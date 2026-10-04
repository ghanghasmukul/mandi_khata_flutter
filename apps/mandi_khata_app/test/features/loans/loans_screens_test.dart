import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_detail_screen.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_screen.dart';
import 'package:mandi_khata_app/features/loans/presentation/rate_input.dart';
import 'package:mandi_khata_app/features/loans/presentation/repayment_dialog.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

class _FakeWriter implements LoanWriter {
  final repaid = <LoanRepaymentDraft>[];

  @override
  Future<LoanResult> repay(LoanRepaymentDraft draft) async {
    repaid.add(draft);
    return const LoanSaved('loan-1', 'KZ-W1-0001');
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('$i');
}

final today = LedgerDate.fromDateTime(DateTime.now());

LedgerEntry entry(String id, Side side, int rupees, LedgerDate date) =>
    LedgerEntry(
      id: id,
      partyId: 'p1',
      entryDate: date,
      side: side,
      amount: Money.rupees(rupees),
      refType: side == Side.udhaar
          ? RefType.loanDisbursal
          : RefType.loanRepayment,
      refId: 'loan-1',
      createdAt: DateTime.utc(2026, 1, 2),
    );

Loan loanOf({LoanStatus status = LoanStatus.active, LedgerDate? due}) => Loan(
  id: 'loan-1',
  loanNo: 'KZ-W1-0001',
  partyId: 'p1',
  partyName: 'Gurmeet Singh',
  partyCode: 'F-1',
  issueDate: today.addDays(-30),
  principal: const Money.rupees(100000),
  dueDate: due ?? today.addDays(60),
  purpose: 'Diesel and seed',
  config: InterestConfig(
    ratePa: Decimal.fromInt(18),
    applyOn: ApplyOn.loansOnly,
    rounding: InterestRounding.paise,
  ),
  status: status,
  closedOn: status == LoanStatus.active ? null : today,
  closeReason: status == LoanStatus.writtenOff ? 'Gone' : null,
  createdAt: DateTime.utc(2026, 1, 2),
);

LoanDetail detailOf({Loan? loan}) => LoanDetail(
  loan: loan ?? loanOf(),
  entries: [
    LoanEntry(entry: entry('e1', Side.udhaar, 100000, today.addDays(-30))),
  ],
  rateChanges: const [],
);

void main() {
  late _FakeWriter writer;

  setUp(() => writer = _FakeWriter());

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    required LoanDetail? detail,
    List<LoanSummary> list = const [],
    bool manage = true,
    bool repay = true,
    bool reverse = true,
    Money partyBalance = Money.zero,
    String route = '/x',
  }) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: route,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(path: '/x', builder: (_, _) => home),
        GoRoute(path: '/loans', builder: (_, _) => const LoansScreen()),
        GoRoute(
          path: '/loans/:id',
          builder: (_, s) => LoanDetailScreen(loanId: s.pathParameters['id']!),
        ),
        GoRoute(path: '/parties/:id', builder: (_, _) => const Text('party')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTenantProvider.overrideWith(_FixedTenant.new),
          loanDetailProvider(
            'loan-1',
          ).overrideWith((ref) => Stream.value(detail)),
          loanListProvider(
            const LoanFilter(),
          ).overrideWith((ref) => Stream.value(list)),
          loanListProvider(
            const LoanFilter(status: LoanStatusFilter.closed),
          ).overrideWith((ref) => Stream.value(const [])),
          loanWriterProvider.overrideWithValue(writer),
          canProvider(Permission.loansManage).overrideWithValue(manage),
          canProvider(Permission.paymentsCreate).overrideWithValue(repay),
          canProvider(Permission.entriesReverse).overrideWithValue(reverse),
          canProvider(Permission.financeView).overrideWithValue(manage),
          partyBalancesProvider.overrideWith(
            (ref) => Stream.value({'p1': partyBalance}),
          ),
          bankAccountListProvider().overrideWith(
            (ref) => Stream.value(const <BankAccount>[]),
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
  }

  Finder key(String k) => find.byKey(ValueKey(k));

  group('loans list', () {
    testWidgets('cards show principal, byaj, payable, recovery and due, '
        'with totals; the owner can issue', (tester) async {
      final d = detailOf();
      final summary = LoanSummary(loan: d.loan, position: d.position(today));
      await pump(
        tester,
        const SizedBox(),
        detail: d,
        list: [summary],
        route: '/loans',
      );
      expect(key('loan-card-loan-1'), findsOneWidget);
      expect(find.text('Gurmeet Singh'), findsOneWidget);
      expect(find.textContaining('KZ-W1-0001'), findsOneWidget);
      expect(find.text('0% recovered'), findsOneWidget);
      expect(find.text('60 days left'), findsOneWidget);
      expect(key('loans-totals'), findsOneWidget);
      expect(key('loans-issue'), findsOneWidget);
    });

    testWidgets('a munshi sees no Issue button; empty state shows', (
      tester,
    ) async {
      await pump(
        tester,
        const SizedBox(),
        detail: null,
        manage: false,
        route: '/loans',
      );
      expect(key('loans-issue'), findsNothing);
      expect(find.text('No loans here yet'), findsOneWidget);
    });
  });

  group('loan detail', () {
    testWidgets('payable today from the engine and the statement table', (
      tester,
    ) async {
      await pump(
        tester,
        const SizedBox(),
        detail: detailOf(),
        route: '/loans/loan-1',
      );
      // 30 days at 18% on 1,00,000 = 1,479.45
      expect(find.text('₹1,01,479.45'), findsWidgets);
      expect(key('loan-statement'), findsOneWidget);
      expect(find.text('Loan given'), findsOneWidget);
      expect(key('loan-repay'), findsOneWidget);
      expect(key('loan-change-rate'), findsOneWidget);
      expect(key('loan-close'), findsOneWidget);
      expect(key('loan-write-off'), findsOneWidget);
    });

    testWidgets('only the owner sees rate / close / write-off; a munshi can '
        'still record a repayment', (tester) async {
      await pump(
        tester,
        const SizedBox(),
        detail: detailOf(),
        manage: false,
        route: '/loans/loan-1',
      );
      expect(key('loan-repay'), findsOneWidget);
      expect(key('loan-change-rate'), findsNothing);
      expect(key('loan-close'), findsNothing);
      expect(key('loan-write-off'), findsNothing);
    });

    testWidgets('a written-off loan has no actions and says so', (
      tester,
    ) async {
      await pump(
        tester,
        const SizedBox(),
        detail: detailOf(loan: loanOf(status: LoanStatus.writtenOff)),
        route: '/loans/loan-1',
      );
      expect(key('loan-repay'), findsNothing);
      expect(key('loan-closed-note'), findsOneWidget);
      expect(find.textContaining('Gone'), findsWidgets);
    });
  });

  group('repayment dialog', () {
    Future<void> open(WidgetTester tester, {Money balance = Money.zero}) async {
      await pump(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showRepaymentDialog(context, 'loan-1'),
              child: const Text('open'),
            ),
          ),
        ),
        detail: detailOf(),
        partyBalance: balance,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the byaj / principal split BEFORE saving', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(
        find.descendant(
          of: key('repay-amount-0'),
          matching: find.byType(TextField),
        ),
        '20000',
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: key('repay-preview-interest'),
          matching: find.textContaining('₹1,479.45'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: key('repay-preview-principal'),
          matching: find.textContaining('₹18,520.55'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('₹81,479.45'), findsWidgets);
      expect(writer.repaid, isEmpty);

      await tester.tap(key('repay-save'));
      await tester.pumpAndSettle();
      expect(writer.repaid.single.amount, const Money.rupees(20000));
      expect(writer.repaid.single.source, RepaymentSource.payment);
    });

    testWidgets('more than is due disables saving and says why', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(
        find.descendant(
          of: key('repay-amount-0'),
          matching: find.byType(TextField),
        ),
        '150000',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('More than the'), findsOneWidget);
      final save = tester.widget<MkButton>(key('repay-save'));
      expect(save.onPressed, isNull);
    });

    testWidgets('Full payable fills the amount', (tester) async {
      await open(tester);
      await tester.tap(key('repay-full'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: key('repay-preview-after'),
          matching: find.textContaining('₹0'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('crop proceeds: shows what is available; over it is refused', (
      tester,
    ) async {
      await open(tester, balance: const Money.rupees(30000));
      await tester.tap(find.text('From crop proceeds'));
      await tester.pumpAndSettle();
      expect(find.textContaining('₹30,000'), findsWidgets);
      await tester.enterText(
        find.descendant(
          of: key('repay-amount-0'),
          matching: find.byType(TextField),
        ),
        '40000',
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('More than the crop proceeds'),
        findsOneWidget,
      );
    });
  });

  group('rate input', () {
    testWidgets('changing the unit converts what is typed and reports % pa', (
      tester,
    ) async {
      Decimal? last;
      await tester.pumpWidget(
        MaterialApp(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RateInput(
              initialPa: Decimal.fromInt(18),
              onChanged: (v) => last = v,
            ),
          ),
        ),
      );
      await tester.tap(key('rate-unit-month'));
      await tester.pumpAndSettle();
      expect(find.text('1.5'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '2');
      expect(last, Decimal.fromInt(24));
      await tester.enterText(find.byType(TextField), '9');
      expect(last, isNull); // 108% a year is not a valid rate
    });
  });
}
