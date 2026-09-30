import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/sync/sync_error_actions.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/diagnostics/presentation/diagnostics_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class FakeActions implements SyncErrorActions {
  final calls = <String>[];
  RetryResult result = RetryResult.requeued;

  @override
  Future<void> discard(String id) async => calls.add('discard:$id');

  @override
  Future<RetryResult> retry(String id) async {
    calls.add('retry:$id');
    return result;
  }
}

void main() {
  late FakeActions actions;

  setUp(() => actions = FakeActions());

  Future<void> pump(WidgetTester tester, MemberRole role) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeMembershipProvider.overrideWithValue(
            Membership(
              tenantId: 't1',
              tenantName: 'Gupta Trading Co.',
              role: role,
            ),
          ),
          activeDeviceProvider.overrideWithValue((id: 'd1', code: 'W1')),
          syncStatusProvider.overrideWith((ref) => const Stream.empty()),
          syncIndicatorProvider.overrideWithValue(null),
          uploadQueueCountProvider.overrideWith((ref) => Stream.value(3)),
          databaseSizeProvider.overrideWith((ref) async => 1536 * 1024),
          syncErrorActionsProvider.overrideWith((ref) async => actions),
          syncErrorsProvider.overrideWith(
            (ref) => Stream.value([
              (
                id: 'e1',
                table: 'parties',
                rowId: 'p1',
                op: 'PATCH',
                code: '42501',
                message: 'new row violates row-level security policy',
                at: DateTime.utc(2026, 9, 30, 10),
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DiagnosticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('owner sees device, queue, size and rejected changes', (
    tester,
  ) async {
    await pump(tester, MemberRole.owner);
    expect(find.text('W1'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1.5 MB'), findsOneWidget);
    expect(find.text('Never'), findsOneWidget);
    expect(find.text('Not connected'), findsOneWidget);
    expect(
      find.text('new row violates row-level security policy'),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(actions.calls, ['retry:e1']);
    expect(find.text('Queued for upload again'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(actions.calls, ['retry:e1', 'discard:e1']);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('a change that cannot be retried says so', (tester) async {
    actions.result = RetryResult.notRetryable;
    await pump(tester, MemberRole.owner);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(
      find.text("This change can't be sent again. Discard it instead."),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('not the owner: nothing shown', (tester) async {
    await pump(tester, MemberRole.accountant);
    expect(find.text('Only the owner can open diagnostics.'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  test('formatBytes', () {
    expect(formatBytes(512), '512 B');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(25 * 1024 * 1024), '25 MB');
  });
}
