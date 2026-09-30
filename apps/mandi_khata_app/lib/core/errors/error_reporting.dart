import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'error_reporting.g.dart';

/// Crash / error reporting (Sentry). Off unless `SENTRY_DSN` is set.
///
/// No personal data leaves the device: no names, phones, emails, IPs or
/// screenshots. Events carry only the business id and the device code, so
/// a problem can be traced to "tenant X, counter PC W1".
abstract final class ErrorReporting {
  static bool get enabled => Env.sentryDsn.isNotEmpty;

  /// Runs [appRunner] with Sentry set up (or directly when disabled).
  static Future<void> run(FutureOr<void> Function() appRunner) async {
    if (!enabled) {
      await appRunner();
      return;
    }
    await SentryFlutter.init((options) {
      options
        ..dsn = Env.sentryDsn
        ..environment = kReleaseMode ? 'production' : 'development'
        ..sendDefaultPii = false
        ..attachScreenshot = false
        ..beforeSend = scrub;
    }, appRunner: appRunner);
  }

  /// Drops anything that could identify a person, whatever the SDK or a
  /// library added.
  @visibleForTesting
  static SentryEvent? scrub(SentryEvent event, Hint hint) => event
    ..user = null
    ..request = null
    ..serverName = null;

  /// SEVERE log records become Sentry events (errors are otherwise only
  /// logged). Messages must not contain personal data; ours carry ids and
  /// error codes only.
  static void captureLog(LogRecord record) {
    if (!enabled || record.level < Level.SEVERE) return;
    unawaited(
      Sentry.captureException(
        record.error ?? record.message,
        stackTrace: record.stackTrace,
        withScope: (scope) => scope.setTag('logger', record.loggerName),
      ),
    );
  }

  static Future<void> setTags(WriteContext? ctx) async {
    if (!enabled) return;
    await Sentry.configureScope((scope) async {
      if (ctx == null) {
        await scope.removeTag('tenant_id');
        await scope.removeTag('device_code');
      } else {
        await scope.setTag('tenant_id', ctx.tenantId);
        await scope.setTag('device_code', ctx.deviceCode);
      }
    });
  }
}

/// Keeps the Sentry tags in step with the active business and device.
/// Watched once by the app root.
@Riverpod(keepAlive: true)
void errorReportingTags(Ref ref) {
  ref.listen(
    writeContextProvider,
    (_, ctx) => unawaited(ErrorReporting.setTags(ctx)),
    fireImmediately: true,
  );
}
