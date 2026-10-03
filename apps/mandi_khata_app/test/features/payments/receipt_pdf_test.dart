import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/payments/data/receipt_pdf.dart';
import 'package:pdf/pdf.dart';
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

const _labels = ReceiptLabels(
  title: 'Payment voucher',
  partyLabel: 'Paid to',
  no: 'No.',
  date: 'Date',
  amount: 'Amount',
  mode: 'Mode',
  reference: 'Reference',
  chequeNo: 'Cheque no.',
  chequeDate: 'Cheque date',
  balanceAfter: 'Balance after this',
  signature: 'Signature',
  reversed: 'REVERSED',
  balanceSide: _side,
);

String _side(Money m) => m.isPositive ? 'Jama' : 'Udhaar';

const _data = ReceiptData(
  businessName: 'Gupta Arhat',
  receiptNo: 'V-W1-0042',
  date: '10 Apr 2026',
  partyName: 'Gurmeet Singh',
  partyDetail: 'F-101 · Rampura',
  amount: Money(1983276),
  modeName: 'Cheque',
  chequeNo: '004512',
  chequeDate: '10 Apr 2026',
  narration: 'Wheat advance',
  balanceAfter: Money.rupees(6000),
);

/// The first `/MediaBox [0 0 w h]` in the file.
({double width, double height}) _pageSize(Uint8List bytes) {
  final m = RegExp(
    r'/MediaBox\s*\[\s*0\s+0\s+([\d.]+)\s+([\d.]+)\s*\]',
  ).firstMatch(latin1.decode(bytes, allowInvalid: true))!;
  return (width: double.parse(m[1]!), height: double.parse(m[2]!));
}

void main() {
  Future<Uint8List> build(
    ReceiptLayout layout, {
    ReceiptData data = _data,
    ReceiptLabels labels = _labels,
  }) => ReceiptPdf.build(
    data: data,
    labels: labels,
    fonts: _fonts,
    layout: layout,
  );

  test('A5 sheet: one page of 148 × 210 mm', () async {
    final bytes = await build(ReceiptLayout.a5);
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    final size = _pageSize(bytes);
    expect(size.width, closeTo(PdfPageFormat.a5.width, 0.5));
    expect(size.height, closeTo(PdfPageFormat.a5.height, 0.5));
    expect(
      RegExp(
        r'/Type\s*/Page\b',
      ).allMatches(latin1.decode(bytes, allowInvalid: true)).length,
      1,
    );
  });

  test('thermal rolls are 80 mm and 57 mm wide and fit the content', () async {
    final r80 = _pageSize(await build(ReceiptLayout.thermal80));
    final r58 = _pageSize(await build(ReceiptLayout.thermal58));
    expect(r80.width, closeTo(PdfPageFormat.roll80.width, 0.5));
    expect(r58.width, closeTo(PdfPageFormat.roll57.width, 0.5));
    // The roll is as tall as the receipt, not a fixed sheet.
    expect(r80.height, lessThan(PdfPageFormat.a5.height));
    expect(r80.height, greaterThan(100));
  });

  test('reversed receipts, receipts without a balance and Hindi / Punjabi '
      'text all build', () async {
    for (final layout in ReceiptLayout.values) {
      expect(
        (await build(
          layout,
          data: const ReceiptData(
            businessName: 'गुप्ता आढ़त',
            receiptNo: 'R-W1-0001',
            date: '10 अप्रैल 2026',
            partyName: 'ਗੁਰਮੀਤ ਸਿੰਘ',
            amount: Money.rupees(500),
            modeName: 'नकद',
            isReversed: true,
          ),
          labels: const ReceiptLabels(
            title: 'रसीद',
            partyLabel: 'प्राप्त किया',
            no: 'नंबर',
            date: 'तारीख',
            amount: 'रकम',
            mode: 'तरीका',
            reference: 'संदर्भ',
            chequeNo: 'चेक नं.',
            chequeDate: 'चेक की तारीख',
            balanceAfter: 'इसके बाद बाकी',
            signature: 'हस्ताक्षर',
            reversed: 'उलटा किया',
            balanceSide: _side,
          ),
        )).length,
        greaterThan(1000),
      );
    }
  });

  test('the layout comes from print.receipt_size, A5 by default', () {
    expect(ReceiptLayout.fromSetting('thermal_80'), ReceiptLayout.thermal80);
    expect(ReceiptLayout.fromSetting('thermal_58'), ReceiptLayout.thermal58);
    expect(ReceiptLayout.fromSetting('a5'), ReceiptLayout.a5);
    expect(ReceiptLayout.fromSetting(null), ReceiptLayout.a5);
    expect(ReceiptLayout.fromSetting('letter'), ReceiptLayout.a5);
    expect(ReceiptLayout.a5.isRoll, isFalse);
    expect(ReceiptLayout.thermal80.isRoll, isTrue);
  });
}
