import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/payments/data/receipt_pdf.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/invoice_actions.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Font _font(String file) => pw.Font.ttf(
  ByteData.sublistView(
    File('../../packages/mk_ui/assets/fonts/$file').readAsBytesSync(),
  ),
);

final _fonts = StatementFonts(
  regular: _font('IBMPlexSans-Regular.ttf'),
  bold: _font('IBMPlexSans-SemiBold.ttf'),
  fallback: [
    _font('NotoSansDevanagari-Regular.ttf'),
    _font('NotoSansGurmukhi-Regular.ttf'),
  ],
);

SaleDetail _detail() {
  const split = GstSplit(
    taxable: Money(10000),
    cgst: Money(250),
    sgst: Money(250),
    igst: Money.zero,
  );
  return SaleDetail(
    sale: SaleRecord(
      id: 's1',
      saleNo: 'SI-W1-0001',
      entryDate: LedgerDate(2027, 4, 30),
      partyName: 'Gurmeet Singh',
      partyCode: 'F-1',
      customerGstin: '03AAPFU0939F1ZV',
      placeOfSupply: '03',
      tier: 'farmer',
      subtotal: const Money(10500),
      lineDiscounts: Money.zero,
      invoiceDiscount: Money.zero,
      invoiceDiscountPct: 0,
      gst: split,
      roundOff: Money.zero,
      total: const Money(10500),
      paidCash: const Money(5000),
      paidUpi: Money.zero,
      paidCredit: const Money(5500),
      status: SaleStatus.posted,
      createdAt: DateTime.utc(2027, 4, 30),
    ),
    lines: [
      InvoiceLine(
        id: 'l1',
        lineNo: 0,
        productId: 'p1',
        productName: 'DAP 50 kg',
        unit: 'bag',
        batchId: 'b1',
        batchNo: 'B-77',
        expiry: LedgerDate(2028, 6, 30),
        qtyMilli: 1000,
        unitPrice: const Money(10500),
        discount: Money.zero,
        split: split,
        unitCost: const Money(8000),
        rateBp: 500,
        hsn: '3105',
      ),
    ],
  );
}

void main() {
  setUpAll(initializeDateFormatting);

  for (final code in ['en', 'hi', 'pa']) {
    for (final layout in [ReceiptLayout.a5, ReceiptLayout.thermal80]) {
      test('invoice PDF in $code on ${layout.name}', () async {
        final bytes = await SaleInvoices.build(
          _detail(),
          l10n: lookupAppLocalizations(Locale(code)),
          languageCode: code,
          fonts: _fonts,
          businessName: 'Gupta Kisan Seva Kendra',
          businessGstin: '03AAPFU0939F1ZV',
          layout: layout,
        );
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
        expect(bytes.length, greaterThan(1500));
      });
    }
  }
}
