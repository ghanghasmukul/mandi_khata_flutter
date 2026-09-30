import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/sync/sync_indicator.dart';
import 'package:mandi_khata_app/core/sync/upload_policy.dart';

void main() {
  group('classifyUploadError', () {
    const permanent = UploadFailureKind.permanent;
    const transient = UploadFailureKind.transient;
    final cases = <String?, UploadFailureKind>{
      '42501': permanent, // RLS / guard trigger
      '23505': permanent, // unique violation
      '23503': permanent, // foreign key
      '23514': permanent, // check constraint
      '22P02': permanent, // invalid text representation
      'P0001': permanent, // raised by a trigger (e.g. last owner)
      '42703': permanent, // unknown column
      'PGRST204': permanent, // column missing in schema cache
      'PGRST301': transient, // JWT expired → refresh and retry
      '08006': transient, // connection failure
      '57014': transient, // statement timeout
      null: transient, // network errors carry no code
    };
    for (final MapEntry(key: code, value: kind) in cases.entries) {
      test('$code → ${kind.name}', () {
        expect(classifyUploadError(code), kind);
      });
    }
  });

  test('backoff doubles up to the cap and resets', () {
    final backoff = UploadBackoff(max: const Duration(seconds: 10));
    final delays = [for (var i = 0; i < 6; i++) backoff.nextDelay().inSeconds];
    expect(delays, [1, 2, 4, 8, 10, 10]);
    backoff.reset();
    expect(backoff.nextDelay(), const Duration(seconds: 1));
  });

  group('toServerPayload', () {
    test('decodes JSON columns and turns 0/1 into booleans', () {
      final payload = toServerPayload('tenant_members', {
        'role': 'munshi',
        'custom_permissions': '{"master.delete":true}',
        'is_active': 0,
        'device_limit': 2,
      });
      expect(payload, {
        'role': 'munshi',
        'custom_permissions': {'master.delete': true},
        'is_active': false,
        'device_limit': 2,
      });
    });

    test('keeps a null setting value (inherit) and JSON scalars', () {
      expect(toServerPayload('settings', {'value': null}), {'value': null});
      expect(toServerPayload('settings', {'value': '2.5'}), {'value': 2.5});
      expect(toServerPayload('settings', {'value': '"compound"'}), {
        'value': 'compound',
      });
    });

    test('non-JSON text in a JSON column is sent as a JSON string', () {
      expect(toServerPayload('settings', {'value': 'compound'}), {
        'value': 'compound',
      });
    });

    test('unknown tables pass through unchanged', () {
      expect(toServerPayload('sync_errors', {'x': '1'}), {'x': '1'});
    });
  });

  group('syncIndicatorFor', () {
    SyncIndicator pick({
      bool configured = true,
      bool connected = true,
      bool connecting = false,
      bool transferring = false,
      int queued = 0,
      int rejected = 0,
      DateTime? at,
    }) => syncIndicatorFor(
      configured: configured,
      connected: connected,
      connecting: connecting,
      transferring: transferring,
      queued: queued,
      rejected: rejected,
      lastSyncedAt: at,
    );

    final at = DateTime.utc(2026, 9, 30, 10);

    test('off when not configured', () {
      expect(pick(configured: false, rejected: 3), const SyncOff());
    });
    test('rejected changes win over everything else', () {
      expect(
        pick(connected: false, queued: 4, rejected: 2),
        const SyncRejected(2),
      );
    });
    test('offline shows the queue', () {
      expect(pick(connected: false, queued: 4), const SyncOffline(4));
    });
    test('busy while connecting, transferring or with a queue', () {
      expect(pick(connected: false, connecting: true), const SyncBusy());
      expect(pick(transferring: true), const SyncBusy());
      expect(pick(queued: 1), const SyncBusy());
    });
    test('done when connected and idle', () {
      expect(pick(at: at), SyncDone(at));
    });
    test('age in minutes and hours', () {
      expect(ageOf(at, at.add(const Duration(seconds: 59))), (
        minutes: 0,
        hours: 0,
      ));
      expect(ageOf(at, at.add(const Duration(minutes: 2))), (
        minutes: 2,
        hours: 0,
      ));
      expect(ageOf(at, at.add(const Duration(minutes: 135))), (
        minutes: 135,
        hours: 2,
      ));
      expect(ageOf(at, at.subtract(const Duration(minutes: 5))), (
        minutes: 0,
        hours: 0,
      ));
    });
  });
}
