import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:http/http.dart' as http;
import 'package:mandi_khata_app/core/update/app_version.dart';

/// `latest.json`, published next to each release (see docs/ops.md):
///
/// ```json
/// {
///   "version": "1.2.0",
///   "min_supported": "1.0.0",
///   "notes": "Cheque reminders on the dashboard.",
///   "downloads": {
///     "windows": "https://.../MandiKhata-Setup-1.2.0.exe",
///     "macos": "https://.../MandiKhata-1.2.0.dmg",
///     "android": "https://play.google.com/store/apps/details?id=..."
///   }
/// }
/// ```
///
/// Platforms with no entry (web updates itself on reload) never see a banner.
@immutable
class UpdateManifest {
  const UpdateManifest({
    required this.version,
    required this.minSupported,
    required this.downloads,
    this.notes,
  });

  /// Null when the JSON is not a manifest (wrong shape or version).
  static UpdateManifest? tryParse(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final version = AppVersion.tryParse(json['version'] as String?);
    if (version == null) return null;
    final downloads = json['downloads'];
    return UpdateManifest(
      version: version,
      minSupported:
          AppVersion.tryParse(json['min_supported'] as String?) ??
          const AppVersion(0, 0, 0),
      notes: json['notes'] as String?,
      downloads: {
        if (downloads is Map<String, Object?>)
          for (final e in downloads.entries)
            if (e.value case final String url when url.isNotEmpty) e.key: url,
      },
    );
  }

  final AppVersion version;

  /// Versions below this must update (a schema or sync change they cannot
  /// handle); the banner then cannot be dismissed.
  final AppVersion minSupported;
  final String? notes;

  /// Platform name (`windows`, `macos`, `android`) to download link.
  final Map<String, String> downloads;
}

sealed class UpdateStatus {
  const UpdateStatus();
}

/// Nothing to say: this is the newest version, no manifest is configured, or
/// there is no download for this platform.
final class UpdateNone extends UpdateStatus {
  const UpdateNone();
}

/// Offline or the manifest could not be read. Never shown to the user: the
/// app works the same without a network, and the next start tries again.
final class UpdateCheckFailed extends UpdateStatus {
  const UpdateCheckFailed(this.reason);

  final Object reason;
}

final class UpdateAvailable extends UpdateStatus {
  const UpdateAvailable({
    required this.latest,
    required this.url,
    required this.required,
    this.notes,
  });

  final AppVersion latest;
  final String url;

  /// The running version is below `min_supported`.
  final bool required;
  final String? notes;
}

/// Asks the version manifest whether a newer build exists.
///
/// One small GET with a short timeout, and every failure (offline, DNS,
/// timeout, bad JSON) comes back as [UpdateCheckFailed], never an exception:
/// the check must never get in the way of the shop counter.
class UpdateChecker {
  UpdateChecker({
    required this.client,
    required this.manifestUrl,
    required this.platform,
    required this.current,
    this.timeout = const Duration(seconds: 8),
  });

  final http.Client client;

  /// Empty disables the check (dev builds, CI builds).
  final String manifestUrl;

  /// `windows`, `macos`, `android` or `web`.
  final String platform;
  final AppVersion current;
  final Duration timeout;

  Future<UpdateStatus> check() async {
    if (manifestUrl.isEmpty) return const UpdateNone();
    final Object? json;
    try {
      final response = await client
          .get(Uri.parse(manifestUrl))
          .timeout(timeout);
      if (response.statusCode != 200) {
        return UpdateCheckFailed('HTTP ${response.statusCode}');
      }
      json = jsonDecode(utf8.decode(response.bodyBytes));
    } on Object catch (e) {
      // Offline, DNS, timeout, TLS, bad JSON: all the same to the user.
      return UpdateCheckFailed(e);
    }
    final manifest = UpdateManifest.tryParse(json);
    if (manifest == null) return const UpdateCheckFailed('not a manifest');
    return decide(manifest);
  }

  /// Pure part of the check, for tests.
  UpdateStatus decide(UpdateManifest manifest) {
    final url = manifest.downloads[platform];
    if (url == null || !(manifest.version > current)) {
      return const UpdateNone();
    }
    return UpdateAvailable(
      latest: manifest.version,
      url: url,
      required: current < manifest.minSupported,
      notes: manifest.notes,
    );
  }
}
