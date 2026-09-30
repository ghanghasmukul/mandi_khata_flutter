import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('DocumentSeries', () {
    test(r'stable codes match number_series.series (^[A-Z]{1,4}$)', () {
      expect(DocumentSeries.receipt.code, 'R');
      expect(DocumentSeries.lot.code, 'L');
      expect(DocumentSeries.salesInvoice.code, 'SI');
      expect(DocumentSeries.purchaseInvoice.code, 'PI');
      expect(DocumentSeries.karza.code, 'KZ');
      expect(DocumentSeries.voucher.code, 'V');
      for (final s in DocumentSeries.values) {
        expect(RegExp(r'^[A-Z]{1,4}$').hasMatch(s.code), isTrue);
      }
    });

    test('each series has its settings key with a default prefix', () {
      for (final s in DocumentSeries.values) {
        final key = SettingsSchema.parse(s.settingKey);
        expect(key, isNotNull, reason: s.settingKey);
        final dflt = key!.def.defaultFor(key.suffix)! as Map;
        expect(dflt['prefix'], '${s.code}-');
      }
    });
  });

  group('formatDocumentNumber', () {
    test('prefix + device + zero-padded counter (CLAUDE.md rule 10)', () {
      expect(formatDocumentNumber('R-', 'W1', 42), 'R-W1-0042');
      expect(formatDocumentNumber('SI-', 'A12', 7741), 'SI-A12-7741');
      expect(formatDocumentNumber('L-', 'B1', 1), 'L-B1-0001');
    });

    test('grows past four digits instead of wrapping', () {
      expect(formatDocumentNumber('R-', 'W1', 10000), 'R-W1-10000');
      expect(formatDocumentNumber('R-', 'W1', 1234567), 'R-W1-1234567');
    });

    test('rejects values that could collide or be unreadable', () {
      expect(() => formatDocumentNumber('R-', 'W1', 0), throwsArgumentError);
      expect(() => formatDocumentNumber('R-', 'w1', 1), throwsArgumentError);
      expect(() => formatDocumentNumber('R', 'W1', 1), throwsArgumentError);
    });
  });

  group('parseDocumentNumber', () {
    test('round-trips', () {
      final n = parseDocumentNumber('SI-A12-7741')!;
      expect((n.prefix, n.deviceCode, n.counter), ('SI-', 'A12', 7741));
      expect(parseDocumentNumber('R-W1-0042')!.counter, 42);
      expect(parseDocumentNumber('R-W1-0042').toString(), 'R-W1-0042');
      expect(const DocumentNumber('KZ-', 'M2', 9).toString(), 'KZ-M2-0009');
    });

    test('numbers from different devices never collide', () {
      expect(
        formatDocumentNumber('R-', 'W1', 5),
        isNot(formatDocumentNumber('R-', 'A1', 5)),
      );
    });

    test('rejects other text', () {
      expect(parseDocumentNumber('R-3008'), isNull);
      expect(parseDocumentNumber('hello'), isNull);
      expect(parseDocumentNumber('R-W1-00x2'), isNull);
    });
  });
}
