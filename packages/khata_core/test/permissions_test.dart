import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('role defaults (docs/domain/ledger-and-mandi.md)', () {
    const accountant = {
      Permission.partiesManage,
      Permission.arrivalsManage,
      Permission.paymentsCreate,
      Permission.entriesReverse,
      Permission.financeView,
    };
    const munshi = {
      Permission.partiesManage,
      Permission.arrivalsManage,
      Permission.paymentsCreate,
    };

    for (final p in Permission.values) {
      test(p.key, () {
        expect(MemberRole.owner.allows(p), isTrue);
        expect(MemberRole.accountant.allows(p), accountant.contains(p));
        expect(MemberRole.munshi.allows(p), munshi.contains(p));
        expect(MemberRole.custom.allows(p), isFalse);
      });
    }
  });

  group('hasPermission', () {
    test('custom entries override the role default', () {
      expect(
        hasPermission(MemberRole.munshi, const {
          'finance.view': true,
        }, Permission.financeView),
        isTrue,
      );
      expect(
        hasPermission(MemberRole.accountant, const {
          'entries.reverse': false,
        }, Permission.entriesReverse),
        isFalse,
      );
    });

    test('a custom role starts with nothing', () {
      expect(
        hasPermission(MemberRole.custom, const {}, Permission.partiesManage),
        isFalse,
      );
      expect(
        hasPermission(MemberRole.custom, const {
          'parties.manage': true,
        }, Permission.partiesManage),
        isTrue,
      );
    });

    test('owners cannot be locked out', () {
      expect(
        hasPermission(MemberRole.owner, const {
          'admin.manage': false,
        }, Permission.adminManage),
        isTrue,
      );
    });

    test('non-boolean entries are ignored (like the SQL)', () {
      expect(
        hasPermission(MemberRole.munshi, const {
          'finance.view': 'yes',
        }, Permission.financeView),
        isFalse,
      );
    });
  });

  test('keys round-trip', () {
    for (final p in Permission.values) {
      expect(Permission.fromKey(p.key), p);
    }
    expect(Permission.fromKey('nope'), isNull);
    expect(MemberRole.parse('munshi'), MemberRole.munshi);
    expect(MemberRole.parse('superuser'), MemberRole.custom);
  });

  group('canWriteSetting (mirrors private.can_write_setting)', () {
    bool Function(Permission) grants(Set<Permission> perms) => perms.contains;

    test('business-wide keys need settings.manage', () {
      expect(
        canWriteSetting(
          'mandi.commission_pct',
          SettingScope.tenant,
          grants({Permission.settingsManage}),
        ),
        isTrue,
      );
      expect(
        canWriteSetting(
          'mandi.commission_pct',
          SettingScope.tenant,
          grants({}),
        ),
        isFalse,
      );
      expect(
        canWriteSetting(
          'mandi.commission_pct',
          SettingScope.partyGroup,
          grants({}),
        ),
        isFalse,
      );
    });

    test('party / document keys need only membership', () {
      expect(
        canWriteSetting('mandi.commission_pct', SettingScope.party, grants({})),
        isTrue,
      );
      expect(
        canWriteSetting(
          'mandi.commission_pct.wheat',
          SettingScope.lot,
          grants({}),
        ),
        isTrue,
      );
    });

    test('interest keys need loans.manage at every level', () {
      expect(
        canWriteSetting('interest.rate_pa', SettingScope.party, grants({})),
        isFalse,
      );
      expect(
        canWriteSetting(
          'interest.rate_pa',
          SettingScope.tenant,
          grants({Permission.settingsManage}),
        ),
        isFalse,
      );
      expect(
        canWriteSetting(
          'interest.rate_pa',
          SettingScope.party,
          grants({Permission.loansManage}),
        ),
        isTrue,
      );
      expect(
        canWriteSetting(
          'interest.rate_pa',
          SettingScope.tenant,
          grants({Permission.loansManage, Permission.settingsManage}),
        ),
        isTrue,
      );
    });
  });
}
