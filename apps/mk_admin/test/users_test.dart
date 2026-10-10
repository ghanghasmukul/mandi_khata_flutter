import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_admin/src/access_catalog.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/user_access_dialog.dart';
import 'package:mk_admin/src/users_screen.dart';
import 'package:mk_ui/mk_ui.dart';

class FakeApi implements AdminApi {
  FakeApi(this.responses);

  final Map<String, Object?> responses;
  final List<({String action, Map<String, Object?> params})> calls = [];

  @override
  Future<Object?> call(
    String action, [
    Map<String, Object?> params = const {},
  ]) async {
    calls.add((action: action, params: params));
    return responses[action];
  }

  Map<String, Object?> last(String action) =>
      calls.lastWhere((c) => c.action == action).params;
}

Widget app(FakeApi api, Widget home) => ProviderScope(
  overrides: [adminApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    theme: MkTheme.light(),
    home: Scaffold(body: home),
  ),
);

Map<String, Object?> user({
  String role = 'munshi',
  Map<String, Object?>? custom,
}) => {
  'user_id': 'u1',
  'email': 'ram@shop.test',
  'full_name': 'Ram Lal',
  'phone': '919814022110',
  'created_at': '2027-01-01T00:00:00Z',
  'last_sign_in_at': null,
  'is_banned': false,
  'is_platform_admin': false,
  'memberships': [
    {
      'tenant_id': 't1',
      'tenant_name': 'Gupta Trading',
      'role': role,
      'is_active': true,
      'custom_permissions': custom ?? <String, Object?>{},
      'device_limit': 5,
    },
  ],
};

void main() {
  test('every permission appears in exactly one group', () {
    final keys = [
      for (final g in featureGroups)
        for (final f in g.features) f.permission,
    ];
    expect(keys.toSet(), Permission.values.toSet());
    expect(keys.length, Permission.values.length);
  });

  test('effective access = override, else role', () {
    expect(effective(MemberRole.munshi, {}, Permission.paymentsCreate), isTrue);
    expect(
      effective(MemberRole.munshi, {
        'payments.create': false,
      }, Permission.paymentsCreate),
      isFalse,
    );
    expect(
      effective(MemberRole.munshi, {
        'finance.view': true,
      }, Permission.financeView),
      isTrue,
    );
    expect(effective(MemberRole.custom, {}, Permission.partiesManage), isFalse);
    expect(Access.of({'a': true}, 'a'), Access.allow);
    expect(Access.of({'a': false}, 'a'), Access.deny);
    expect(Access.of({}, 'a'), Access.byRole);
  });

  testWidgets('the list shows people with their businesses', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 1000);
    addTearDown(tester.view.reset);
    final api = FakeApi({
      'users_list': [
        user(),
        {
          ...user(),
          'user_id': 'u2',
          'email': 'x@y.test',
          'full_name': '',
          'memberships': <Object>[],
        },
      ],
    });
    await tester.pumpWidget(app(api, const UsersScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Ram Lal'), findsOneWidget);
    expect(find.text('Gupta Trading · munshi'), findsOneWidget);
    expect(find.text('no business'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('user-search')), 'ram');
    await tester.pumpAndSettle();
    expect(find.text('x@y.test'), findsNothing);
  });

  testWidgets('create user sends the form and shows the password once', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 1000);
    addTearDown(tester.view.reset);
    final api = FakeApi({
      'users_list': <Object>[],
      'businesses_brief': [
        {'id': 't1', 'name': 'Gupta Trading'},
      ],
      'user_create': {
        'user_id': 'u9',
        'email': 'new@shop.test',
        'password': 'Abc12345xyz',
      },
    });
    await tester.pumpWidget(app(api, const UsersScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('user-create')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('new-name')),
      'New Person',
    );
    await tester.enterText(
      find.byKey(const ValueKey('new-email')),
      'new@shop.test',
    );
    await tester.tap(find.byKey(const ValueKey('new-business')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gupta Trading').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-save')));
    await tester.pumpAndSettle();
    final sent = api.last('user_create');
    expect(sent['email'], 'new@shop.test');
    expect(sent['tenant_id'], 't1');
    expect(sent['role'], 'munshi');
    expect(find.byKey(const ValueKey('shown-password')), findsOneWidget);
    expect(find.text('Abc12345xyz'), findsOneWidget);
  });

  testWidgets('switching a feature off saves exactly that override', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 1200);
    addTearDown(tester.view.reset);
    final api = FakeApi({
      'member_set_access': {
        'role': 'munshi',
        'custom_permissions': {'payments.create': false},
        'is_active': true,
        'device_limit': 5,
      },
    });
    await tester.pumpWidget(app(api, UserAccessDialog(user: user())));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('access-save')))
          .onPressed,
      isNull,
      reason: 'nothing to save yet',
    );
    final row = find.byKey(const ValueKey('feature-payments.create'));
    await tester.ensureVisible(row);
    await tester.tap(find.descendant(of: row, matching: find.text('Deny')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('access-save')));
    await tester.pumpAndSettle();
    final sent = api.last('member_set_access');
    expect(sent['tenant_id'], 't1');
    expect(sent['user_id'], 'u1');
    expect(sent['custom_permissions'], {'payments.create': false});
    expect(sent['role'], 'munshi');
  });

  testWidgets('an owner cannot be limited', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 1200);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(FakeApi({}), UserAccessDialog(user: user(role: 'owner'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('An owner always has every feature.'), findsOneWidget);
    expect(find.byKey(const ValueKey('preset-all')), findsNothing);
  });

  testWidgets('presets: allow none writes a deny for every feature', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 1200);
    addTearDown(tester.view.reset);
    final api = FakeApi({
      'member_set_access': {
        'role': 'munshi',
        'custom_permissions': <String, Object?>{},
        'is_active': true,
        'device_limit': 5,
      },
    });
    await tester.pumpWidget(app(api, UserAccessDialog(user: user())));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('preset-none')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('access-save')));
    await tester.pumpAndSettle();
    final sent = api.last('member_set_access')['custom_permissions']! as Map;
    expect(sent.length, Permission.values.length);
    expect(sent.values.every((v) => v == false), isTrue);
  });
}
