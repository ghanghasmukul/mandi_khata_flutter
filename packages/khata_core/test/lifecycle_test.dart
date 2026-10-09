import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

DateTime d(int m, int day, [int h = 0]) => DateTime.utc(2027, m, day, h);

void main() {
  group('trial', () {
    final t = SubscriptionTerms(
      status: SubscriptionStatus.trial,
      trialEndsAt: d(5, 15),
    );

    test('running: full access, days left', () {
      final s = Lifecycle.evaluate(t, d(5, 1));
      expect(s.effective, SubscriptionStatus.trial);
      expect(s.access, AccessLevel.full);
      expect(s.reason, LifecycleReason.trialRunning);
      expect(s.daysLeft, 14);
      expect(s.needsBanner, isFalse);
    });

    test('banner in the last week', () {
      final s = Lifecycle.evaluate(t, d(5, 10));
      expect(s.daysLeft, 5);
      expect(s.needsBanner, isTrue);
    });

    test('the last day still counts as 1 day', () {
      expect(Lifecycle.evaluate(t, d(5, 14, 12)).daysLeft, 1);
    });

    test('ended: read-only (synced after the end)', () {
      final s = Lifecycle.evaluate(t, d(5, 16), lastSyncedAt: d(5, 16));
      expect(s.effective, SubscriptionStatus.locked);
      expect(s.access, AccessLevel.readOnly);
      expect(s.reason, LifecycleReason.trialEnded);
      expect(s.canView, isTrue);
      expect(s.canWrite, isFalse);
    });

    test('missing end date is treated as ended', () {
      final s = Lifecycle.evaluate(
        const SubscriptionTerms(status: SubscriptionStatus.trial),
        d(5, 1),
      );
      expect(s.access, AccessLevel.readOnly);
    });
  });

  group('active -> grace -> locked', () {
    final t = SubscriptionTerms(
      status: SubscriptionStatus.active,
      currentPeriodEnd: d(6, 1),
    );

    test('inside the period', () {
      final s = Lifecycle.evaluate(t, d(5, 20));
      expect(s.effective, SubscriptionStatus.active);
      expect(s.access, AccessLevel.full);
      expect(s.needsBanner, isFalse);
    });

    test('the end moment itself is still active', () {
      expect(
        Lifecycle.evaluate(t, d(6, 1)).effective,
        SubscriptionStatus.active,
      );
    });

    test('overdue: grace with banner and full access', () {
      final s = Lifecycle.evaluate(t, d(6, 3));
      expect(s.effective, SubscriptionStatus.grace);
      expect(s.access, AccessLevel.full);
      expect(s.reason, LifecycleReason.renewalOverdue);
      expect(s.daysLeft, 5);
      expect(s.needsBanner, isTrue);
    });

    test('grace over: read-only', () {
      final s = Lifecycle.evaluate(t, d(6, 9), lastSyncedAt: d(6, 9));
      expect(s.effective, SubscriptionStatus.locked);
      expect(s.access, AccessLevel.readOnly);
      expect(s.reason, LifecycleReason.graceEnded);
    });

    test('past_due and grace behave the same by date', () {
      for (final st in [SubscriptionStatus.pastDue, SubscriptionStatus.grace]) {
        final x = SubscriptionTerms(status: st, currentPeriodEnd: d(6, 1));
        expect(
          Lifecycle.evaluate(x, d(6, 2)).effective,
          SubscriptionStatus.grace,
        );
        expect(
          Lifecycle.evaluate(x, d(6, 20), lastSyncedAt: d(6, 20)).access,
          AccessLevel.readOnly,
        );
      }
    });

    test('grace_until extends grace to an exact moment', () {
      final x = SubscriptionTerms(
        status: SubscriptionStatus.pastDue,
        currentPeriodEnd: d(6, 1),
        graceUntil: d(6, 30),
      );
      expect(Lifecycle.evaluate(x, d(6, 20)).access, AccessLevel.full);
      expect(
        Lifecycle.evaluate(x, d(7, 1), lastSyncedAt: d(7, 1)).access,
        AccessLevel.readOnly,
      );
    });

    test('a per-business grace length is used', () {
      final x = SubscriptionTerms(
        status: SubscriptionStatus.active,
        currentPeriodEnd: d(6, 1),
        graceDays: 0,
      );
      expect(
        Lifecycle.evaluate(x, d(6, 2), lastSyncedAt: d(6, 2)).access,
        AccessLevel.readOnly,
      );
    });

    test('no period end on an active plan never expires', () {
      const x = SubscriptionTerms(status: SubscriptionStatus.active);
      expect(Lifecycle.evaluate(x, d(12, 31)).access, AccessLevel.full);
    });

    test('renewal brings full access back', () {
      final renewed = SubscriptionTerms(
        status: SubscriptionStatus.active,
        currentPeriodEnd: d(7, 1),
      );
      expect(
        Lifecycle.evaluate(renewed, d(6, 9)).effective,
        SubscriptionStatus.active,
      );
    });
  });

  group('locked by the vendor', () {
    test('read-only at once, never held off by the offline rule', () {
      final s = Lifecycle.evaluate(
        const SubscriptionTerms(status: SubscriptionStatus.locked),
        d(6, 1),
      );
      expect(s.access, AccessLevel.readOnly);
      expect(s.reason, LifecycleReason.lockedByVendor);
    });
  });

  group('cancelled', () {
    final t = SubscriptionTerms(
      status: SubscriptionStatus.cancelled,
      cancelledAt: d(1, 1),
    );

    test('read-only for 90 days', () {
      final s = Lifecycle.evaluate(t, d(3, 1));
      expect(s.access, AccessLevel.readOnly);
      expect(s.reason, LifecycleReason.cancelled);
      expect(s.daysLeft, 31);
    });

    test('then export-only', () {
      final s = Lifecycle.evaluate(t, d(4, 2));
      expect(s.access, AccessLevel.exportOnly);
      expect(s.canView, isFalse);
      expect(s.reason, LifecycleReason.cancelledExpired);
    });

    test('without a cancel date it is export-only', () {
      final s = Lifecycle.evaluate(
        const SubscriptionTerms(status: SubscriptionStatus.cancelled),
        d(1, 2),
      );
      expect(s.access, AccessLevel.exportOnly);
    });
  });

  group('offline tolerance', () {
    final t = SubscriptionTerms(
      status: SubscriptionStatus.active,
      currentPeriodEnd: d(6, 1),
    );

    test('never synced since the lock: held off with a confirm banner', () {
      final s = Lifecycle.evaluate(t, d(6, 12), lastSyncedAt: d(6, 2));
      expect(s.access, AccessLevel.full);
      expect(s.reason, LifecycleReason.confirmWithServer);
      expect(s.daysLeft, 3);
      expect(s.needsBanner, isTrue);
    });

    test('after the tolerance: read-only until a sync', () {
      final s = Lifecycle.evaluate(t, d(6, 16), lastSyncedAt: d(6, 2));
      expect(s.access, AccessLevel.readOnly);
      expect(s.reason, LifecycleReason.syncRequired);
    });

    test('a device that synced after the lock moment locks exactly then', () {
      final s = Lifecycle.evaluate(t, d(6, 9), lastSyncedAt: d(6, 8, 12));
      expect(s.access, AccessLevel.readOnly);
      expect(s.reason, LifecycleReason.graceEnded);
    });

    test('never synced at all is also held off then locked', () {
      expect(Lifecycle.evaluate(t, d(6, 10)).access, AccessLevel.full);
      expect(Lifecycle.evaluate(t, d(6, 20)).access, AccessLevel.readOnly);
    });

    test('tolerance length is configurable', () {
      final s = Lifecycle.evaluate(
        t,
        d(6, 10),
        lastSyncedAt: d(6, 2),
        offlineToleranceDays: 1,
      );
      expect(s.access, AccessLevel.readOnly);
    });

    test('inside the paid period offline changes nothing', () {
      final s = Lifecycle.evaluate(t, d(5, 20), lastSyncedAt: d(5, 1));
      expect(s.reason, LifecycleReason.none);
    });
  });

  test('status wire names round trip', () {
    for (final s in SubscriptionStatus.values) {
      expect(SubscriptionStatus.parse(s.wire), s);
    }
    expect(SubscriptionStatus.parse('weird'), SubscriptionStatus.locked);
    expect(SubscriptionStatus.parse(null), SubscriptionStatus.locked);
  });
}
