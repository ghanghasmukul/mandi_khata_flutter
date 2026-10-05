import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/interest/data/interest_statement_pdf.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_statement_data.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Font _font(String file) => pw.Font.ttf(
  ByteData.sublistView(
    File('../../packages/mk_ui/assets/fonts/$file').readAsBytesSync(),
  ),
);

StatementFonts _fonts() => StatementFonts(
  regular: _font('IBMPlexSans-Regular.ttf'),
  bold: _font('IBMPlexSans-SemiBold.ttf'),
  fallback: [
    _font('NotoSansDevanagari-Regular.ttf'),
    _font('NotoSansGurmukhi-Regular.ttf'),
  ],
);

void main() {
  final asOf = LedgerDate(2027, 4, 11);
  final config = InterestConfig(
    ratePa: Decimal.parse('18'),
    rounding: InterestRounding.paise,
  );
  final result = calculate(
    events: [
      LedgerEvent(
        id: 'a',
        date: LedgerDate(2027, 1, 1),
        side: Side.udhaar,
        amountPaise: 10000000,
      ),
      LedgerEvent(
        id: 'b',
        date: LedgerDate(2027, 2, 1),
        side: Side.jama,
        amountPaise: 2000000,
      ),
    ],
    config: config,
    asOf: asOf,
  );
  const party = Party(
    id: 'p1',
    code: 'F-1',
    name: 'ਗੁਰਮੀਤ ਸਿੰਘ',
    village: 'Rampura',
    roles: {PartyRole.farmer},
  );

  for (final code in ['en', 'hi', 'pa']) {
    test(
      'the byaj statement is built in $code, rows follow the engine',
      () async {
        final l10n = lookupAppLocalizations(Locale(code));
        final data = interestStatementData(
          l10n,
          businessName: 'Gupta Arhat',
          party: party,
          config: config,
          result: result,
          asOf: asOf,
          postedPaise: 100000,
          formatDate: (d) => d.toString(),
        );
        expect(data.headers, hasLength(9));
        expect(data.rows, hasLength(result.schedule.length));
        expect(data.rows.every((r) => r.length == 9), isTrue);
        expect(data.title, l10n.byajStatementTitle);
        expect(
          data.figures.last.amount,
          Money(result.totalPayablePaise).format(),
        );
        // Posted 1,000 of the charged interest is shown.
        expect(
          data.figures.map((f) => f.amount),
          contains(const Money(100000).format()),
        );

        final bytes = await InterestStatementPdf.build(
          data: data,
          fonts: _fonts(),
        );
        expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
        expect(bytes.length, greaterThan(1000));
      },
    );
  }
}
