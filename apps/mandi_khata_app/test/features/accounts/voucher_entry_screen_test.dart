import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/voucher_entry_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'u1',
  deviceId: 'd1',
  deviceCode: 'W1',
);

class _FakeWriter implements AccountsWriter {
  final drafts = <VoucherDraft>[];
  VoucherSaveResult next = const VoucherSaved('v1', 'PY-W1-0001');

  @override
  Future<VoucherSaveResult> save(VoucherDraft draft) async {
    drafts.add(draft);
    return next;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('$i');
}

final chart = Chart(
  groups: const [
    ChartGroup(
      id: 'g-cred',
      code: 'sundry_creditors',
      name: 'Sundry Creditors',
      nature: AccountNature.liability,
    ),
    ChartGroup(
      id: 'g-cash',
      code: 'cash_in_hand',
      name: 'Cash-in-hand',
      nature: AccountNature.asset,
    ),
  ],
  accounts: const [
    ChartEntry(
      id: 'a-farmer',
      name: 'Gurmeet Singh',
      groupId: 'g-cred',
      account: PartyAccount('farmer'),
      kind: VoucherAccountKind.party,
      code: 'P-1',
    ),
    ChartEntry(
      id: 'a-cash',
      name: 'Cash',
      groupId: 'g-cash',
      account: BookAccount('cash'),
      kind: VoucherAccountKind.cash,
    ),
  ],
);

void main() {
  late _FakeWriter writer;
  setUp(() => writer = _FakeWriter());

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          writeContextProvider.overrideWithValue(ctx),
          chartProvider.overrideWith((ref) => Stream.value(chart)),
          nextVoucherNoProvider.overrideWith((ref, type) async => 'XX-W1-0001'),
          accountsWriterProvider.overrideWithValue(writer),
        ],
        child: MaterialApp.router(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, _) => const VoucherEntryScreen()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pickAccount(WidgetTester tester, int line, String text) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(ValueKey('line-$line-account')),
        matching: find.byType(TextField),
      ),
      text,
    );
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('F-keys switch the voucher type', (tester) async {
    await pump(tester);
    ChoiceChip chip(String type) =>
        tester.widget<ChoiceChip>(find.byKey(ValueKey('type-$type')));
    expect(chip('payment').selected, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.f7);
    await tester.pumpAndSettle();
    expect(chip('sales').selected, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    expect(chip('contra').selected, isTrue);
  });

  testWidgets(
    'Enter walks the fields, a balancing line is offered, Ctrl+Enter saves',
    (tester) async {
      await pump(tester);
      await pickAccount(tester, 0, 'gurm');
      // Enter picked the farmer and moved to the amount.
      await tester.enterText(
        find.byKey(const ValueKey('line-0-amount')),
        '500',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.textContaining('Difference'), findsOneWidget);
      // Line 2 (Cr) got the difference as its amount once an account is picked.
      await pickAccount(tester, 1, 'cash');
      final amount = tester.widget<TextField>(
        find.byKey(const ValueKey('line-1-amount')),
      );
      expect(amount.controller!.text, '500');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('voucher-difference')), findsOneWidget);
      expect(find.text('Balanced'), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      final d = writer.drafts.single;
      expect(d.type, VoucherType.payment);
      expect(
        [for (final l in d.lines) (l.account.id, l.side, l.amount.paise)],
        [('a-farmer', DrCr.dr, 50000), ('a-cash', DrCr.cr, 50000)],
      );
      expect(find.text('Saved PY-W1-0001'), findsOneWidget);
    },
  );

  testWidgets('a refused voucher shows why', (tester) async {
    await pump(tester);
    writer.next = const VoucherInvalid([VoucherProblem.unbalanced]);
    await tester.tap(find.byKey(const ValueKey('voucher-save')));
    await tester.pumpAndSettle();
    expect(find.text('Debit and credit must be equal.'), findsOneWidget);
  });
}
