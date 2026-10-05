import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'interest_providers.g.dart';

/// The settings target of [party]: its own rows and its group's.
SettingsTarget partyTarget(Party party) =>
    (partyId: party.id, partyGroupId: party.partyGroupId, documentId: null);

/// The party's interest terms resolved through the cascade
/// (system → business → group → party), with the supplier / agency default
/// applied. Null while settings load.
@riverpod
InterestConfig? partyInterestConfig(Ref ref, Party party) {
  final resolver = ref.watch(settingsResolverProvider(partyTarget(party)));
  if (resolver == null) return null;
  return InterestConfig.fromSettings(
    resolver,
    partyId: party.id,
    partyGroupId: party.partyGroupId,
    partyRoles: party.roles,
  );
}

/// Saves the interest terms of parties (party-level `interest.*` rows) as
/// the signed-in member. Each row is one audited setting write.
class PartyInterestWriter {
  PartyInterestWriter(this._ref);

  final Ref _ref;

  /// Writes [values] (key → value, `null` = back to inherited) for [partyId].
  /// A `null` is only written where the party has its own row, so nothing is
  /// created just to say "inherit". Returns the first failure, else null.
  Future<SettingWriteFailure?> apply(
    String partyId,
    Map<String, Object?> values, {
    required Set<String> existingKeys,
  }) async {
    final writer = _ref.read(settingsWriterProvider);
    for (final e in values.entries) {
      if (e.value == null && !existingKeys.contains(e.key)) continue;
      final failure = await writer.write(
        scope: SettingScope.party,
        scopeId: partyId,
        key: e.key,
        value: e.value,
      );
      if (failure != null) return failure;
    }
    return null;
  }
}

@Riverpod(keepAlive: true)
PartyInterestWriter partyInterestWriter(Ref ref) => PartyInterestWriter(ref);
