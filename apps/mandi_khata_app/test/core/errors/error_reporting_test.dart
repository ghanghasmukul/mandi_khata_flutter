import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mandi_khata_app/core/errors/error_reporting.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test('no personal data leaves the device', () {
    final event = SentryEvent(
      user: SentryUser(id: 'u1', email: 'owner@example.com'),
      request: SentryRequest(url: 'https://x.test/?phone=9814022110'),
      serverName: 'shop-pc',
    );
    final scrubbed = ErrorReporting.scrub(event, Hint())!;
    expect(scrubbed.user, isNull);
    expect(scrubbed.request, isNull);
    expect(scrubbed.serverName, isNull);
  });

  test('off without SENTRY_DSN: nothing is sent, the app still runs', () async {
    expect(ErrorReporting.enabled, isFalse);
    ErrorReporting.captureLog(
      LogRecord(Level.SEVERE, 'boom', 'sync', StateError('x')),
    );
    var ran = false;
    await ErrorReporting.run(() => ran = true);
    expect(ran, isTrue);
    await ErrorReporting.setTags(null);
  });
}
