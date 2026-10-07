import 'package:khata_core/src/gst.dart';
import 'package:khata_core/src/journal.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/purchase_rules.dart';
import 'package:khata_core/src/return_rules.dart';
import 'package:khata_core/src/sale_calc.dart';
import 'package:khata_core/src/stock_rules.dart';
import 'package:meta/meta.dart';

/// Money moved through one cash / bank book (cash, or a bank for UPI).
@immutable
final class BookPayment {
  const BookPayment(this.bookAccountId, this.amount);

  final String bookAccountId;
  final Money amount;
}

/// The khata entry a shop document writes with its journal entry.
@immutable
final class ShopKhataEntry {
  const ShopKhataEntry({
    required this.refType,
    required this.side,
    required this.partyId,
    required this.amount,
  });

  final RefType refType;
  final Side side;
  final String partyId;
  final Money amount;
}

/// A shop document's postings: always the journal entry, and the khata entry
/// when part of it goes through a party.
@immutable
final class ShopPostingPlan {
  const ShopPostingPlan({required this.journal, this.khata});

  final JournalEntryDraft journal;
  final ShopKhataEntry? khata;
}

/// The journal entries of the shop documents, exactly as written in
/// docs/domain/posting-rules.md section 12. Only the unpaid / udhaar part
/// goes through the party account (so party accounts keep mirroring the
/// khata); the paid part goes straight to cash / bank.
abstract final class ShopPosting {
  static JournalAccount _sys(SystemAccount a) => SystemJournalAccount(a);

  static void _gst(
    JournalBuilder b,
    GstSplit s, {
    required bool output,
    required bool debit,
  }) {
    final accounts = output
        ? (
            SystemAccount.gstOutputCgst,
            SystemAccount.gstOutputSgst,
            SystemAccount.gstOutputIgst,
          )
        : (
            SystemAccount.gstInputCgst,
            SystemAccount.gstInputSgst,
            SystemAccount.gstInputIgst,
          );
    final parts = [
      (accounts.$1, s.cgst),
      (accounts.$2, s.sgst),
      (accounts.$3, s.igst),
    ];
    for (final (account, amount) in parts) {
      if (!amount.isPositive) continue;
      if (debit) {
        b.debit(_sys(account), amount);
      } else {
        b.credit(_sys(account), amount);
      }
    }
  }

  /// Adds a signed amount: positive on the credit side, negative on debit.
  static void _signedCredit(JournalBuilder b, SystemAccount a, Money m) {
    if (m.isPositive) b.credit(_sys(a), m);
    if (m.isNegative) b.debit(_sys(a), -m);
  }

  static void _pay(
    JournalBuilder b,
    List<BookPayment> pays, {
    required bool debit,
  }) {
    for (final p in pays) {
      if (!p.amount.isPositive) continue;
      if (debit) {
        b.debit(BookAccount(p.bookAccountId), p.amount);
      } else {
        b.credit(BookAccount(p.bookAccountId), p.amount);
      }
    }
  }

  static ShopKhataEntry? _khata(
    RefType ref,
    Side side,
    String? partyId,
    Money amount,
  ) => amount.isPositive && partyId != null
      ? ShopKhataEntry(
          refType: ref,
          side: side,
          partyId: partyId,
          amount: amount,
        )
      : null;

  /// Row 17: a saved bill. [paid] are the cash / UPI parts; [udhaar] needs
  /// a [partyId]; paid + udhaar must equal `totals.total`. [cogs] is the
  /// cost of the batches sold (sum of `BatchAllocation.cost`).
  static ShopPostingPlan sale({
    required String saleId,
    required LedgerDate date,
    required SaleTotals totals,
    required List<BookPayment> paid,
    required Money cogs,
    Money udhaar = Money.zero,
    String? partyId,
    String? invoiceNo,
  }) {
    final paidSum = paid.fold(Money.zero, (a, p) => a + p.amount);
    if (paidSum + udhaar != totals.total) {
      throw JournalError('Payment does not equal the bill total');
    }
    if (udhaar.isPositive && partyId == null) {
      throw JournalError('Udhaar needs a party');
    }
    final b = JournalBuilder();
    if (udhaar.isPositive) b.debit(PartyAccount(partyId!), udhaar);
    _pay(b, paid, debit: true);
    b.credit(_sys(SystemAccount.sales), totals.gst.taxable);
    _gst(b, totals.gst, output: true, debit: false);
    _signedCredit(b, SystemAccount.roundOff, totals.roundOff);
    if (cogs.isPositive) {
      b
        ..debit(_sys(SystemAccount.costOfGoodsSold), cogs)
        ..credit(_sys(SystemAccount.stockInHand), cogs);
    }
    return ShopPostingPlan(
      journal: b.build(
        sourceKey: 'shop_sale:$saleId',
        date: date,
        narration: invoiceNo,
      ),
      khata: _khata(RefType.shopSale, Side.udhaar, partyId, udhaar),
    );
  }

