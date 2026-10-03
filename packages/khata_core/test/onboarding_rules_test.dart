import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('needsOnboarding', () {
    bool needs({
      MemberRole role = MemberRole.owner,
      String status = 'not_started',
      bool parties = false,
      bool entries = false,
      bool synced = true,
    }) => OnboardingRules.needsOnboarding(
      role: role,
      status: status,
      hasParties: parties,
      hasEntries: entries,
      synced: synced,
    );

    test('a brand-new business, owner, synced: yes', () {
      expect(needs(), isTrue);
    });
    test('never before the first sync finished', () {
      expect(needs(synced: false), isFalse);
    });
    test('only the owner', () {
      expect(needs(role: MemberRole.accountant), isFalse);
      expect(needs(role: MemberRole.munshi), isFalse);
    });
    test('a business that already has parties or entries is left alone', () {
      expect(needs(parties: true), isFalse);
      expect(needs(entries: true), isFalse);
    });
    test('completed and skipped never reopen by themselves', () {
      expect(needs(status: 'completed'), isFalse);
      expect(needs(status: 'skipped'), isFalse);
    });
    test('a half-done wizard resumes even after it created parties', () {
      expect(needs(status: 'in_progress', parties: true), isTrue);
    });
  });

  test('resume clamps the stored step', () {
    expect(OnboardingRules.resume(0), OnboardingStep.business);
    expect(OnboardingRules.resume(3), OnboardingStep.charges);
    expect(OnboardingRules.resume(99), OnboardingStep.invite);
    expect(OnboardingRules.resume(-4), OnboardingStep.business);
  });

  test('home states come first, codes are GST codes', () {
    expect(OnboardingRules.states.take(3).map((s) => s.code), [
      '03',
      '06',
      '08',
    ]);
    expect(OnboardingRules.stateByCode('03')!.nameIn('hi'), 'पंजाब');
    expect(OnboardingRules.stateByCode('99'), isNull);
    final codes = OnboardingRules.states.map((s) => s.code).toList();
    expect(codes.toSet(), hasLength(codes.length));
  });

  group('BusinessDetails', () {
    test('name is required; GSTIN and phone are checked when given', () {
      expect(const BusinessDetails(name: ' ').validate(), {
        BusinessField.name: FieldProblem.required,
      });
      expect(
        const BusinessDetails(
          name: 'Sandhu Traders',
          gstin: '27AAPFU0939F1ZW',
          phone: '12345',
        ).validate(),
        {
          BusinessField.gstin: FieldProblem.invalid,
          BusinessField.phone: FieldProblem.invalid,
        },
      );
    });

    test('columns are trimmed, blanks are null, numbers canonical', () {
      final c = const BusinessDetails(
        name: '  Sandhu   Traders ',
        gstin: '27aapfu0939f1zv',
        phone: '+91 98140-22110',
        address: '  ',
      ).columns();
      expect(c, {
        'name': 'Sandhu Traders',
        'legal_name': null,
        'gstin': '27AAPFU0939F1ZV',
        'address': null,
        'phone': '9814022110',
      });
    });
  });

  group('ChargeDefaults -> settings', () {
    test('worked example: 2.5% / ₹12 / ₹8 / ₹3 / 1% / 50 kg', () {
      final r = const ChargeDefaults(
        commissionPct: '2.50',
        palledariPerBag: '12',
        bardanaPerBag: '8.00',
        tulaiPerQtl: '3',
        mandiFeePct: '1',
        bagWeightKg: '50',
      ).toSettings();
      expect(r.problems, isEmpty);
      expect(r.values, {
        'mandi.commission_pct': '2.5',
        'mandi.palledari_per_bag': 1200,
        'mandi.bardana_per_bag': 800,
        'mandi.tulai_per_qtl': 300,
        'mandi.mandi_fee_pct': '1',
        'mandi.bag_weight_kg': '50',
      });
    });

    test('paise survive exactly, never through a double', () {
      final r = const ChargeDefaults(
        commissionPct: '2',
        palledariPerBag: '12.55',
        bardanaPerBag: '0.10',
        tulaiPerQtl: '2.5',
        mandiFeePct: '2',
        bagWeightKg: '49.5',
      ).toSettings();
      expect(r.values['mandi.palledari_per_bag'], 1255);
      expect(r.values['mandi.bardana_per_bag'], 10);
      expect(r.values['mandi.tulai_per_qtl'], 250);
      expect(r.values['mandi.bag_weight_kg'], '49.5');
    });

    test('bad input is reported by key, not guessed', () {
      final r = const ChargeDefaults(
        commissionPct: '25',
        palledariPerBag: '12.345',
        bardanaPerBag: '-1',
        tulaiPerQtl: 'abc',
        mandiFeePct: '',
        bagWeightKg: '0',
      ).toSettings();
      expect(r.problems, {
        'mandi.commission_pct',
        'mandi.palledari_per_bag',
        'mandi.bardana_per_bag',
        'mandi.tulai_per_qtl',
        'mandi.mandi_fee_pct',
        'mandi.bag_weight_kg',
      });
      expect(r.values, isEmpty);
    });
  });

  group('InterestDefaults -> settings', () {
    test('18% a year, simple', () {
      final r = const InterestDefaults(
        enabled: true,
        rate: '18',
        perHundredPerMonth: false,
        method: 'simple',
        compounding: 'quarterly',
      ).toSettings();
      expect(r.problems, isEmpty);
      expect(r.values, {
        'interest.enabled': true,
        'interest.rate_unit_display': 'pa',
        'interest.method': 'simple',
        'interest.rate_pa': '18',
      });
    });

    test('₹1.5 per 100 per month is stored as 18% a year', () {
      final r = const InterestDefaults(
        enabled: true,
        rate: '1.5',
        perHundredPerMonth: true,
        method: 'compound',
        compounding: 'halfyearly',
      ).toSettings();
      expect(r.values['interest.rate_pa'], '18');
      expect(r.values['interest.rate_unit_display'], 'per100_per_month');
      expect(r.values['interest.method'], 'compound');
      expect(r.values['interest.compounding'], 'halfyearly');
    });

    test('a rate over 100% or not a number is a problem', () {
      expect(
        const InterestDefaults(
          enabled: true,
          rate: '9',
          perHundredPerMonth: true,
          method: 'simple',
          compounding: 'monthly',
        ).toSettings().problems,
        {'interest.rate_pa'},
      );
      expect(
        const InterestDefaults(
          enabled: true,
          rate: 'x',
          perHundredPerMonth: false,
          method: 'simple',
          compounding: 'monthly',
        ).toSettings().problems,
        {'interest.rate_pa'},
      );
    });
  });

  test('onboarding settings keys exist, are hidden and business-only', () {
    for (final key in ['onboarding.status', 'onboarding.step']) {
      final def = SettingsSchema.parse(key)!.def;
      expect(def.hidden, isTrue);
      expect(def.businessOnly, isTrue);
    }
    expect(
      SettingsSchema.visible.any((d) => d.key.startsWith('onboarding.')),
      isFalse,
    );
    expect(
      SettingsSchema.parse('onboarding.status')!.def.validate('completed'),
      isNull,
    );
    expect(
      SettingsSchema.parse('onboarding.status')!.def.validate('done'),
      SettingError.notAllowed,
    );
  });
}
