import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/update/app_version.dart';
import 'package:mandi_khata_app/core/update/update_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_providers.g.dart';

/// `windows`, `macos`, `android` or `web` (the keys of `downloads`).
String get updatePlatform {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.windows => 'windows',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.android => 'android',
    _ => defaultTargetPlatform.name,
  };
}

/// The version this build was made as (`--build-name`).
@Riverpod(keepAlive: true)
Future<AppVersion> currentVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return AppVersion.tryParse(info.version) ?? const AppVersion(0, 0, 0);
}

/// The result of the start-up check. Runs once per app start; offline it
/// simply ends as [UpdateCheckFailed].
@Riverpod(keepAlive: true)
Future<UpdateStatus> updateStatus(Ref ref) async {
  if (Env.updateManifestUrl.isEmpty || kIsWeb) return const UpdateNone();
  final current = await ref.watch(currentVersionProvider.future);
  final client = http.Client();
  ref.onDispose(client.close);
  final status = await UpdateChecker(
    client: client,
    manifestUrl: Env.updateManifestUrl,
    platform: updatePlatform,
    current: current,
  ).check();
  return status;
}

/// Hides the (optional) banner for the version the user said "later" to.
@riverpod
class DismissedUpdate extends _$DismissedUpdate {
  @override
  String? build() => ref.read(appPrefsProvider).dismissedUpdate;

  Future<void> dismiss(AppVersion version) async {
    state = version.toString();
    await ref.read(appPrefsProvider).setDismissedUpdate(version.toString());
  }
}
