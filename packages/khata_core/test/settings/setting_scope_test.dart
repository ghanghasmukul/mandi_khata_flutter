import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  test('database names round-trip; unknown scopes are null', () {
    for (final s in SettingScope.values) {
      expect(SettingScope.parse(s.dbName), s);
    }
    expect(SettingScope.parse('party_group'), SettingScope.partyGroup);
    expect(SettingScope.parse('village'), isNull);
  });

  test('loan, lot and invoice are the document level', () {
    expect(SettingScope.values.where((s) => s.isDocument).toSet(), {
      SettingScope.loan,
      SettingScope.lot,
      SettingScope.invoice,
    });
    for (final s in SettingScope.values) {
      expect(s.level == SettingLevel.document, s.isDocument, reason: '$s');
    }
  });

  test('SettingKey equality is by key and suffix', () {
    final a = SettingsSchema.parse('mandi.commission_pct.wheat');
    final b = SettingsSchema.parse('mandi.commission_pct.wheat');
    final c = SettingsSchema.parse('mandi.commission_pct');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));
  });
}
