import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/features/accounts/data/book_line_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/products/data/stock_repository.dart';
import 'package:mandi_khata_app/features/shop_sales/data/sale_reader.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

/// Sales returns: select lines and quantities of a posted bill, restock the
/// ORIGINAL batch, then credit the party's khata (`shop_return` jama) or
/// refund cash / UPI. One local transaction; all refusals before any write.
class ReturnRepository {
  ReturnRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;
  final Map<String, Object?> planDefaults;

  /// What a return of [items] would refund and how it would settle; null
  /// when the items are not valid. For the preview in the return dialog.
  static ({SalesReturnResult result, ReturnSettlement settlement})? preview(
    SaleDetail d,
    List<ReturnItem> items,
    RefundChoice choice, {
    Money priorRoundOff = Money.zero,
  }) {
    final requests = _requests(d, items);
    if (requests == null || requests.isEmpty) return null;
    final sold = [for (final l in d.lines) l.toSoldLine()];
    if (SalesReturns.validate(sold, requests).isNotEmpty) return null;
    final result = SalesReturns.compute(
      sold,
      requests,
      invoiceRoundOff: d.sale.roundOff,
      roundOffReturned: priorRoundOff,
    );
    return (
      result: result,
      settlement: ReturnSettlement.split(
        refund: result.refund,
        choice: choice,
        hasParty: d.sale.partyId != null,
        unpaidOnBill: d.unpaidOnBill,
      ),
    );
  }

  static List<ReturnRequest>? _requests(SaleDetail d, List<ReturnItem> items) {
    final out = <ReturnRequest>[];
    for (final it in items) {
      final i = d.lines.indexWhere((l) => l.id == it.saleLineId);
      if (i < 0) return null;
      out.add(ReturnRequest(i, it.qtyMilli));
    }
    return out;
  }

