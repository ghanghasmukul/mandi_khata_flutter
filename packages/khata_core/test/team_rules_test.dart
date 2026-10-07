import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('validateInvite', () {
    test('normalises a typed number to 91 + 10 digits', () {
      final (draft, error) = TeamRules.validateInvite(
        phone: '+91 98140-22110',
        role: MemberRole.munshi,
      );
      expect(error, isNull);
      expect(draft!.phone, '919814022110');
      expect(draft.role, MemberRole.munshi);
    });

    test('rejects a bad number', () {
      final (draft, error) = TeamRules.validateInvite(
        phone: '12345',
        role: MemberRole.munshi,
      );
      expect(draft, isNull);
      expect(error, InviteError.phone);
    });

    test('owners cannot be invited', () {
      final (_, error) = TeamRules.validateInvite(
        phone: '9814022110',
        role: MemberRole.owner,
      );
      expect(error, InviteError.role);
    });

    test('custom role is allowed', () {
      final (draft, _) = TeamRules.validateInvite(
        phone: '9814022110',
        role: MemberRole.custom,
      );
      expect(draft!.role, MemberRole.custom);
    });
  });

  test('displayPhone groups 5 + 5', () {
    expect(TeamRules.displayPhone('919814022110'), '98140 22110');
    expect(TeamRules.displayPhone('+919814022110'), '98140 22110');
    expect(TeamRules.displayPhone('abc'), 'abc');
  });

  group('permission grid', () {
    test('munshi default grid, no overrides', () {
      expect(TeamRules.effective(MemberRole.munshi, const {}), {
        Permission.partiesManage,
        Permission.arrivalsManage,
        Permission.paymentsCreate,
        Permission.salesCreate,
      });
    });

    test('overrides add and remove', () {
      final eff = TeamRules.effective(MemberRole.munshi, const {
        'entries.reverse': true,
        'payments.create': false,
      });
      expect(eff, contains(Permission.entriesReverse));
      expect(eff, isNot(contains(Permission.paymentsCreate)));
    });

    test('owner always holds everything', () {
      expect(
        TeamRules.effective(MemberRole.owner, const {'admin.manage': false}),
        Permission.values.toSet(),
      );
    });

    test('overridesFor stores only differences from the role default', () {
      final granted = {
        Permission.partiesManage,
        Permission.arrivalsManage,
        Permission.salesCreate,
        Permission.entriesReverse, // extra
        // payments.create removed
      };
      expect(TeamRules.overridesFor(MemberRole.munshi, granted), {
        'payments.create': false,
        'entries.reverse': true,
      });
    });

    test('overridesFor round-trips through effective', () {
      for (final role in [
        MemberRole.accountant,
        MemberRole.munshi,
        MemberRole.custom,
      ]) {
        final want = {Permission.auditView, Permission.financeView};
        final stored = TeamRules.overridesFor(role, want);
        expect(TeamRules.effective(role, stored), want, reason: role.name);
      }
    });

    test('custom role stores only true keys', () {
      expect(
        TeamRules.overridesFor(MemberRole.custom, {Permission.partiesManage}),
        {'parties.manage': true},
      );
    });

    test('owner stores nothing', () {
      expect(
        TeamRules.overridesFor(MemberRole.owner, {Permission.auditView}),
        isEmpty,
      );
    });
  });

  group('keepsAnOwner', () {
    test('false when the only owner is changed', () {
      expect(TeamRules.keepsAnOwner(['a'], 'a'), isFalse);
    });
    test('true with another owner', () {
      expect(TeamRules.keepsAnOwner(['a', 'b'], 'a'), isTrue);
    });
    test('true when someone else is changed', () {
      expect(TeamRules.keepsAnOwner(['a'], 'x'), isTrue);
    });
  });
}
