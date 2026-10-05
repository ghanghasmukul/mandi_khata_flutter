import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/interest/data/interest_posting_repository.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'interest_posting_providers.g.dart';

@Riverpod(keepAlive: true)
Future<InterestPostingRepository> interestPostingRepository(Ref ref) async =>
    InterestPostingRepository(
      await ref.watch(powerSyncDatabaseProvider.future),
      planDefaults: ref.watch(planDefaultsProvider),
    );

/// Postings and waivers of one party (khata and loans). Live.
@riverpod
Stream<List<PostingRow>> partyPostings(Ref ref, String partyId) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(interestPostingRepositoryProvider.future);
  yield* repo.watchParty(tenantId, partyId);
}

/// Accounts with interest to post as of [asOf] (one party only when
/// [partyId] is given). Read again when the postings or entries change.
@riverpod
Future<List<PostingCandidate>> postingCandidates(
  Ref ref,
  LedgerDate asOf, {
  String? partyId,
}) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  if (partyId != null) ref.watch(partyPostingsProvider(partyId));
  final repo = await ref.watch(interestPostingRepositoryProvider.future);
  return await repo.candidates(tenantId, asOf, partyId: partyId);
}

/// The day the bulk run proposes: the end of the last period of
/// `interest.post_frequency` (today for on demand).
@riverpod
LedgerDate suggestedPostingDay(Ref ref, LedgerDate today) {
  final frequency = ref
      .watch(settingProvider('interest.post_frequency', businessTarget))
      ?.value;
  return PostingSchedule.suggestedAsOf('$frequency', today);
}

/// Posts interest and settles accounts as the signed-in member.
class InterestPostingWriter {
  InterestPostingWriter(this._ref);

  final Ref _ref;

  Future<PostingResult> _run(
    Future<PostingResult> Function(
      InterestPostingRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const PostingNotPermitted(Permission.loansManage);
    }
    final repo = await _ref.read(interestPostingRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  Future<PostingResult> post(List<InterestPostingPlan> plans) =>
      _run((repo, ctx, can) => repo.post(ctx, plans, can: can));

  Future<PostingResult> settle(
    String partyId,
    LedgerDate asOf, {
    Map<String, int> waivers = const {},
    String reason = '',
  }) => _run(
    (repo, ctx, can) => repo.settle(
      ctx,
      partyId,
      asOf,
      can: can,
      waivers: waivers,
      reason: reason,
    ),
  );
}

@Riverpod(keepAlive: true)
InterestPostingWriter interestPostingWriter(Ref ref) =>
    InterestPostingWriter(ref);

extension InterestPostingLabels on AppLocalizations {
  String settlementProblem(SettlementProblem p) => switch (p) {
    SettlementProblem.waiverNegative => settleErrorNegative,
    SettlementProblem.waiverExceedsInterest => settleErrorExceeds,
    SettlementProblem.reasonRequired => settleErrorReason,
    SettlementProblem.unknownSource => settleErrorUnknown,
  };

  String postingSkip(PostingSkip s) => switch (s) {
    PostingSkip.alreadyPosted => postSkipAlready,
    PostingSkip.notFound => postSkipNotFound,
    PostingSkip.backdated => postSkipBackdated,
  };

  /// A message for a posting that did not happen, or null when it did.
  String? postingError(PostingResult r) => switch (r) {
    InterestPosted(:final posted, :final skipped) when posted.isEmpty =>
      skipped.isEmpty ? postNothing : postingSkip(skipped.first.reason),
    InterestPosted() || SettlementDone() => null,
    PostingNotPermitted(permission: Permission.entriesReverse) =>
      settleErrorNeedsReverse,
    PostingNotPermitted() => postErrorNotPermitted,
    PostingInFuture() => postErrorFuture,
    PostingRefused(:final reason) => postingSkip(reason),
    SettlementInvalid(:final problems) =>
      problems.map(settlementProblem).join('\n'),
  };
}
