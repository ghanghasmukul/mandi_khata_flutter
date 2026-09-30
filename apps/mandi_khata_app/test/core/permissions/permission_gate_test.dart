import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';

Membership member(MemberRole role, [Map<String, Object?> custom = const {}]) =>
    Membership(
      tenantId: 't1',
      tenantName: 'Gupta Trading Co.',
      role: role,
      customPermissions: custom,
    );

void main() {
  Future<void> pump(WidgetTester tester, Membership? m) => tester.pumpWidget(
    ProviderScope(
      overrides: [activeMembershipProvider.overrideWithValue(m)],
      child: MaterialApp(
        home: Column(
          children: [
            const PermissionGate(
              permission: Permission.loansManage,
              fallback: Text('no loans'),
              child: Text('issue karza'),
            ),
            PermissionGate(
              permission: Permission.financeView,
              builder: (context, {required allowed}) =>
                  Text('finance ${allowed ? 'on' : 'off'}'),
            ),
          ],
        ),
      ),
    ),
  );

  testWidgets('owner sees everything', (tester) async {
    await pump(tester, member(MemberRole.owner));
    expect(find.text('issue karza'), findsOneWidget);
    expect(find.text('finance on'), findsOneWidget);
  });

  testWidgets('munshi: role defaults hide loans and finance', (tester) async {
    await pump(tester, member(MemberRole.munshi));
    expect(find.text('no loans'), findsOneWidget);
    expect(find.text('finance off'), findsOneWidget);
  });

  testWidgets('custom_permissions override the role', (tester) async {
    await pump(tester, member(MemberRole.munshi, const {'finance.view': true}));
    expect(find.text('finance on'), findsOneWidget);
  });

  testWidgets('no active business: nothing is allowed', (tester) async {
    await pump(tester, null);
    expect(find.text('no loans'), findsOneWidget);
    expect(find.text('finance off'), findsOneWidget);
  });
}
