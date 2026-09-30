import 'dart:convert';
import 'dart:math' as math;

import 'package:mandi_khata_app/core/db/powersync_schema.dart';

/// Whether a failed upload should be retried or set aside.
enum UploadFailureKind {
  /// Network, timeout, expired token, server down: try again later.
  transient,

  /// The server will never accept this change (RLS, constraint, bad data).
  /// Retrying would block every later change in the queue.
  permanent,
}

/// Decides from a Postgres / PostgREST error code whether retrying can help.
///
/// Permanent:
/// * class 22 — data exception (bad value, wrong type);
/// * class 23 — integrity constraint (unique, foreign key, check);
/// * 42501 — RLS / privilege denied (includes our guard triggers);
/// * 42703 — unknown column, P0001 — raised by a trigger;
/// * PGRST204 — PostgREST cannot find a column (app ahead of the schema).
///
/// Anything else, including errors without a code, is treated as transient.
UploadFailureKind classifyUploadError(String? code) {
  if (code == null) return UploadFailureKind.transient;
  if (RegExp(r'^2[23][0-9A-Z]{3}$').hasMatch(code)) {
    return UploadFailureKind.permanent;
  }
  const permanentCodes = {'42501', '42703', 'P0001', 'PGRST204'};
  return permanentCodes.contains(code)
      ? UploadFailureKind.permanent
      : UploadFailureKind.transient;
}

/// Exponential backoff for transient upload failures: 1 s, 2 s, 4 s … capped.
class UploadBackoff {
  UploadBackoff({
    this.initial = const Duration(seconds: 1),
    this.max = const Duration(seconds: 60),
  });

  final Duration initial;
  final Duration max;
  int _failures = 0;

  int get failures => _failures;

  /// Records a failure and returns how long to wait before the next attempt.
  Duration nextDelay() {
    final factor = math.pow(2, _failures.clamp(0, 20)).toInt();
    _failures++;
    final ms = initial.inMilliseconds * factor;
    return Duration(milliseconds: math.min(ms, max.inMilliseconds));
  }

  void reset() => _failures = 0;
}

/// Turns locally stored values back into what Postgres expects: JSON text →
/// JSON value for `jsonb` columns, 0/1 → bool for `boolean` columns. Other
/// values pass through. Unknown tables pass through unchanged.
Map<String, Object?> toServerPayload(String table, Map<String, Object?> data) {
  final spec = syncedTable(table);
  if (spec == null) return Map.of(data);
  return {
    for (final MapEntry(:key, :value) in data.entries)
      key: switch ((spec.columns[key], value)) {
        (ColumnKind.json, final String text) => _decodeJson(text),
        (ColumnKind.boolean, final int flag) => flag != 0,
        _ => value,
      },
  };
}

Object? _decodeJson(String text) {
  try {
    return jsonDecode(text);
  } on FormatException {
    // Not JSON (e.g. a bare word): send it as a JSON string rather than lose
    // it; the server's check constraints decide whether it is acceptable.
    return text;
  }
}
