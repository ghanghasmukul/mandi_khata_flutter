import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/team/data/invite_service.dart';
import 'package:mandi_khata_app/features/team/data/team_repository.dart';
import 'package:mandi_khata_app/features/team/domain/team_models.dart';
import 'package:mandi_khata_app/features/team/presentation/team_providers.dart';
import 'package:mandi_khata_app/features/team/presentation/team_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../../helpers/fakes.dart';

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'user-a',
  deviceId: 'd-owner',
  deviceCode: 'W1',
);

const _owner = TeamMember(
  id: 'm-owner',
  userId: 'user-a',
  fullName: 'Naresh Gupta',
  phone: '919814022110',
  role: MemberRole.owner,
  customPermissions: {},
  isActive: true,
  deviceLimit: 5,
);
const _munshi = TeamMember(
  id: 'm-munshi',
  userId: 'u-munshi',
  fullName: 'Rajinder Kumar',
  phone: '919814022112',
  role: MemberRole.munshi,
  customPermissions: {},
  isActive: true,
  deviceLimit: 5,
);

class FakeTeamRepository implements TeamRepository {
  final members = StreamController<List<TeamMember>>.broadcast();
  final devices = StreamController<List<TeamDevice>>.broadcast();
  final invites = StreamController<List<TeamInvite>>.broadcast();

  List<TeamMember> memberRows = const [_owner, _munshi];
  List<TeamDevice> deviceRows = [
    TeamDevice(
      id: 'd-owner',
      userId: 'user-a',
      userName: 'Naresh Gupta',
      code: 'W1',
      platform: 'windows',
      lastSeenAt: DateTime(2026, 10, 3, 9),
    ),
    const TeamDevice(
      id: 'd-munshi',
      userId: 'u-munshi',
      userName: 'Rajinder Kumar',
      code: 'A1',
      platform: 'android',
    ),
  ];
  List<TeamInvite> inviteRows = [
    TeamInvite(
      id: 'i-1',
      phone: '919000000001',
      fullName: 'New Munshi',
      role: MemberRole.munshi,
      customPermissions: const {},
      status: 'pending',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    ),
  ];

  final calls = <String>[];
  Map<String, bool>? lastOverrides;
  MemberRole? lastRole;
  int? lastLimit;
  TeamResult next = const TeamSaved();

  Stream<T> _live<T>(StreamController<T> c, T Function() read) async* {
    yield read();
    yield* c.stream;
  }

  @override
  Stream<List<TeamMember>> watchMembers(String tenantId) =>
      _live(members, () => memberRows);

  @override
  Stream<List<TeamDevice>> watchDevices(String tenantId) =>
      _live(devices, () => deviceRows);

  @override
  Stream<List<TeamInvite>> watchPendingInvites(String tenantId) =>
      _live(invites, () => inviteRows);

