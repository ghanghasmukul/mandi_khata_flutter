import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchase_entry_screen.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

class _FakeWriter implements PurchaseWriter {
  PurchaseDraft? last;

  @override
  Future<PurchaseResult> create(PurchaseDraft draft) async {
    last = draft;
    return const PurchaseInvalid([PurchaseProblem.noSupplier]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('F2 adds a line; Ctrl+Enter saves and shows the error', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final writer = _FakeWriter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseWriterProvider.overrideWithValue(writer),
          canProvider(Permission.purchasesCreate).overrideWithValue(true),
          canProvider(Permission.financeView).overrideWithValue(true),
          supplierCreditDaysProvider.overrideWithValue(30),
          bankAccountListProvider().overrideWith(
            (ref) => Stream.value(const <BankAccount>[]),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const Scaffold(
                  body: Material(child: PurchaseEntryScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('purchase-batch-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('purchase-batch-1')), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('purchase-batch-1')), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(writer.last, isNotNull);
    expect(find.text('Choose a supplier'), findsOneWidget);
  });
}
