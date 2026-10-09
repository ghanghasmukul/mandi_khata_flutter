import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_detail_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_form_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../khata/fake_ledger_repository.dart';

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'u1',
  deviceId: 'd1',
  deviceCode: 'W1',
);

/// In-memory parties with the real validation and permission rules.
class FakePartiesRepository implements PartiesRepository {
  final parties = <Party>[];
  final _changed = StreamController<void>.broadcast();
  var _next = 1;

  /// Like a database watch: listens for changes *before* the first read,
  /// so a paused (hidden) screen never misses one.
  Stream<T> _live<T>(T Function() read) {
    StreamSubscription<void>? changes;
    late final StreamController<T> out;
    out = StreamController<T>(
      onListen: () {
        changes = _changed.stream.listen((_) => out.add(read()));
        out.add(read());
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  @override
  Stream<List<Party>> watchAll(
    String tenantId, {
    String query = '',
    PartyRole? role,
  }) => _live(
    () => [
      for (final p in parties)
        if (p.name.toLowerCase().contains(query.trim().toLowerCase()) &&
            (role == null || p.roles.contains(role)))
          p,
    ],
  );

  @override
  Stream<Party?> watchOne(String tenantId, String id) => _live(() {
    for (final p in parties) {
      if (p.id == id) return p;
    }
    return null;
  });

  @override
  Future<String> previewNextCode(WriteContext ctx) async =>
      formatDocumentNumber('P-', ctx.deviceCode, _next);

  @override
  Future<PartySaveResult> create(
    WriteContext ctx,
    PartyInput input, {
    required bool Function(Permission) can,
    int? maxParties,
    DateTime? now,
  }) async {
    if (!can(Permission.partiesManage)) return const PartyNotPermitted();
    final auto = input.code.trim().isEmpty;
    final errors = input.copyWith(code: auto ? 'X' : null).validate();
    if (errors.isNotEmpty) return PartyInvalid(errors);
    final code = auto
        ? formatDocumentNumber('P-', ctx.deviceCode, _next++)
        : input.code;
    final n = input.copyWith(code: code).normalised();
    final party = Party(
      id: 'id-${parties.length + 1}',
      code: n.code,
      name: n.name,
      roles: n.roles,
      mobile: n.mobile,
      village: n.village,
    );
    parties.add(party);
    _changed.add(null);
    return PartySaved(party.id, party.code);
  }

  @override
  Future<PartySaveResult> update(
    WriteContext ctx,
    String id,
    PartyInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async => const PartyNotFound();

  @override
  Future<PartySaveResult> softDelete(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.masterDelete)) return const PartyNotPermitted();
    parties.removeWhere((p) => p.id == id);
    _changed.add(null);
    return PartySaved(id, 'x');
  }
}

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

void main() {
  late FakePartiesRepository repo;
  final ledger = FakeLedgerRepository();

  setUp(() {
    repo = FakePartiesRepository()
      ..parties.addAll(const [
        Party(
          id: 'p1',
          code: 'F-101',
          name: 'Gurmeet Singh',
          roles: {PartyRole.farmer},
          village: 'Rampura',
          mobile: '9814022110',
          bankName: 'State Bank of India',
          bankAccountMasked: 'XXXXXX4321',
          ifsc: 'SBIN0001234',
        ),
        Party(
          id: 'p2',
          code: 'B-201',
          name: 'Aggarwal Traders',
          roles: {PartyRole.buyer},
          village: 'Mansa',
        ),
      ]);
  });

  Future<GoRouter> pump(
    WidgetTester tester,
    MemberRole role, {
    String start = '/parties',
  }) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/parties',
          builder: (_, _) => const PartiesScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const PartyFormScreen()),
            GoRoute(
              path: ':id',
              builder: (_, s) =>
                  PartyDetailScreen(partyId: s.pathParameters['id']!),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          partiesRepositoryProvider.overrideWith((ref) async => repo),
          ledgerRepositoryProvider.overrideWith((ref) async => ledger),
          activeTenantProvider.overrideWith(_FixedTenant.new),
          writeContextProvider.overrideWithValue(ctx),
          activeMembershipProvider.overrideWithValue(
            Membership(tenantId: 't1', tenantName: 'Gupta', role: role),
          ),
          syncIndicatorProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('list: search and role filter', (tester) async {
    await pump(tester, MemberRole.owner);
    expect(find.text('2 parties'), findsOneWidget);
    expect(find.text('Gurmeet Singh'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('parties-search')), 'agg');
    await tester.pumpAndSettle();
    expect(find.text('1 party'), findsOneWidget);
    expect(find.text('Gurmeet Singh'), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('parties-search')), '');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Farmer'));
    await tester.pumpAndSettle();
    expect(find.text('Gurmeet Singh'), findsOneWidget);
    expect(find.text('Aggarwal Traders'), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('parties-search')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No party matches your search.'), findsOneWidget);
  });

  testWidgets('add a party: validation, then save opens its page', (
    tester,
  ) async {
    await pump(tester, MemberRole.munshi);
    // Ctrl+N opens the form.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('Add party'), findsWidgets);
    expect(find.text('Leave blank for P-W1-0001'), findsOneWidget);

    Finder field(String label) => find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byType(MkTextField),
      ),
      matching: find.byType(TextField),
    );
    await tester.enterText(field('Mobile'), '12345');
    await tester.tap(find.text('Save party'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget); // name
    expect(find.text('Enter a 10-digit mobile number'), findsOneWidget);

    await tester.enterText(field('Name'), 'Harpreet Kaur');
    await tester.enterText(field('Mobile'), '+91 98765 00001');
    await tester.tap(find.text('Save party'));
    await tester.pumpAndSettle();

    expect(repo.parties.last.code, 'P-W1-0001');
    expect(repo.parties.last.mobile, '9876500001');
    // Now on the party page, with its tabs.
    expect(find.text('Harpreet Kaur'), findsWidgets);
    expect(find.text('Khata'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('owner can delete; munshi does not see delete', (tester) async {
    await pump(tester, MemberRole.munshi, start: '/parties/p1');
    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.byTooltip('Delete'), findsNothing);
  });

  testWidgets('bank details need finance.view: a munshi does not see them', (
    tester,
  ) async {
    await pump(tester, MemberRole.munshi, start: '/parties/p1');
    expect(find.text('9814022110'), findsOneWidget);
    expect(find.text('State Bank of India'), findsNothing);
    expect(find.text('XXXXXX4321'), findsNothing);
    expect(find.text('SBIN0001234'), findsNothing);
  });

  testWidgets('bank details are shown to the owner and the accountant', (
    tester,
  ) async {
    for (final role in [MemberRole.owner, MemberRole.accountant]) {
      await pump(tester, role, start: '/parties/p1');
      expect(find.text('State Bank of India'), findsOneWidget, reason: '$role');
      expect(find.text('XXXXXX4321'), findsOneWidget);
      expect(find.text('SBIN0001234'), findsOneWidget);
    }
  });

  testWidgets('owner deletes after confirming', (tester) async {
    await pump(tester, MemberRole.owner, start: '/parties/p1');
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Gurmeet Singh?'), findsOneWidget);
    await tester.tap(find.widgetWithText(MkButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(repo.parties.map((p) => p.id), ['p2']);
    expect(find.text('1 party'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('a custom role without parties.manage cannot add', (
    tester,
  ) async {
    await pump(tester, MemberRole.custom);
    expect(find.text('Add party'), findsNothing);
  });
}
