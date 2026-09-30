import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/settings/data/party_options.dart';
import 'package:mandi_khata_app/features/settings/presentation/settings_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../../helpers/fakes.dart';

const tenant = 't-gupta';

/// In-memory settings store with the real validation / permission rules.
class FakeSettingsRepository implements SettingsRepository {
  final rows = <SettingRow>[];
  final _changed = StreamController<void>.broadcast();

  @override
  Stream<List<SettingRow>> watch(
    String tenantId,
    SettingsTarget target,
  ) async* {
    List<SettingRow> matching() => [
      for (final r in rows)
        if (r.scope == SettingScope.tenant ||
            (r.scope == SettingScope.party && r.scopeId == target.partyId))
          r,
    ];
    yield matching();
    await for (final _ in _changed.stream) {
      yield matching();
    }
  }

  @override
  Future<SettingWriteFailure?> write(
    WriteContext ctx, {
    required SettingScope scope,
    required String key,
    required Object? value,
    required bool Function(Permission) can,
    String? scopeId,
    DateTime? now,
  }) async {
    final def = SettingsSchema.parse(key)!.def;
    final error = def.validate(value);
    if (error != null) return InvalidSettingValue(error);
    if (!canWriteSetting(key, scope, can)) return const SettingNotPermitted();
    rows
      ..removeWhere(
        (r) => r.scope == scope && r.scopeId == scopeId && r.key == key,
      )
      ..add(SettingRow(scope: scope, scopeId: scopeId, key: key, value: value));
    _changed.add(null);
    return null;
  }
}

void main() {
  late AppPrefs prefs;
  late FakeSettingsRepository repo;

  setUp(() async {
    prefs = await makePrefs();
    await prefs.setDataOwnerUserId(userA.id);
    await prefs.setLastTenantId(tenant);
    await prefs.setDevice(tenant, (id: 'dev-1', code: 'W1'));
    repo = FakeSettingsRepository();
  });

  Future<void> pump(WidgetTester tester, MemberRole role) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(userA)),
          appPrefsProvider.overrideWithValue(prefs),
          localDataWiperProvider.overrideWithValue(() async {}),
          myMembershipsProvider.overrideWith(
            (ref) => Stream.value([
              Membership(
                tenantId: tenant,
                tenantName: 'Gupta Trading Co.',
                role: role,
              ),
            ]),
          ),
          settingsRepositoryProvider.overrideWith((ref) async => repo),
          partyOptionsProvider.overrideWith(
            (ref) => Stream.value(const [
              (id: 'p-ram', name: 'Ram Singh', village: 'Rampura'),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder tileOf(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(Wrap)).first;

  Finder fieldIn(String label) =>
      find.descendant(of: tileOf(label), matching: find.byType(TextField));

  testWidgets('owner sets a business rate; a party inherits it, then gets '
      'its own', (tester) async {
    await pump(tester, MemberRole.owner);

    // Nothing stored: system default.
    expect(
      find.descendant(
        of: tileOf('Commission (arhat) %'),
        matching: find.textContaining('App default'),
      ),
      findsOneWidget,
    );

    await tester.enterText(fieldIn('Commission (arhat) %'), '2.25');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(repo.rows.single.value, '2.25');
    expect(
      find.descendant(
        of: tileOf('Commission (arhat) %'),
        matching: find.textContaining('Set here'),
      ),
      findsOneWidget,
    );

    // Switch to the party: the business value is inherited.
    await tester.tap(find.byKey(const ValueKey('settings-scope')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ram Singh · Rampura').last);
    await tester.pumpAndSettle();
    expect(find.text('Input shop'), findsNothing);
    expect(
      find.descendant(
        of: tileOf('Commission (arhat) %'),
        matching: find.textContaining('From business setting'),
      ),
      findsOneWidget,
    );

    await tester.enterText(fieldIn('Commission (arhat) %'), '2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final partyRow = repo.rows.firstWhere((r) => r.scope == SettingScope.party);
    expect((partyRow.scopeId, partyRow.value), ('p-ram', '2'));

    // Reset to inherited writes null.
    await tester.tap(
      find.descendant(
        of: tileOf('Commission (arhat) %'),
        matching: find.byTooltip('Reset to inherited'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      repo.rows.firstWhere((r) => r.scope == SettingScope.party).value,
      isNull,
    );
    expect(
      find.descendant(
        of: tileOf('Commission (arhat) %'),
        matching: find.textContaining('From business setting'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('out-of-range values are refused with the limit', (tester) async {
    await pump(tester, MemberRole.owner);
    await tester.enterText(fieldIn('Commission (arhat) %'), '25');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Too large (maximum 20)'), findsOneWidget);
    expect(repo.rows, isEmpty);
  });

  testWidgets('interest rate shows the mandi "per 100 per month" form', (
    tester,
  ) async {
    await pump(tester, MemberRole.owner);
    expect(find.textContaining('= ₹1.5 per 100 per month'), findsOneWidget);
  });

  testWidgets('munshi sees business settings read-only', (tester) async {
    await pump(tester, MemberRole.munshi);
    final field = tester.widget<TextField>(fieldIn('Commission (arhat) %'));
    expect(field.enabled, isFalse);
    expect(
      find.descendant(
        of: tileOf('Interest method'),
        matching: find.textContaining("You don't have permission"),
      ),
      findsOneWidget,
    );
  });
}
