import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/payments/data/receipt_pdf.dart';
import 'package:mandi_khata_app/features/shop_sales/data/invoice_pdf.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:printing/printing.dart';

/// Builds, prints and shares a bill's invoice in the business language
/// (`app.default_language`): A5 GST invoice, or an 80 mm / 58 mm roll when
/// `print.receipt_size` says so.
abstract final class SaleInvoices {
  static ReceiptLayout layoutOf(WidgetRef ref) => ReceiptLayout.fromSetting(
    ref.read(settingProvider('print.receipt_size', businessTarget))?.value,
  );

  static String languageOf(WidgetRef ref) {
    final code = ref
        .read(settingProvider('app.default_language', businessTarget))
        ?.value;
    return code is String ? code : 'en';
  }

  static String _string(WidgetRef ref, String key) {
    final v = ref.read(settingProvider(key, businessTarget))?.value;
    return v is String ? v : '';
  }

  static Future<Uint8List> pdf(
    WidgetRef ref,
    SaleDetail detail, {
    ReceiptLayout? layout,
  }) async {
    final code = languageOf(ref);
    final l10n = lookupAppLocalizations(Locale(code));
    final fonts = await StatementFonts.load();
    final business = ref.read(activeMembershipProvider)?.tenantName ?? '';
    final gstin = _string(ref, 'business.gstin');
    final gstOn =
        ref.read(settingProvider('shop.gst_enabled', businessTarget))?.value !=
        false;
    return await build(
      detail,
      l10n: l10n,
      languageCode: code,
      fonts: fonts,
      businessName: business,
      businessGstin: gstin,
      gstEnabled: gstOn,
      layout: layout ?? layoutOf(ref),
    );
  }

  /// The PDF without Riverpod, for tests.
  static Future<Uint8List> build(
    SaleDetail detail, {
    required AppLocalizations l10n,
    required String languageCode,
    required StatementFonts fonts,
    required String businessName,
    String businessGstin = '',
    bool gstEnabled = true,
    ReceiptLayout layout = ReceiptLayout.a5,
  }) {
    final s = detail.sale;
    String dateText(LedgerDate d) => (DateFormat.yMMMd(
      languageCode,
    )..useNativeDigits = false).format(DateTime(d.year, d.month, d.day));
    final stateName = s.placeOfSupply == null
        ? null
        : '${GstStates.nameOf(s.placeOfSupply!) ?? ''} (${s.placeOfSupply})';
    final detailLine = [
      s.partyCode,
      detail.partyVillage,
    ].whereType<String>().where((t) => t.isNotEmpty).join(' · ');
    return InvoicePdf.build(
      layout: layout,
      fonts: fonts,
      data: InvoiceData(
        businessName: businessName,
        businessGstin: businessGstin,
        saleNo: s.saleNo,
        date: dateText(s.entryDate),
        customerName: s.displayName,
        customerDetail: detailLine.isEmpty ? null : detailLine,
        customerGstin: s.customerGstin,
        placeOfSupply: stateName,
        isReversed: s.isReversed,
        showGst: gstEnabled,
        subtotal: s.subtotal,
        discount: s.lineDiscounts + s.invoiceDiscount,
        taxable: s.gst.taxable,
        cgst: s.gst.cgst,
        sgst: s.gst.sgst,
        igst: s.gst.igst,
        roundOff: s.roundOff,
        total: s.total,
        paidCash: s.paidCash,
        paidUpi: s.paidUpi,
        udhaar: s.paidCredit,
        lines: [
          for (final l in detail.lines)
            InvoiceLineData(
              name: l.productName,
              hsn: l.hsn,
              qty: Qty.format(l.qtyMilli),
              rate: l.unitPrice,
              discount: l.discount,
              taxable: l.split.taxable,
              gstPct: l.rateBp == null ? null : GstRates.format(l.rateBp!),
              amount: l.total,
              batchCaption: l.batchNo == null
                  ? null
                  : l.expiry == null
                  ? l10n.salesBatchOnly(l.batchNo!)
                  : l10n.salesBatchExpiry(l.batchNo!, dateText(l.expiry!)),
            ),
        ],
      ),
      labels: InvoiceLabels(
        title: gstEnabled && businessGstin.isNotEmpty
            ? l10n.invoiceTax
            : l10n.invoiceRetail,
        no: l10n.invoiceNo,
        date: l10n.invoiceDate,
        billTo: l10n.salesBillTo,
        gstin: l10n.salesGstin,
        placeOfSupply: l10n.salesPlaceOfSupply,
        item: l10n.invoiceItem,
        hsn: l10n.salesHsn,
        qty: l10n.invoiceQty,
        rate: l10n.invoiceRate,
        taxable: l10n.invoiceTaxable,
        gstPct: l10n.invoiceGstPct,
        amount: l10n.invoiceAmount,
        discount: l10n.invoiceDiscount,
        subtotal: l10n.posSubtotal,
        cgst: l10n.posCgst,
        sgst: l10n.posSgst,
        igst: l10n.posIgst,
        roundOff: l10n.posRoundOff,
        total: l10n.invoiceTotal,
        paidCash: l10n.invoicePaidCash,
        paidUpi: l10n.invoicePaidUpi,
        udhaar: l10n.invoiceOnUdhaar,
        thanks: l10n.invoiceThanks,
        signature: l10n.invoiceSignature,
        reversed: l10n.invoiceReversed,
      ),
    );
  }

  static Future<void> print(WidgetRef ref, SaleDetail detail) async {
    final layout = layoutOf(ref);
    final bytes = await pdf(ref, detail, layout: layout);
    await Printing.layoutPdf(
      name: detail.sale.saleNo,
      format: ReceiptPdf.format(layout),
      onLayout: (_) async => bytes,
    );
  }

  static Future<void> share(WidgetRef ref, SaleDetail detail) async {
    final bytes = await pdf(ref, detail);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${detail.sale.saleNo}.pdf',
    );
  }
}
