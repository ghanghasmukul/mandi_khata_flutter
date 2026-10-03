import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/audit/data/audit_repository.dart';
import 'package:mandi_khata_app/features/audit/domain/audit_entry.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_labels.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_providers.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

AuditEntry _entry(
  String id,
  String table,
  String action, {
  Map<String, Object?>? before,
  Map<String, Object?>? after,
  String user = 'Rajinder',
  String? role = 'munshi',
  String? device = 'A1',
  String? subject,
}) => AuditEntry(
  id: id,
  table: table,
  rowId: 'row-$id',
  action: action,
  before: before,
  after: after,
  kind: AuditRules.classify(
    table: table,
    action: action,
    before: before,
    after: after,
  ),
  userName: user,
  role: role,
  deviceCode: device,
  subject: subject,
  createdAt: DateTime(2026, 10, 3, 10, 30),
);

class FakeAuditRepository implements AuditRepository {
  final seen = <AuditFilter>[];
  final List<AuditEntry> entries = [
    _entry(
      'e1',
      'ledger_entries',
      'reverse',
      before: {'amount_paise': 1555800},
      after: {'amount_paise': 1555800},
      subject: 'Gurmeet Singh',
    ),
    _entry(
      'e2',
      'lots',
      'update',
      before: {'gross': 100000, 'note': 'a'},
      after: {'gross': 120000, 'note': 'b'},
      user: 'Naresh Gupta',
      role: 'owner',
      device: 'W1',
      subject: 'L-W1-0007',
    ),
    _entry(
      'e3',
      'parties',
      'insert',
      after: {'name': 'Gurmeet Singh'},
      subject: 'Gurmeet Singh',
    ),
    _entry(
      'e4',
      'tenant_members',
      'update',
      before: {'role': 'munshi'},
      after: {'role': 'accountant'},
      user: 'Naresh Gupta',
      role: 'owner',
      device: null,
    ),
  ];

  @override
  Stream<List<AuditEntry>> watch(
    String tenantId,
    AuditFilter filter, {
    int limit = 100,
  }) {
    seen.add(filter);
    final out = [
      for (final e in entries)
        if ((filter.table == null || filter.table == e.table) &&
            (!filter.onlyHighlighted || e.highlighted))
          e,
    ];
    return Stream.value(out);
  }

  @override
  Stream<List<({String id, String name})>> watchWriters(String tenantId) =>
      Stream.value([
        (id: 'u1', name: 'Naresh Gupta'),
        (id: 'u2', name: 'Rajinder'),
      ]);
}

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

void main() {
  late FakeAuditRepository repo;
  setUp(() => repo = FakeAuditRepository());

  Future<void> pump(
    WidgetTester tester, {
    MemberRole role = MemberRole.owner,
  }) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          auditRepositoryProvider.overrideWith((ref) async => repo),
          activeTenantProvider.overrideWith(_FixedTenant.new),
          activeMembershipProvider.overrideWithValue(
            Membership(tenantId: 't1', tenantName: 'Gupta', role: role),
          ),
          syncIndicatorProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AuditScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('only the owner sees the log', (tester) async {
    await pump(tester, role: MemberRole.munshi);
    expect(find.text('Only the owner can see the audit log.'), findsOneWidget);
    expect(repo.seen, isEmpty);
  });

  testWidgets('timeline: who, role, device, what, before → after', (
    tester,
  ) async {
    await pump(tester);
    // Reversal and money edit are badged; plain entries are not.
    expect(find.text('Reversal'), findsOneWidget);
    expect(find.text('Amount changed'), findsOneWidget);
    expect(find.text('Reversed · Khata entry · Gurmeet Singh'), findsOneWidget);
    expect(find.text('Rajinder · Munshi · device A1'), findsWidgets);
    expect(find.text('Naresh Gupta · Owner · device W1'), findsOneWidget);
    // Money shown as rupees, before struck through then after.
    expect(find.text('₹15,558'), findsWidgets);
    expect(find.text('₹1,000'), findsOneWidget);
    expect(find.text('₹1,200'), findsOneWidget);
    // Role change in words.
    expect(find.text('Munshi'), findsWidgets);
    expect(find.text('Accountant'), findsWidgets);
  });

  testWidgets('money edits and reversals only', (tester) async {
    await pump(tester);
    expect(find.byKey(const ValueKey('audit-e3')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('audit-only-money')));
    await tester.pumpAndSettle();
    expect(repo.seen.last.onlyHighlighted, isTrue);
    expect(find.byKey(const ValueKey('audit-e3')), findsNothing);
    expect(find.byKey(const ValueKey('audit-e1')), findsOneWidget);
  });

  testWidgets('record type filter', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('audit-filter-table')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lot').last);
    await tester.pumpAndSettle();
    expect(repo.seen.last.table, 'lots');
    expect(find.byKey(const ValueKey('audit-e2')), findsOneWidget);
    expect(find.byKey(const ValueKey('audit-e1')), findsNothing);
  });

  testWidgets('person filter lists the writers', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('audit-filter-user')));
    await tester.pumpAndSettle();
    expect(find.text('Everyone'), findsWidgets);
    await tester.tap(find.text('Rajinder').last);
    await tester.pumpAndSettle();
    expect(repo.seen.last.userId, 'u2');
  });

  testWidgets('date chips filter by day', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('audit-range-today')));
    await tester.pumpAndSettle();
    expect(repo.seen.last.from, isNotNull);
    expect(repo.seen.last.from, repo.seen.last.to);
  });

  testWidgets('empty result', (tester) async {
    repo.entries.clear();
    await pump(tester);
    expect(find.text('No entries match.'), findsOneWidget);
  });

  group('value words', () {
    testWidgets('permissions, booleans, nothing', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (c) {
              l10n = AppLocalizations.of(c);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        l10n.auditValue('custom_permissions', {
          'entries.reverse': true,
          'payments.create': false,
        }),
        'Edit or reverse past entries: Yes, Record payments: No',
      );
      expect(l10n.auditValue('custom_permissions', const {}), '—');
      expect(l10n.auditValue('is_active', false), 'No');
      expect(l10n.auditValue('qtl_milli', 8640), '8.64');
      expect(l10n.auditValue('note', null), '—');
      expect(l10n.auditField('entry_date'), 'Date');
      expect(l10n.auditField('some_new_column'), 'some new column');
    });
  });
}
