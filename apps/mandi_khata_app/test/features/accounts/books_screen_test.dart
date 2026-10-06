import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_backfill.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/books_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'u1',
  deviceId: 'd1',
  deviceCode: 'W1',
);

class _FakeBackfill implements JournalBackfill {
  int runs = 0;

  @override
  Future<BackfillResult> run(
    WriteContext ctx, {
    required bool Function(Permission) can,
    int batchSize = 25,
    void Function(int done, int total)? onProgress,
    DateTime? now,
  }) async {
    runs++;
    onProgress?.call(2, 4);
    return const BackfillDone(
      written: 4,
      problems: ['Lot L-W1-0009: cannot be re-derived'],
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('$i');
}

void main() {
  const missing = BackfillStatus(
    lots: 2,
    payments: 5,
    interest: 1,
    waivers: 0,
    entries: 3,
    reversals: 1,
  );
  const done = BackfillStatus(
    lots: 0,
    payments: 0,
    interest: 0,
    waivers: 0,
    entries: 0,
    reversals: 0,
  );
  const healthy = BooksChecks(
    unbalanced: 0,
    partyDifferences: 0,
    bookDifferences: 0,
  );

  late _FakeBackfill backfill;
  setUp(() => backfill = _FakeBackfill());

  Future<void> pump(
    WidgetTester tester, {
    BackfillStatus status = done,
    BooksChecks checks = healthy,
    bool allowed = true,
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writeContextProvider.overrideWithValue(ctx),
          canProvider(Permission.entriesReverse).overrideWithValue(allowed),
          booksStatusProvider.overrideWith((ref) async => status),
          booksChecksProvider.overrideWith((ref) async => checks),
          journalBackfillProvider.overrideWith((ref) async => backfill),
          syncIndicatorProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, _) => const BooksScreen()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder key(String k) => find.byKey(ValueKey(k));

  testWidgets('everything journalled and tallying says so', (tester) async {
    await pump(tester);
    expect(key('books-all-done'), findsOneWidget);
    expect(key('books-run'), findsNothing);
    for (final k in ['check-balanced', 'check-parties', 'check-books']) {
      expect(
        find.descendant(
          of: key(k),
          matching: find.byIcon(Icons.check_circle_outline),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('missing entries are counted and the run reports its result', (
    tester,
  ) async {
    await pump(tester, status: missing);
    expect(
      find.text('12 documents have no journal entry yet.'),
      findsOneWidget,
    );
    expect(find.textContaining('Lots 2 · Payments 5'), findsOneWidget);

    await tester.tap(key('books-run'));
    await tester.pumpAndSettle();
    expect(backfill.runs, 1);
    expect(find.text('Done: 4 journal entries written.'), findsOneWidget);
    expect(find.textContaining('L-W1-0009'), findsOneWidget);
  });

  testWidgets('differences are named, not hidden', (tester) async {
    await pump(
      tester,
      checks: const BooksChecks(
        unbalanced: 1,
        partyDifferences: 3,
        bookDifferences: 2,
      ),
    );
    expect(find.text('1 journal entries do not balance.'), findsOneWidget);
    expect(
      find.text('3 party accounts differ from the khata.'),
      findsOneWidget,
    );
    expect(
      find.text('2 cash or bank accounts differ from the cash book.'),
      findsOneWidget,
    );
  });

  testWidgets('only an accountant or the owner sees the books', (tester) async {
    await pump(tester, status: missing, allowed: false);
    expect(key('books-not-permitted'), findsOneWidget);
    expect(key('books-run'), findsNothing);
    expect(key('books-checks'), findsNothing);
  });
}
