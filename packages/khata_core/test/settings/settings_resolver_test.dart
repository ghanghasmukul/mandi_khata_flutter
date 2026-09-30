import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

const ram = 'party-ram';
const rampura = 'group-rampura';
const lot = 'lot-445';
const loan = 'loan-12';

SettingRow row(
  SettingScope scope,
  String key,
  Object? value, [
  String? scopeId,
]) => SettingRow(scope: scope, scopeId: scopeId, key: key, value: value);

void main() {
  group('the cascade: document → party → group → tenant → plan → system', () {
    final rows = [
      row(SettingScope.tenant, 'interest.rate_pa', '18'),
      row(SettingScope.partyGroup, 'interest.rate_pa', '15', rampura),
      row(SettingScope.party, 'interest.rate_pa', '12', ram),
      row(SettingScope.loan, 'interest.rate_pa', '10', loan),
    ];
    final r = SettingsResolver(rows, planDefaults: {'interest.rate_pa': '20'});

    test('document wins', () {
      final s = r.resolve(
        'interest.rate_pa',
        partyId: ram,
        partyGroupId: rampura,
        documentId: loan,
      );
      expect(s.value, '10');
      expect(s.level, SettingLevel.document);
    });

    test('then party', () {
      final s = r.resolve(
        'interest.rate_pa',
        partyId: ram,
        partyGroupId: rampura,
      );
      expect((s.value, s.level), ('12', SettingLevel.party));
    });

    test('then party group', () {
      final s = r.resolve(
        'interest.rate_pa',
        partyId: 'someone-else',
        partyGroupId: rampura,
      );
      expect((s.value, s.level), ('15', SettingLevel.partyGroup));
    });

    test('then business', () {
      final s = r.resolve('interest.rate_pa', partyId: 'someone-else');
      expect((s.value, s.level), ('18', SettingLevel.tenant));
    });

    test('then plan, then system default', () {
      final planOnly = SettingsResolver(
        const [],
        planDefaults: {'interest.rate_pa': '20'},
      );
      expect(planOnly.resolve('interest.rate_pa').level, SettingLevel.plan);
      final nothing = SettingsResolver(const []);
      final s = nothing.resolve('interest.rate_pa');
      expect((s.value, s.level), ('18', SettingLevel.system));
    });

    test("another party's or document's rows never apply", () {
      final s = SettingsResolver([
        row(SettingScope.party, 'interest.rate_pa', '5', 'party-other'),
        row(SettingScope.lot, 'interest.rate_pa', '6', 'lot-other'),
      ]).resolve('interest.rate_pa', partyId: ram, documentId: lot);
      expect(s.level, SettingLevel.system);
    });

    test('a party id alone does not match a group row with the same id', () {
      final s = SettingsResolver([
        row(SettingScope.partyGroup, 'interest.rate_pa', '7', ram),
      ]).resolve('interest.rate_pa', partyId: ram);
      expect(s.level, SettingLevel.system);
    });
  });

  group('null means inherit', () {
    test('a reset value falls through to the next level', () {
      final s = SettingsResolver([
        row(SettingScope.tenant, 'interest.method', 'compound'),
        row(SettingScope.party, 'interest.method', null, ram),
      ]).resolve('interest.method', partyId: ram);
      expect((s.value, s.level), ('compound', SettingLevel.tenant));
    });

    test('plan default null also inherits', () {
      final s = SettingsResolver(
        const [],
        planDefaults: {'interest.method': null},
      ).resolve('interest.method');
      expect(s.level, SettingLevel.system);
    });
  });

  group('invalid stored values are ignored, never used', () {
    test('wrong type at party level → business value', () {
      final s = SettingsResolver([
        row(SettingScope.tenant, 'mandi.commission_pct', '2'),
        row(SettingScope.party, 'mandi.commission_pct', true, ram),
      ]).resolve('mandi.commission_pct', partyId: ram);
      expect((s.value, s.level), ('2', SettingLevel.tenant));
    });

    test('unknown choice from a newer app version → default', () {
      final s = SettingsResolver([
        row(SettingScope.tenant, 'interest.method', 'continuous'),
      ]).resolve('interest.method');
      expect((s.value, s.level), ('simple', SettingLevel.system));
    });
  });

  group('per-crop keys: level first, crop before generic within a level', () {
    test('party general commission beats the business wheat rate', () {
      // The example agreed for the domain doc: Ram Singh pays 2% on wheat.
      final s = SettingsResolver([
        row(SettingScope.tenant, 'mandi.commission_pct.wheat', '2.5'),
        row(SettingScope.party, 'mandi.commission_pct', '2', ram),
      ]).resolve('mandi.commission_pct.wheat', partyId: ram);
      expect(s.value, '2');
      expect(s.level, SettingLevel.party);
      expect(s.matchedKey, 'mandi.commission_pct');
    });

    test('within one level the crop key wins', () {
      final s = SettingsResolver([
        row(SettingScope.tenant, 'mandi.commission_pct', '2'),
        row(SettingScope.tenant, 'mandi.commission_pct.wheat', '2.5'),
      ]).resolve('mandi.commission_pct.wheat');
      expect(s.value, '2.5');
      expect(s.matchedKey, 'mandi.commission_pct.wheat');
    });

    test('other crops fall back to the generic value', () {
      final s = SettingsResolver([
        row(SettingScope.tenant, 'mandi.commission_pct', '2'),
        row(SettingScope.tenant, 'mandi.commission_pct.wheat', '2.5'),
      ]).resolve('mandi.commission_pct.paddy');
      expect((s.value, s.matchedKey), ('2', 'mandi.commission_pct'));
    });

    test('plan crop default beats plan generic default', () {
      final s = SettingsResolver(
        const [],
        planDefaults: {
          'mandi.commission_pct': '2',
          'mandi.commission_pct.cotton': '1.5',
        },
      ).resolve('mandi.commission_pct.cotton');
      expect((s.value, s.level), ('1.5', SettingLevel.plan));
    });

    test('with nothing set: the generic system default', () {
      final s = SettingsResolver(
        const [],
      ).resolve('mandi.commission_pct.cotton');
      expect((s.value, s.level), ('2.5', SettingLevel.system));
    });

    test('a lot row for this lot beats everything', () {
      final s = SettingsResolver([
        row(SettingScope.party, 'mandi.commission_pct.wheat', '2', ram),
        row(SettingScope.lot, 'mandi.commission_pct', '1.75', lot),
      ]).resolve('mandi.commission_pct.wheat', partyId: ram, documentId: lot);
      expect((s.value, s.level), ('1.75', SettingLevel.document));
    });
  });

  test('suffix-specific system defaults', () {
    final r = SettingsResolver(const []);
    expect(r.resolve('shop.default_tier_for_role.vendor').value, 'vendor');
    expect(r.resolve('shop.default_tier_for_role.buyer').value, 'retail');
  });

  test('unknown keys are a programming error', () {
    expect(
      () => SettingsResolver(const []).resolve('interest.typo'),
      throwsArgumentError,
    );
  });

  test('typed readers', () {
    final r = SettingsResolver([
      row(SettingScope.tenant, 'interest.rate_pa', '13.5'),
    ]);
    expect(r.resolve('interest.rate_pa').asDecimal.toString(), '13.5');
    expect(r.resolve('interest.enabled').asBool, isTrue);
    expect(r.resolve('interest.day_basis').asInt, 365);
    expect(r.resolve('interest.method').asString, 'simple');
    expect(r.resolve('mandi.palledari_per_bag').asMoney, const Money(1200));
  });
}
