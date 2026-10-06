import 'package:khata_core/src/journal.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/lot_rules.dart';
import 'package:khata_core/src/mandi_charges.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/payment_rules.dart';

/// The journal entry every document makes, exactly as written in
/// docs/domain/posting-rules.md (section 4). Each function returns a checked
/// [JournalEntryDraft]; the app writes it in the same transaction as the
/// document and its khata entries.
abstract final class PostingRules {
  static JournalAccount _system(SystemAccount a) => SystemJournalAccount(a);

  /// Row 1: a posted lot.
  ///
  /// - Dr the buyer for `gross + buyer-borne charges` (Lot Sale Clearing
  ///   when the lot has no buyer);
  /// - Cr the farmer for the net;
  /// - Cr the income or payable account of every charge the farmer or the
  ///   buyer bears;
  /// - a mandi fee or cess the arhtiya bears: Dr own-cost expense, Cr the
  ///   matching payable; other charges the arhtiya bears and a waived
  ///   commission write no line.
  static JournalEntryDraft lot({
    required String lotId,
    required LedgerDate date,
    required LotPostingPlan plan,
    String? lotNo,
  }) {
    final b = plan.breakdown;
    final buyer = plan.buyer;
    final builder = JournalBuilder()
      ..debit(
        buyer == null
            ? _system(SystemAccount.lotSaleClearing)
            : PartyAccount(buyer.partyId),
        b.buyerTotal,
      )
      ..credit(PartyAccount(plan.farmer.partyId), b.netToFarmer);
    for (final line in b.lines) {
      if (!line.amount.isPositive) continue;
      final income = _chargeAccount(line.charge);
      switch (line.payer) {
        case ChargePayer.farmer:
        case ChargePayer.buyer:
          builder.credit(income, line.amount, memo: line.name);
        case ChargePayer.arhtiya:
          final cost = _ownCostAccount(line.charge);
          if (cost == null) continue;
          builder
            ..debit(cost, line.amount, memo: line.name)
            ..credit(income, line.amount, memo: line.name);
      }
    }
    return builder.build(sourceKey: 'lot:$lotId', date: date, narration: lotNo);
  }

  static JournalAccount _chargeAccount(MandiCharge charge) =>
      _system(switch (charge) {
        MandiCharge.commission => SystemAccount.commissionIncome,
        MandiCharge.palledari => SystemAccount.palledariReceipts,
        MandiCharge.bardana => SystemAccount.bardanaReceipts,
        MandiCharge.tulai => SystemAccount.tulaiReceipts,
        MandiCharge.mandiFee => SystemAccount.mandiFeePayable,
        MandiCharge.cess => SystemAccount.cessPayable,
      });

  /// Only a mandi fee and a cess are owed to someone (the market committee)
  /// at the time of the lot; the other charges the arhtiya bears are costs
  /// when they are paid.
  static JournalAccount? _ownCostAccount(MandiCharge charge) =>
      switch (charge) {
        MandiCharge.mandiFee => _system(SystemAccount.mandiFeeOwnCost),
        MandiCharge.cess => _system(SystemAccount.cessOwnCost),
        _ => null,
      };

  /// Rows 2, 3, 4, 8, 9: a payment to a party, a receipt from one, a loan
  /// disbursal (a payment to the borrower) or a cash / bank loan repayment (a
  /// receipt). Paying out: Dr party, Cr cash / bank. Receiving: the other
  /// way round.
  static JournalEntryDraft payment({
    required String paymentId,
    required LedgerDate date,
    required PaymentDirection direction,
    required String partyId,
    required String bankAccountId,
    required Money amount,
    String? narration,
  }) {
    final party = PartyAccount(partyId);
    final book = BookAccount(bankAccountId);
    final builder = JournalBuilder();
    if (direction == PaymentDirection.toParty) {
      builder
        ..debit(party, amount)
        ..credit(book, amount);
    } else {
      builder
        ..debit(book, amount)
        ..credit(party, amount);
    }
    return builder.build(
      sourceKey: 'payment:$paymentId',
      date: date,
      narration: narration,
    );
  }

  /// Row 11: interest posted to the khata. Dr party, Cr Interest Income.
  static JournalEntryDraft interest({
    required String postingId,
    required LedgerDate date,
    required String partyId,
    required Money amount,
    String? narration,
  }) =>
      (JournalBuilder()
            ..debit(PartyAccount(partyId), amount)
            ..credit(_system(SystemAccount.interestIncome), amount))
          .build(
            sourceKey: 'interest:$postingId',
            date: date,
            narration: narration,
          );

  /// Row 12: interest waived. Dr Interest Waived, Cr party.
  static JournalEntryDraft waiver({
    required String postingId,
    required LedgerDate date,
    required String partyId,
    required Money amount,
    String? narration,
  }) =>
      (JournalBuilder()
            ..debit(_system(SystemAccount.interestWaived), amount)
            ..credit(PartyAccount(partyId), amount))
          .build(
            sourceKey: 'waiver:$postingId',
            date: date,
            narration: narration,
          );

  /// Row 13: a manual khata entry. Udhaar: Dr party, Cr Khata Adjustments;
  /// jama: the other way round.
  static JournalEntryDraft manualEntry({
    required String entryId,
    required LedgerDate date,
    required Side side,
    required String partyId,
    required Money amount,
    String? narration,
  }) => _againstSystem(
    sourceKey: 'entry:$entryId',
    date: date,
    side: side,
    partyId: partyId,
    amount: amount,
    counter: SystemAccount.khataAdjustments,
    narration: narration,
  );

  /// Row 14: an opening balance. Udhaar: Dr party, Cr Opening Balance Equity;
  /// jama: the other way round.
  static JournalEntryDraft openingBalance({
    required String entryId,
    required LedgerDate date,
    required Side side,
    required String partyId,
    required Money amount,
    String? narration,
  }) => _againstSystem(
    sourceKey: 'entry:$entryId',
    date: date,
    side: side,
    partyId: partyId,
    amount: amount,
    counter: SystemAccount.openingBalanceEquity,
    narration: narration,
  );

  static JournalEntryDraft _againstSystem({
    required String sourceKey,
    required LedgerDate date,
    required Side side,
    required String partyId,
    required Money amount,
    required SystemAccount counter,
    String? narration,
  }) {
    final party = PartyAccount(partyId);
    final other = _system(counter);
    final builder = JournalBuilder();
    if (side == Side.udhaar) {
      builder
        ..debit(party, amount)
        ..credit(other, amount);
    } else {
      builder
        ..debit(other, amount)
        ..credit(party, amount);
    }
    return builder.build(
      sourceKey: sourceKey,
      date: date,
      narration: narration,
    );
  }
}