  Future<ReturnSaveResult> create(
    WriteContext ctx,
    ReturnDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.salesReturn)) {
      return const ReturnNotPermitted(Permission.salesReturn);
    }
    if (draft.items.isEmpty) {
      return const ReturnInvalid({ReturnProblem.noItems});
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final d = await SaleReader.detailIn(tx, ctx.tenantId, draft.saleId);
      if (d == null) return const ReturnNotFound();
      if (d.sale.status != SaleStatus.posted) return const ReturnLocked();
      final date = draft.entryDate ?? LedgerDate.fromDateTime(when);
      final refused = await LedgerRepository.checkDate(
        tx,
        ctx,
        RefType.shopReturn,
        date,
        can: can,
        now: when,
        planDefaults: planDefaults,
      );
      if (refused != null) {
        return ReturnNotPermitted(
          refused.permission,
          backdateDays: refused.backdateDays,
          lockedYear: refused.lockedYear,
        );
      }
      final prior = await tx.getOptional(
        'SELECT COALESCE(SUM(round_off_paise), 0) AS s FROM shop_returns '
        "WHERE tenant_id = ? AND sale_id = ? AND status = 'posted'",
        [ctx.tenantId, draft.saleId],
      );
      final p = preview(
        d,
        draft.items,
        draft.choice,
        priorRoundOff: Money(prior!['s']! as int),
      );
      if (p == null) return const ReturnInvalid({ReturnProblem.badQuantity});
      if (!p.settlement.ok) {
        return const ReturnInvalid({ReturnProblem.noParty});
      }
      final result = p.result;
      final settlement = p.settlement;
      // Belt and braces: khata_core clamps, but never write a negative refund.
      if (result.refund.paise < 0) {
        return const ReturnInvalid({ReturnProblem.badQuantity});
      }
      // Mirrors the server guard: a bank / UPI refund needs finance.view.
      if (draft.viaUpi &&
          settlement.cash.isPositive &&
          !can(Permission.financeView)) {
        return const ReturnNotPermitted(Permission.financeView);
      }

      String? bankId;
      if (draft.viaUpi && settlement.cash.isPositive) {
        final bank = await tx.getOptional(
          'SELECT id FROM bank_accounts WHERE tenant_id = ? AND id = ? '
          "AND kind = 'bank' AND is_active = 1",
          [ctx.tenantId, draft.bankAccountId],
        );
        if (bank == null) {
          return const ReturnInvalid({ReturnProblem.upiNeedsAccount});
        }
        bankId = bank['id']! as String;
      }

      // ---- writes ----
      final id = const Uuid().v4();
      final returnNo = await NumberSeriesService.next(
        tx,
        ctx,
        DocumentSeries.salesReturn,
        now: when,
      );
      final at = when.toUtc().toIso8601String();
      final viaUpi = bankId != null;
      final header = <String, Object?>{
        'return_no': returnNo,
        'sale_id': draft.saleId,
        'party_id': d.sale.partyId,
        'entry_date': date.toString(),
        'taxable_paise': result.split.taxable.paise,
        'cgst_paise': result.split.cgst.paise,
        'sgst_paise': result.split.sgst.paise,
        'igst_paise': result.split.igst.paise,
        'round_off_paise': result.roundOff.paise,
        'total_paise': result.refund.paise,
        'refund_mode': draft.choice == RefundChoice.cash && viaUpi
            ? 'upi'
            : draft.choice.name,
        'refund_khata_paise': settlement.khata.paise,
        'refund_cash_paise': viaUpi ? 0 : settlement.cash.paise,
        'refund_upi_paise': viaUpi ? settlement.cash.paise : 0,
        'bank_account_id': bankId,
        'note': draft.note?.trim().isEmpty ?? true ? null : draft.note!.trim(),
        'status': 'posted',
      };
      await tx.execute(
        'INSERT INTO shop_returns (id, tenant_id, ${header.keys.join(', ')}, '
        'device_id, created_by, created_at, updated_at) VALUES '
        '(${List.filled(header.length + 6, '?').join(', ')})',
        [id, ctx.tenantId, ...header.values, ctx.deviceId, ctx.userId, at, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'shop_returns',
        rowId: id,
        action: AuditAction.insert,
        after: {for (final e in header.entries) e.key: ?e.value},
        at: when,
      );
      var n = 0;
      for (final r in result.lines) {
        final line = d.lines[r.lineIndex];
        final lid = const Uuid().v4();
        final cols = <String, Object?>{
          'shop_return_id': id,
          'line_no': n++,
          'sale_line_id': line.id,
          'product_id': line.productId,
          'batch_id': line.batchId,
          'qty_milli': r.qtyMilli,
          'taxable_paise': r.split.taxable.paise,
          'cgst_paise': r.split.cgst.paise,
          'sgst_paise': r.split.sgst.paise,
          'igst_paise': r.split.igst.paise,
          'amount_paise': r.split.total.paise,
        };
        await tx.execute(
          'INSERT INTO shop_return_lines (id, tenant_id, '
          '${cols.keys.join(', ')}, created_by, created_at) VALUES '
          '(${List.filled(cols.length + 4, '?').join(', ')})',
          [lid, ctx.tenantId, ...cols.values, ctx.userId, at],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'shop_return_lines',
          rowId: lid,
          action: AuditAction.insert,
          after: {for (final e in cols.entries) e.key: ?e.value},
          at: when,
        );
      }
      for (final r in result.lines) {
        final line = d.lines[r.lineIndex];
        final mid = const Uuid().v4();
        await StockMovementWriter.insert(
          tx,
          ctx,
          id: mid,
          productId: line.productId,
          batchId: line.batchId,
          date: date,
          qtyMilli: r.qtyMilli,
          reason: StockMovementReason.saleReturn,
          refType: 'shop_return',
          refId: id,
          at: when,
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'stock_movements',
          rowId: mid,
          action: AuditAction.insert,
          after: {
            'product_id': line.productId,
            'batch_id': line.batchId,
            'qty_milli': r.qtyMilli,
            'reason': 'sale_return',
            'ref_id': id,
          },
          at: when,
        );
      }
      if (settlement.khata.isPositive) {
        await LedgerRepository.post(
          tx,
          ctx,
          LedgerDraft(
            partyId: d.sale.partyId!,
            side: Side.jama,
            amount: settlement.khata,
            refType: RefType.shopReturn,
            refId: id,
            entryDate: date,
            narration: returnNo,
          ),
          now: when,
        );
      }
      final refunds = <BookPayment>[];
      if (settlement.cash.isPositive) {
        final account =
            bankId ?? BankAccountsRepository.cashIdFor(ctx.tenantId);
        refunds.add(BookPayment(account, settlement.cash));
        await BookLineWriter.insert(
          tx,
          ctx,
          source: BookSource.shopReturn,
          sourceId: id,
          accountId: account,
          accountKind: viaUpi ? 'bank' : 'cash',
          entryDate: date,
          direction: BookDirection.moneyOut,
          amount: settlement.cash,
          narration: returnNo,
          when: when,
        );
      }
      final plan = ShopPosting.saleReturn(
        returnId: id,
        date: date,
        result: result,
        settlement: settlement,
        refunds: refunds,
        partyId: d.sale.partyId,
        returnNo: returnNo,
      );
      await JournalWriter.post(tx, ctx, plan.journal, now: when);
      return ReturnSaved(
        id,
        returnNo,
        refund: result.refund,
        toKhata: settlement.khata,
        toCash: settlement.cash,
      );
    });
  }
}
