import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/bank_accounts_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_detail_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/record_payment_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../khata/fake_ledger_repository.dart';
import '../parties/parties_screens_test.dart' show FakePartiesRepository;
import '../settings/settings_screen_test.dart' show FakeSettingsRepository;
import 'fake_payments_repository.dart';

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'u1',
  deviceId: 'd1',
  deviceCode: 'W1',
);

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

const gurmeet = Party(
  id: 'p-gurmeet',
  code: 'F-1',
  name: 'Gurmeet Singh',
  roles: {PartyRole.farmer},
  village: 'Bhucho',
);

final today = LedgerDate.fromDateTime(DateTime.now());

Payment chequePayment({
  ChequeStatus status = ChequeStatus.pending,
  PaymentStatus state = PaymentStatus.posted,
}) => Payment(
  id: 'pay-cheque',
  receiptNo: 'V-W1-0003',
  entryDate: today,
  partyId: gurmeet.id,
  partyName: gurmeet.name,
  partyCode: gurmeet.code,
  direction: PaymentDirection.toParty,
  mode: PaymentMode.cheque,
  amount: const Money.rupees(20000),
  bankAccountId: 'bank-1',
  accountName: 'SBI Current',
  chequeNo: '004512',
  chequeDate: today,
  chequeStatus: status,
  status: state,
  createdAt: DateTime.utc(2026, 4, 10),
);