  @override
  Future<TeamResult> updateMember(
    WriteContext ctx,
    String memberId, {
    required MemberRole role,
    required Map<String, bool> overrides,
    required int deviceLimit,
    required MemberRole actorRole,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    calls.add('update:$memberId');
    lastRole = role;
    lastOverrides = overrides;
    lastLimit = deviceLimit;
    return next;
  }

  @override
  Future<TeamResult> setActive(
    WriteContext ctx,
    String memberId, {
    required bool active,
    required MemberRole actorRole,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    calls.add('active:$memberId:$active');
    return next;
  }

  @override
  Future<TeamResult> revokeDevice(
    WriteContext ctx,
    String deviceId, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    calls.add('revoke:$deviceId');
    return next;
  }

  @override
  Future<TeamResult> cancelInvite(
    WriteContext ctx,
    String inviteId, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    calls.add('cancel:$inviteId');
    return next;
  }
}

class FakeInviteService implements InviteService {
  InviteResult result = const InviteSent(
    delivery: InviteDelivery.whatsapp,
    message: 'Hello',
    phone: '919814022199',
  );
  final calls = <Map<String, Object?>>[];

  @override
  Future<InviteResult> invite({
    required String tenantId,
    required String phone,
    required String role,
    required Map<String, bool> customPermissions,
    String? fullName,
    String? deviceId,
    String language = 'en',
    String channel = 'whatsapp',
  }) async {
    calls.add({
      'phone': phone,
      'role': role,
      'perms': customPermissions,
      'name': fullName,
      'channel': channel,
      'device': deviceId,
    });
    return result;
  }
}

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

void main() {
  late FakeTeamRepository repo;
  late FakeInviteService invites;

  setUp(() {
    repo = FakeTeamRepository();
    invites = FakeInviteService();
  });

  Future<void> pump(
    WidgetTester tester, {
    MemberRole role = MemberRole.owner,
    Map<String, Object?> custom = const {},
  }) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final prefs = await makePrefs();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teamRepositoryProvider.overrideWith((ref) async => repo),
          inviteServiceProvider.overrideWithValue(invites),
          activeTenantProvider.overrideWith(_FixedTenant.new),
          activeDeviceProvider.overrideWithValue((id: 'd-owner', code: 'W1')),
          writeContextProvider.overrideWithValue(ctx),
          activeMembershipProvider.overrideWithValue(
            Membership(
              tenantId: 't1',
              tenantName: 'Gupta',
              role: role,
              customPermissions: custom,
            ),
          ),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(userA)),
          appPrefsProvider.overrideWithValue(prefs),
          localDataWiperProvider.overrideWithValue(() async {}),
          syncIndicatorProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TeamScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('access', () {
    testWidgets('a munshi sees no user management', (tester) async {
      await pump(tester, role: MemberRole.munshi);
      expect(find.text('Only the owner can manage users.'), findsOneWidget);
      expect(find.byKey(const ValueKey('team-invite')), findsNothing);
      expect(find.text('Rajinder Kumar'), findsNothing);
    });

    testWidgets('admin.manage granted by override opens the screen', (
      tester,
    ) async {
      await pump(
        tester,
        role: MemberRole.accountant,
        custom: {'admin.manage': true},
      );
      expect(find.text('Rajinder Kumar'), findsOneWidget);
    });
  });

  group('people', () {
    testWidgets('lists people with roles, devices and pending invites', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Naresh Gupta (You)'), findsOneWidget);
      expect(find.text('Rajinder Kumar'), findsOneWidget);
      expect(find.text('98140 22112'), findsOneWidget);
      expect(find.text('Waiting to join'), findsOneWidget);
      expect(find.textContaining('New Munshi'), findsOneWidget);
      expect(find.text('Cancel invite'), findsOneWidget);
    });

    testWidgets('cancel invite', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('cancel-invite-i-1')));
      await tester.pumpAndSettle();
      expect(repo.calls, ['cancel:i-1']);
      expect(find.text('Invite cancelled'), findsOneWidget);
    });

    testWidgets('permission grid: overrides are stored as differences', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('member-m-munshi')));
      await tester.pumpAndSettle();

      // Munshi default: reverse is off, payments are on.
      final reverse = find.byKey(const ValueKey('perm-entries.reverse'));
      final payments = find.byKey(const ValueKey('perm-payments.create'));
      expect(tester.widget<SwitchListTile>(reverse).value, isFalse);
      expect(tester.widget<SwitchListTile>(payments).value, isTrue);

      await tester.tap(reverse);
      await tester.tap(payments);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('member-save')));
      await tester.pumpAndSettle();

      expect(repo.calls, ['update:m-munshi']);
      expect(repo.lastRole, MemberRole.munshi);
      expect(repo.lastOverrides, {
        'entries.reverse': true,
        'payments.create': false,
      });
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets("changing the role starts from that role's defaults", (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('member-m-munshi')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('role-accountant')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('perm-entries.reverse')),
            )
            .value,
        isTrue,
      );
      await tester.tap(find.byKey(const ValueKey('limit-minus')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('member-save')));
      await tester.pumpAndSettle();
      expect(repo.lastRole, MemberRole.accountant);
      expect(repo.lastOverrides, isEmpty);
      expect(repo.lastLimit, 4);
    });

    testWidgets('a refused change shows the reason and keeps the dialog', (
      tester,
    ) async {
      repo.next = const TeamLastOwner();
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('member-m-owner')));
      await tester.pumpAndSettle();
      expect(
        find.text('Owners can do everything. This cannot be changed.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('role-munshi')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('member-save')));
      await tester.pumpAndSettle();
      expect(
        find.text('A business must keep at least one active owner.'),
        findsOneWidget,
      );
    });

    testWidgets('deactivate asks first', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('member-m-munshi')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('member-toggle-active')));
      await tester.pumpAndSettle();
      expect(find.text('Deactivate Rajinder Kumar?'), findsOneWidget);
      expect(repo.calls, isEmpty);
      await tester.tap(find.byKey(const ValueKey('confirm-deactivate')));
      await tester.pumpAndSettle();
      expect(repo.calls, ['active:m-munshi:false']);
    });

    testWidgets('you cannot deactivate yourself', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('member-m-owner')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('member-toggle-active')), findsNothing);
    });

    testWidgets('a delegated admin cannot edit an owner', (tester) async {
      await pump(
        tester,
        role: MemberRole.accountant,
        custom: {'admin.manage': true},
      );
      await tester.tap(find.byKey(const ValueKey('member-m-owner')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Only an owner can change an owner, and you cannot change your own '
          'access.',
        ),
        findsOneWidget,
      );
      final save = find.byKey(const ValueKey('member-save'));
      expect(
        tester
            .widget<TextButton>(
              find.descendant(of: save, matching: find.byType(TextButton)),
            )
            .onPressed,
        isNull,
      );
    });
  });

  group('devices', () {
    testWidgets(
      'lists devices; revoke needs a confirmation; not for this one',
      (tester) async {
        await pump(tester);
        await tester.tap(find.text('Devices').first);
        await tester.pumpAndSettle();
        expect(find.text('W1 · Windows'), findsOneWidget);
        expect(find.text('A1 · Android'), findsOneWidget);
        expect(find.text('This device'), findsOneWidget);
        expect(find.byKey(const ValueKey('revoke-d-owner')), findsNothing);

        await tester.tap(find.byKey(const ValueKey('revoke-d-munshi')));
        await tester.pumpAndSettle();
        expect(find.text('Revoke device A1?'), findsOneWidget);
        expect(repo.calls, isEmpty);
        await tester.tap(find.byKey(const ValueKey('confirm-revoke')));
        await tester.pumpAndSettle();
        expect(repo.calls, ['revoke:d-munshi']);
        expect(find.text('Device revoked'), findsOneWidget);
      },
    );

    testWidgets('a revoked device is marked and has no revoke button', (
      tester,
    ) async {
      repo.deviceRows = [
        TeamDevice(
          id: 'd-munshi',
          userId: 'u-munshi',
          code: 'A1',
          platform: 'android',
          revokedAt: DateTime(2026, 10, 3),
        ),
      ];
      await pump(tester);
      await tester.tap(find.text('Devices').first);
      await tester.pumpAndSettle();
      expect(find.text('Revoked'), findsOneWidget);
      expect(find.byKey(const ValueKey('revoke-d-munshi')), findsNothing);
    });
  });

  group('invite', () {
    Future<void> open(WidgetTester tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('team-invite')));
      await tester.pumpAndSettle();
    }

    testWidgets('Ctrl+N opens it', (tester) async {
      await pump(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('invite-phone')), findsOneWidget);
    });

    testWidgets('a bad number is refused before anything is sent', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(
        find.byKey(const ValueKey('invite-phone')),
        '12345',
      );
      await tester.tap(find.byKey(const ValueKey('invite-send')));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a valid 10-digit mobile number.'),
        findsOneWidget,
      );
      expect(invites.calls, isEmpty);
    });

    testWidgets('sends role, permission differences and the device', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(
        find.byKey(const ValueKey('invite-phone')),
        '98140 22199',
      );
      await tester.enterText(
        find.byKey(const ValueKey('invite-name')),
        'Gate munshi',
      );
      await tester.tap(find.byKey(const ValueKey('role-accountant')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('perm-finance.view')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('channel-sms')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('invite-send')));
      await tester.pumpAndSettle();

      expect(invites.calls, [
        {
          'phone': '919814022199',
          'role': 'accountant',
          'perms': {'finance.view': false},
          'name': 'Gate munshi',
          'channel': 'sms',
          'device': 'd-owner',
        },
      ]);
      expect(
        find.text('Invite sent on WhatsApp to 98140 22199.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('invite-phone')), findsNothing);
    });

    testWidgets('nothing sent (no provider): the owner gets the message', (
      tester,
    ) async {
      invites.result = const InviteSent(
        delivery: InviteDelivery.none,
        message: 'Join us: https://example.test',
        phone: '919814022199',
      );
      await open(tester);
      await tester.enterText(
        find.byKey(const ValueKey('invite-phone')),
        '9814022199',
      );
      await tester.tap(find.byKey(const ValueKey('invite-send')));
      await tester.pumpAndSettle();
      expect(find.text('Invite saved: send it yourself'), findsOneWidget);
      expect(find.text('Join us: https://example.test'), findsOneWidget);
      expect(find.text('Copy message'), findsOneWidget);
    });

    for (final (failure, text) in [
      (
        InviteFailure.offline,
        'Inviting needs internet. Connect and try again.',
      ),
      (InviteFailure.alreadyMember, 'This person is already on your team.'),
      (
        InviteFailure.alreadyInvited,
        'This number already has a pending invite.',
      ),
      (InviteFailure.notAllowed, 'Only the owner can invite people.'),
    ]) {
      testWidgets('server says ${failure.name}', (tester) async {
        invites.result = InviteRejected(failure);
        await open(tester);
        await tester.enterText(
          find.byKey(const ValueKey('invite-phone')),
          '9814022199',
        );
        await tester.tap(find.byKey(const ValueKey('invite-send')));
        await tester.pumpAndSettle();
        expect(find.text(text), findsOneWidget);
        // Still open so the owner can fix it or retry.
        expect(find.byKey(const ValueKey('invite-phone')), findsOneWidget);
      });
    }
  });
}
