import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/team/data/team_repository.dart';
import 'package:mandi_khata_app/features/team/domain/team_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_providers.g.dart';

@Riverpod(keepAlive: true)
Future<TeamRepository> teamRepository(Ref ref) async =>
    TeamRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// People of the active business (active first). Live.
@riverpod
Stream<List<TeamMember>> teamMembers(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(teamRepositoryProvider.future);
  yield* repo.watchMembers(tenantId);
}

/// Devices of the active business. Live.
@riverpod
Stream<List<TeamDevice>> teamDevices(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(teamRepositoryProvider.future);
  yield* repo.watchDevices(tenantId);
}

/// Invites waiting to be accepted. Live.
@riverpod
Stream<List<TeamInvite>> pendingInvites(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(teamRepositoryProvider.future);
  yield* repo.watchPendingInvites(tenantId);
}

/// Changes the team as the signed-in member of the active business.
class TeamWriter {
  TeamWriter(this._ref);

  final Ref _ref;

  Future<TeamResult> _run(
    Future<TeamResult> Function(
      TeamRepository repo,
      WriteContext ctx,
      MemberRole actorRole,
      bool Function(Permission) can,
    )
    action,
  ) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return const TeamNotPermitted();
    final repo = await _ref.read(teamRepositoryProvider.future);
    return await action(repo, ctx, member.role, member.can);
  }

  Future<TeamResult> updateMember(
    String memberId, {
    required MemberRole role,
    required Map<String, bool> overrides,
    required int deviceLimit,
  }) => _run(
    (repo, ctx, actor, can) => repo.updateMember(
      ctx,
      memberId,
      role: role,
      overrides: overrides,
      deviceLimit: deviceLimit,
      actorRole: actor,
      can: can,
    ),
  );

  Future<TeamResult> setActive(String memberId, {required bool active}) => _run(
    (repo, ctx, actor, can) => repo.setActive(
      ctx,
      memberId,
      active: active,
      actorRole: actor,
      can: can,
    ),
  );

  Future<TeamResult> revokeDevice(String deviceId) => _run(
    (repo, ctx, actor, can) => repo.revokeDevice(ctx, deviceId, can: can),
  );

  Future<TeamResult> cancelInvite(String inviteId) => _run(
    (repo, ctx, actor, can) => repo.cancelInvite(ctx, inviteId, can: can),
  );
}

@Riverpod(keepAlive: true)
TeamWriter teamWriter(Ref ref) => TeamWriter(ref);
