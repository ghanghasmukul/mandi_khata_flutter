import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/subscription/subscription_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parties_providers.g.dart';

@Riverpod(keepAlive: true)
Future<PartiesRepository> partiesRepository(Ref ref) async =>
    PartiesRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Active parties of the active business matching [query] and [role].
@riverpod
Stream<List<Party>> partyList(Ref ref, String query, PartyRole? role) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(partiesRepositoryProvider.future);
  yield* repo.watchAll(tenantId, query: query, role: role);
}

/// One party of the active business; null if missing or deleted.
@riverpod
Stream<Party?> party(Ref ref, String id) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(partiesRepositoryProvider.future);
  yield* repo.watchOne(tenantId, id);
}

/// The automatic code a new party would get (form hint).
@riverpod
Future<String?> nextPartyCode(Ref ref) async {
  final ctx = ref.watch(writeContextProvider);
  if (ctx == null) return null;
  final repo = await ref.watch(partiesRepositoryProvider.future);
  return await repo.previewNextCode(ctx);
}

/// Saves parties as the signed-in member of the active business.
class PartyWriter {
  PartyWriter(this._ref);

  final Ref _ref;

  Future<PartySaveResult> _run(
    Future<PartySaveResult> Function(
      PartiesRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return const PartyNotPermitted();
    final repo = await _ref.read(partiesRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  Future<PartySaveResult> create(PartyInput input) {
    // The plan's limit, checked inside the save (read before any await).
    final maxParties = _ref.read(entitlementsProvider).limit('parties');
    return _run(
      (repo, ctx, can) =>
          repo.create(ctx, input, can: can, maxParties: maxParties),
    );
  }

  Future<PartySaveResult> update(String id, PartyInput input) =>
      _run((repo, ctx, can) => repo.update(ctx, id, input, can: can));

  Future<PartySaveResult> delete(String id) =>
      _run((repo, ctx, can) => repo.softDelete(ctx, id, can: can));
}

@Riverpod(keepAlive: true)
PartyWriter partyWriter(Ref ref) => PartyWriter(ref);

extension PartyLabels on AppLocalizations {
  String partyRole(PartyRole role) => switch (role) {
    PartyRole.farmer => settingSuffixRoleFarmer,
    PartyRole.customer => settingSuffixRoleCustomer,
    PartyRole.supplier => settingSuffixRoleSupplier,
    PartyRole.vendor => settingSuffixRoleVendor,
    PartyRole.agency => settingSuffixRoleAgency,
    PartyRole.buyer => settingSuffixRoleBuyer,
  };

  String relation(Relation? r) => switch (r) {
    null => partyRelationNone,
    Relation.sonOf => partyRelationSonOf,
    Relation.daughterOf => partyRelationDaughterOf,
    Relation.wifeOf => partyRelationWifeOf,
    Relation.proprietor => partyRelationProprietor,
  };

  /// "Gurmeet Singh S/o Bachan Singh" style line.
  String partyFullName(Party p) {
    final father = p.fatherOrHusbandName;
    if (p.relation == null ||
        p.relation == Relation.proprietor ||
        father == null) {
      return p.name;
    }
    return '${p.name} ${relation(p.relation)} $father';
  }

  String? partyFieldError(PartyField field, PartyFieldError? error) =>
      switch ((field, error)) {
        (_, null) => null,
        (PartyField.roles, _) => partyErrorRoles,
        (_, PartyFieldError.required) => partyErrorRequired,
        (PartyField.mobile || PartyField.altMobile, _) => partyErrorMobile,
        (PartyField.ifsc, _) => partyErrorIfsc,
        (PartyField.gstin, _) => partyErrorGstin,
        (PartyField.aadhaarLast4, _) => partyErrorAadhaar,
        _ => partyErrorRequired,
      };
}