void main() {
  late FakePaymentsRepository payments;
  late FakeBankAccountsRepository accounts;
  late FakeLedgerRepository ledger;

  setUp(() {
    payments = FakePaymentsRepository();
    accounts = FakeBankAccountsRepository()
      ..accounts.add(
        const BankAccount(
          id: 'bank-1',
          kind: AccountKind.bank,
          name: 'SBI Current',
          last4: '7890',
          isActive: true,
        ),
      );
    // We owe Gurmeet ₹10,000 (a posted lot).
    ledger = FakeLedgerRepository()
      ..add(gurmeet.id, '2026-04-09', Side.jama, 10000);
  });

  Future<GoRouter> pump(
    WidgetTester tester,
    String start, {
    MemberRole role = MemberRole.owner,
    Size size = const Size(1400, 1600),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    showRecordPaymentDialog(context, party: gurmeet),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/payments',
          builder: (_, _) => const PaymentsScreen(),
          routes: [
            GoRoute(
              path: 'accounts',
              builder: (_, _) => const BankAccountsScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, s) =>
                  PaymentDetailScreen(paymentId: s.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(path: '/parties/:id', builder: (_, _) => const Text('party')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentsRepositoryProvider.overrideWith((ref) async => payments),
          bankAccountsRepositoryProvider.overrideWith((ref) async => accounts),
          ledgerRepositoryProvider.overrideWith((ref) async => ledger),
          partiesRepositoryProvider.overrideWith(
            (ref) async => FakePartiesRepository()..parties.add(gurmeet),
          ),
          settingsRepositoryProvider.overrideWith(
            (ref) async => FakeSettingsRepository(),
          ),
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

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder key(String k) => find.byKey(ValueKey(k));

  /// Saving awaits the repository provider and a stream; let those finish
  /// (they need event-loop turns, which a bare pumpAndSettle does not give).
  Future<void> save(WidgetTester tester) async {
    await tester.tap(key('payment-save'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  group('record payment dialog', () {
    testWidgets('shows baki now and after; Full baki fills the amount; saves '
        'and offers the receipt', (tester) async {
      await pump(tester, '/');
      await openDialog(tester);
      expect(find.text('Record payment'), findsWidgets);
      expect(find.text('Baki now'), findsOneWidget);
      expect(find.textContaining('₹10,000'), findsWidgets);
      // No amount yet: no "after".
      expect(key('payment-baki-after'), findsNothing);

      await tester.tap(key('payment-full-baki'));
      await tester.pumpAndSettle();
      expect(key('payment-baki-after'), findsOneWidget);
      expect(
        find.descendant(
          of: key('payment-baki-after'),
          matching: find.textContaining('Settled', findRichText: true),
        ),
        findsOneWidget,
      );

      // A part payment: ₹4,000 leaves ₹6,000 jama.
      await tester.tap(key('payment-quick-1000'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: key('payment-baki-after'),
          matching: find.textContaining('₹9,000', findRichText: true),
        ),
        findsOneWidget,
      );

      await save(tester);
      final d = payments.saved.single;
      expect(d.partyId, gurmeet.id);
      expect(d.direction, PaymentDirection.toParty);
      expect(d.mode, PaymentMode.cash);
      expect(d.amount, const Money.rupees(1000));
      expect(key('payment-saved'), findsOneWidget);
      expect(find.text('Saved as V-W1-0007'), findsOneWidget);
      expect(key('payment-print'), findsOneWidget);
      expect(key('payment-share'), findsOneWidget);
      await tester.tap(key('payment-done'));
      await tester.pumpAndSettle();
      expect(key('payment-saved'), findsNothing);
    });

    testWidgets('a receipt: Full baki is what the party owes us', (
      tester,
    ) async {
      ledger.entries.clear();
      ledger.add(gurmeet.id, '2026-04-09', Side.udhaar, 2500);
      await pump(tester, '/');
      await openDialog(tester);
      await tester.tap(find.text('Received from party'));
      await tester.pumpAndSettle();
      await tester.tap(key('payment-full-baki'));
      await tester.pumpAndSettle();
      await save(tester);
      final d = payments.saved.single;
      expect(d.direction, PaymentDirection.fromParty);
      expect(d.amount, const Money.rupees(2500));
      expect(find.text('Saved as R-W1-0007'), findsOneWidget);
    });

    testWidgets('no Full baki when nothing is due in that direction', (
      tester,
    ) async {
      ledger.entries.clear();
      await pump(tester, '/');
      await openDialog(tester);
      expect(key('payment-full-baki'), findsNothing);
    });

    testWidgets('a munshi can only choose cash', (tester) async {
      await pump(tester, '/', role: MemberRole.munshi);
      await openDialog(tester);
      expect(key('payment-mode-cash'), findsOneWidget);
      expect(key('payment-mode-bank'), findsNothing);
      expect(key('payment-mode-upi'), findsNothing);
      expect(key('payment-mode-cheque'), findsNothing);
    });

    testWidgets('a cheque needs its number and date; the bank account is '
        'chosen automatically when there is one', (tester) async {
      await pump(tester, '/');
      await openDialog(tester);
      await tester.tap(key('payment-quick-5000'));
      await tester.tap(key('payment-mode-cheque'));
      await tester.pumpAndSettle();
      await tester.tap(key('payment-save'));
      await tester.pumpAndSettle();
      expect(payments.saved, isEmpty);
      expect(find.text('Enter the cheque number'), findsOneWidget);
      expect(find.text('Enter the cheque date'), findsOneWidget);
      // One bank account: preselected, so no "choose" error.
      expect(find.text('Choose a bank account'), findsNothing);

      await tester.enterText(
        find.descendant(
          of: key('payment-cheque-no'),
          matching: find.byType(TextField),
        ),
        '004512',
      );
      await tester.tap(key('payment-cheque-date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(key('payment-save'));
      await tester.pumpAndSettle();
      final d = payments.saved.single;
      expect(d.mode, PaymentMode.cheque);
      expect(d.bankAccountId, 'bank-1');
      expect(d.chequeNo, '004512');
      expect(d.chequeDate, isNotNull);
    });

    testWidgets('a refused payment shows why and stays open', (tester) async {
      payments.nextResult = const PaymentNotPermitted(
        Permission.entriesReverse,
        limit: Money.rupees(50000),
      );
      await pump(tester, '/', role: MemberRole.munshi);
      await openDialog(tester);
      await tester.tap(key('payment-quick-500'));
      await tester.tap(key('payment-save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Payments above ₹50,000 need an Accountant or Owner'),
        findsOneWidget,
      );
      expect(key('payment-saved'), findsNothing);
    });
  });

  group('payments list', () {
    Future<void> seed() async {
      payments.payments.addAll([
        chequePayment(),
        Payment(
          id: 'pay-1',
          receiptNo: 'V-W1-0001',
          entryDate: today,
          partyId: gurmeet.id,
          partyName: gurmeet.name,
          direction: PaymentDirection.toParty,
          mode: PaymentMode.cash,
          amount: const Money.rupees(1000),
          bankAccountId: 'cash',
          status: PaymentStatus.posted,
          createdAt: DateTime.utc(2026, 4, 10),
        ),
        Payment(
          id: 'pay-2',
          receiptNo: 'R-W1-0001',
          entryDate: today,
          partyId: 'p-bansal',
          partyName: 'Bansal Traders',
          direction: PaymentDirection.fromParty,
          mode: PaymentMode.upi,
          amount: const Money.rupees(2500),
          bankAccountId: 'bank-1',
          status: PaymentStatus.posted,
          createdAt: DateTime.utc(2026, 4, 10),
        ),
      ]);
    }

    testWidgets('rows, totals, pending-cheque filter, record button', (
      tester,
    ) async {
      await seed();
      await pump(tester, '/payments');
      expect(find.text('V-W1-0003'), findsOneWidget);
      expect(find.text('V-W1-0001'), findsOneWidget);
      expect(find.text('R-W1-0001'), findsOneWidget);
      final totals = key('payments-totals');
      expect(
        find.descendant(of: totals, matching: find.text('₹21,000')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: totals, matching: find.text('₹2,500')),
        findsOneWidget,
      );

      await tester.ensureVisible(key('payments-pending-cheques'));
      await tester.tap(key('payments-pending-cheques'));
      await tester.pumpAndSettle();
      expect(find.text('V-W1-0003'), findsOneWidget);
      expect(find.text('V-W1-0001'), findsNothing);

      expect(find.text('Record payment'), findsOneWidget);
      expect(key('payments-accounts'), findsOneWidget);
    });

    testWidgets('a munshi records but has no bank accounts screen', (
      tester,
    ) async {
      await seed();
      await pump(tester, '/payments', role: MemberRole.munshi);
      expect(find.text('Record payment'), findsOneWidget);
      expect(key('payments-accounts'), findsNothing);
    });

    testWidgets('an empty period says so', (tester) async {
      await pump(tester, '/payments');
      expect(find.text('No payments in this period'), findsOneWidget);
    });

    testWidgets('tapping a row opens the payment', (tester) async {
      await seed();
      await pump(tester, '/payments');
      await tester.tap(find.text('V-W1-0003'));
      await tester.pumpAndSettle();
      expect(find.byType(PaymentDetailScreen), findsOneWidget);
      expect(find.text('004512'), findsOneWidget);
    });
  });

  group('payment detail', () {
    testWidgets('owner clears a pending cheque', (tester) async {
      payments.payments.add(chequePayment());
      await pump(tester, '/payments/pay-cheque');
      expect(key('payment-clear'), findsOneWidget);
      expect(key('payment-bounce'), findsOneWidget);
      expect(key('payment-reverse'), findsOneWidget);
      await tester.tap(key('payment-clear'));
      await tester.pumpAndSettle();
      expect(payments.chequeMoves.single.to, ChequeStatus.cleared);
      expect(find.text('Cheque marked cleared'), findsOneWidget);
    });

    testWidgets('bouncing asks for the date and reverses', (tester) async {
      payments.payments.add(chequePayment());
      await pump(tester, '/payments/pay-cheque');
      await tester.tap(key('payment-bounce'));
      await tester.pumpAndSettle();
      expect(find.text('Cheque bounced?'), findsOneWidget);
      await tester.tap(key('payment-bounce-confirm'));
      await tester.pumpAndSettle();
      final move = payments.chequeMoves.single;
      expect(move.to, ChequeStatus.bounced);
      expect(move.date, today);
      expect(find.text('Cheque bounced; entry reversed'), findsOneWidget);
    });

    testWidgets('a munshi can neither bounce nor reverse', (tester) async {
      payments.payments.add(chequePayment());
      await pump(tester, '/payments/pay-cheque', role: MemberRole.munshi);
      expect(key('payment-clear'), findsOneWidget);
      expect(key('payment-bounce'), findsNothing);
      expect(key('payment-reverse'), findsNothing);
    });

    testWidgets('reversing asks first', (tester) async {
      payments.payments.add(chequePayment(status: ChequeStatus.cleared));
      await pump(tester, '/payments/pay-cheque');
      expect(key('payment-clear'), findsNothing);
      await tester.tap(key('payment-reverse'));
      await tester.pumpAndSettle();
      expect(find.text('Reverse this payment?'), findsOneWidget);
      await tester.tap(key('payment-confirm'));
      await tester.pumpAndSettle();
      expect(payments.reversed, ['pay-cheque']);
    });

    testWidgets('a reversed payment offers no actions', (tester) async {
      payments.payments.add(
        chequePayment(
          status: ChequeStatus.bounced,
          state: PaymentStatus.reversed,
        ),
      );
      await pump(tester, '/payments/pay-cheque');
      expect(key('payment-clear'), findsNothing);
      expect(key('payment-bounce'), findsNothing);
      expect(key('payment-reverse'), findsNothing);
      expect(find.text('Reversed'), findsWidgets);
    });

    testWidgets('a missing payment says so', (tester) async {
      await pump(tester, '/payments/nope');
      expect(find.text('This payment no longer exists'), findsOneWidget);
    });
  });

  group('bank accounts', () {
    testWidgets('lists Cash and banks with balances; owner adds one', (
      tester,
    ) async {
      accounts.balances['cash'] = const Money.rupees(3800);
      await pump(tester, '/payments/accounts');
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('SBI Current · ••7890'), findsOneWidget);
      expect(find.text('₹3,800'), findsOneWidget);

      await tester.tap(key('accounts-add'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: key('account-name'),
          matching: find.byType(TextField),
        ),
        'HDFC Savings',
      );
      await tester.enterText(
        find.descendant(
          of: key('account-last4'),
          matching: find.byType(TextField),
        ),
        '12',
      );
      await tester.tap(key('account-save'));
      await tester.pumpAndSettle();
      expect(accounts.created, isEmpty);
      expect(find.text('Exactly 4 digits'), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: key('account-last4'),
          matching: find.byType(TextField),
        ),
        '1234',
      );
      await tester.tap(key('account-save'));
      await tester.pumpAndSettle();
      expect(accounts.created.single.name, 'HDFC Savings');
      expect(find.text('HDFC Savings · ••1234'), findsOneWidget);
    });

    testWidgets('a munshi cannot add accounts', (tester) async {
      await pump(tester, '/payments/accounts', role: MemberRole.munshi);
      expect(key('accounts-add'), findsNothing);
    });

    testWidgets('a bank account can be switched off', (tester) async {
      await pump(tester, '/payments/accounts');
      await tester.tap(key('account-menu-bank-1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switch off'));
      await tester.pumpAndSettle();
      expect(accounts.toggled.single, (id: 'bank-1', active: false));
    });
  });
}