  /// Row 18: a sales return. [settlement] splits `result.refund` between
  /// the party's khata and cash / bank [refunds]; the returned goods come
  /// back at `result.cost`.
  static ShopPostingPlan saleReturn({
    required String returnId,
    required LedgerDate date,
    required SalesReturnResult result,
    required ReturnSettlement settlement,
    required List<BookPayment> refunds,
    String? partyId,
    String? returnNo,
  }) {
    _checkSettlement(result.refund, settlement, refunds, partyId);
    final b = JournalBuilder()
      ..debit(_sys(SystemAccount.sales), result.split.taxable);
    _gst(b, result.split, output: true, debit: true);
    _signedCredit(b, SystemAccount.roundOff, -result.roundOff);
    if (settlement.khata.isPositive) {
      b.credit(PartyAccount(partyId!), settlement.khata);
    }
    _pay(b, refunds, debit: false);
    if (result.cost.isPositive) {
      b
        ..debit(_sys(SystemAccount.stockInHand), result.cost)
        ..credit(_sys(SystemAccount.costOfGoodsSold), result.cost);
    }
    return ShopPostingPlan(
      journal: b.build(
        sourceKey: 'shop_return:$returnId',
        date: date,
        narration: returnNo,
      ),
      khata: _khata(RefType.shopReturn, Side.jama, partyId, settlement.khata),
    );
  }

  /// Row 19: a supplier invoice. [paid] is paid now; the rest of
  /// `totals.total` is the supplier's khata (jama).
  static ShopPostingPlan purchase({
    required String purchaseId,
    required LedgerDate date,
    required PurchaseTotals totals,
    required String supplierId,
    required List<BookPayment> paid,
    String? billNo,
  }) {
    final paidSum = paid.fold(Money.zero, (a, p) => a + p.amount);
    final unpaid = totals.total - paidSum;
    if (unpaid.isNegative) throw JournalError('Paid more than the bill');
    final b = JournalBuilder()
      ..debit(_sys(SystemAccount.stockInHand), totals.stockValue);
    _gst(b, totals.gst, output: false, debit: true);
    _signedCredit(b, SystemAccount.roundOff, -totals.roundOff);
    if (unpaid.isPositive) b.credit(PartyAccount(supplierId), unpaid);
    _pay(b, paid, debit: false);
    return ShopPostingPlan(
      journal: b.build(
        sourceKey: 'purchase:$purchaseId',
        date: date,
        narration: billNo,
      ),
      khata: _khata(RefType.purchase, Side.jama, supplierId, unpaid),
    );
  }

  /// Row 20: goods sent back to the supplier. [settlement] splits
  /// `result.refund` between the supplier's khata (udhaar: a credit note)
  /// and cash / bank [received].
  static ShopPostingPlan purchaseReturn({
    required String returnId,
    required LedgerDate date,
    required PurchaseReturnResult result,
    required ReturnSettlement settlement,
    required List<BookPayment> received,
    required String supplierId,
    String? returnNo,
  }) {
    _checkSettlement(result.refund, settlement, received, supplierId);
    final b = JournalBuilder()
      ..credit(_sys(SystemAccount.stockInHand), result.stockValue);
    _gst(b, result.split, output: false, debit: false);
    if (settlement.khata.isPositive) {
      b.debit(PartyAccount(supplierId), settlement.khata);
    }
    _pay(b, received, debit: true);
    return ShopPostingPlan(
      journal: b.build(
        sourceKey: 'purchase_return:$returnId',
        date: date,
        narration: returnNo,
      ),
      khata: _khata(
        RefType.purchaseReturn,
        Side.udhaar,
        supplierId,
        settlement.khata,
      ),
    );
  }

  /// Row 21: a stock adjustment worth [value] at cost (positive = stock
  /// found, negative = lost). Opening stock ([StockMovementReason.opening])
  /// is balanced against Opening Balance Equity, anything else against
  /// Stock Adjustment. No khata entry.
  static JournalEntryDraft stockAdjustment({
    required String adjustmentId,
    required LedgerDate date,
    required Money value,
    StockMovementReason reason = StockMovementReason.adjustment,
    String? narration,
  }) {
    if (value.isZero) throw JournalError('A stock adjustment needs a value');
    final counter = reason == StockMovementReason.opening
        ? SystemAccount.openingBalanceEquity
        : SystemAccount.stockAdjustment;
    final stock = _sys(SystemAccount.stockInHand);
    final b = JournalBuilder();
    if (value.isPositive) {
      b
        ..debit(stock, value)
        ..credit(_sys(counter), value);
    } else {
      b
        ..debit(_sys(counter), -value)
        ..credit(stock, -value);
    }
    return b.build(
      sourceKey: 'stock_adjustment:$adjustmentId',
      date: date,
      narration: narration,
    );
  }

  static void _checkSettlement(
    Money refund,
    ReturnSettlement s,
    List<BookPayment> cash,
    String? partyId,
  ) {
    final cashSum = cash.fold(Money.zero, (a, p) => a + p.amount);
    if (s.khata + s.cash != refund || cashSum != s.cash) {
      throw JournalError('Settlement does not equal the refund');
    }
    if (s.khata.isPositive && partyId == null) {
      throw JournalError('Khata credit needs a party');
    }
  }
}
