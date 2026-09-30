import 'package:decimal/decimal.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/settings/setting_scope.dart';
import 'package:khata_core/src/settings/settings_schema.dart';
import 'package:meta/meta.dart';

/// One stored setting (a row of `settings`), value already JSON-decoded.
/// A null [value] means "inherit".
@immutable
class SettingRow {
  const SettingRow({
    required this.scope,
    required this.key,
    this.scopeId,
    this.value,
  });

  final SettingScope scope;
  final String? scopeId;
  final String key;
  final Object? value;
}

/// A resolved value and where it came from.
@immutable
class ResolvedSetting {
  const ResolvedSetting({
    required this.value,
    required this.level,
    required this.matchedKey,
  });

  final Object? value;
  final SettingLevel level;

  /// The key that supplied the value: the per-crop key or the generic one.
  final String matchedKey;

  bool get asBool => value! as bool;
  int get asInt => value! as int;
  String get asString => value! as String;
  Decimal get asDecimal => SettingsSchema.decimalOf(value)!;
  Money get asMoney => Money(value! as int);
}

/// Resolves a key through the cascade (docs/domain/settings-cascade.md):
/// document → party → party group → tenant → plan → system.
///
/// Level first: within each level a suffixed key (`mandi.commission_pct.wheat`)
/// beats its generic key; a more specific level always beats a less
/// specific one. Null and invalid stored values are skipped (inherit).
class SettingsResolver {
  SettingsResolver(Iterable<SettingRow> rows, {this._planDefaults = const {}}) {
    for (final r in rows) {
      _rows[(r.scope.level, r.scopeId, r.key)] = r;
    }
  }

  final Map<(SettingLevel, String?, String), SettingRow> _rows = {};
  final Map<String, Object?> _planDefaults;

  /// Throws [ArgumentError] for a key that is not in [SettingsSchema].
  ResolvedSetting resolve(
    String key, {
    String? partyId,
    String? partyGroupId,
    String? documentId,
  }) {
    final parsed = SettingsSchema.parse(key);
    if (parsed == null) throw ArgumentError.value(key, 'key', 'unknown');
    final def = parsed.def;
    final candidates = [parsed.full, if (parsed.suffix != null) def.key];

    ResolvedSetting? fromRows(SettingLevel level, String? scopeId) {
      for (final k in candidates) {
        final row = _rows[(level, scopeId, k)];
        if (row == null || row.value == null) continue;
        if (def.validate(row.value) != null) continue;
        return ResolvedSetting(value: row.value, level: level, matchedKey: k);
      }
      return null;
    }

    final found =
        (documentId == null
            ? null
            : fromRows(SettingLevel.document, documentId)) ??
        (partyId == null ? null : fromRows(SettingLevel.party, partyId)) ??
        (partyGroupId == null
            ? null
            : fromRows(SettingLevel.partyGroup, partyGroupId)) ??
        fromRows(SettingLevel.tenant, null);
    if (found != null) return found;

    for (final k in candidates) {
      final v = _planDefaults[k];
      if (v != null && def.validate(v) == null) {
        return ResolvedSetting(
          value: v,
          level: SettingLevel.plan,
          matchedKey: k,
        );
      }
    }
    return ResolvedSetting(
      value: def.defaultFor(parsed.suffix),
      level: SettingLevel.system,
      matchedKey: def.key,
    );
  }
}
