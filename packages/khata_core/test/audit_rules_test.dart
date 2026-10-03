import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  AuditKind kind(
    String table,
    String action, {
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  }) => AuditRules.classify(
    table: table,
    action: action,
    before: before,
    after: after,
  );

  group('classify', () {
    test('a reversal of a ledger entry is a highlighted reversal', () {
      final k = kind('ledger_entries', 'reverse');
      expect(k, AuditKind.reversal);
      expect(AuditRules.isHighlighted(k), isTrue);
    });

    test('payment and lot reversals too', () {
      expect(kind('payments', 'reverse'), AuditKind.reversal);
      expect(kind('lots', 'reverse'), AuditKind.reversal);
      expect(kind('cash_bank_entries', 'reverse'), AuditKind.reversal);
    });

    test('changing an amount on a lot is a money edit', () {
      final k = kind(
        'lots',
        'update',
        before: {'gross': 1000},
        after: {'gross': 1200},
      );
      expect(k, AuditKind.moneyEdit);
      expect(AuditRules.isHighlighted(k), isTrue);
    });

    test('editing only a note on a lot is not a money edit', () {
      expect(
        kind('lots', 'update', before: {'note': 'a'}, after: {'note': 'b'}),
        AuditKind.normal,
      );
    });

    test('an unchanged money column is not a money edit', () {
      expect(
        kind(
          'lots',
          'update',
          before: {'gross': 1000, 'note': 'a'},
          after: {'gross': 1000, 'note': 'b'},
        ),
        AuditKind.normal,
      );
    });

    test('inserts of money are normal', () {
      expect(
        kind('ledger_entries', 'insert', after: {'amount_paise': 5}),
        AuditKind.normal,
      );
    });

    test('team and setting tables', () {
      expect(kind('tenant_members', 'update'), AuditKind.team);
      expect(kind('member_invites', 'insert'), AuditKind.team);
      expect(kind('devices', 'update'), AuditKind.team);
      expect(kind('settings', 'update'), AuditKind.setting);
      expect(AuditRules.isHighlighted(AuditKind.team), isFalse);
    });

    test('a reversal on a non-money table is not a money reversal', () {
      expect(kind('parties', 'reverse'), AuditKind.normal);
    });
  });

  group('changedKeys', () {
    test('lists differing keys sorted', () {
      expect(
        AuditRules.changedKeys({'b': 1, 'a': 1, 'c': 2}, {'b': 2, 'a': 1}),
        ['b', 'c'],
      );
    });

    test('insert lists all keys', () {
      expect(AuditRules.changedKeys(null, {'x': 1, 'a': 2}), ['a', 'x']);
    });

    test('compares nested values by content', () {
      expect(
        AuditRules.changedKeys(
          {
            'p': {'a': true},
          },
          {
            'p': {'a': true},
          },
        ),
        isEmpty,
      );
    });
  });

  test('isPaiseColumn', () {
    expect(AuditRules.isPaiseColumn('amount_paise'), isTrue);
    expect(AuditRules.isPaiseColumn('qtl_milli'), isFalse);
  });
}
