import 'package:meta/meta.dart';

/// Stored status of a subscription.
enum SubscriptionStatus {
  trial,
  active,
  pastDue,
  grace,
  locked,
  cancelled;

  static SubscriptionStatus parse(String? value) => switch (value) {
    'trial' => trial,
    'active' => active,
    'past_due' => pastDue,
    'grace' => grace,
    'locked' => locked,
    'cancelled' => cancelled,
    _ => locked,
  };

  String get wire => switch (this) {
    pastDue => 'past_due',
    _ => name,
  };
}

/// What the business may do right now.
enum AccessLevel {
  /// Everything its plan allows.
  full,

  /// View, search, print and export; nothing new is written.
  readOnly,

  /// Only export (and sign-out / billing).
  exportOnly,
}

/// Why the state is what it is, for the banner.
enum LifecycleReason {
  none,
  trialRunning,
  trialEnded,
  renewalOverdue,
  graceEnded,
  lockedByVendor,
  cancelled,
  cancelledExpired,
  confirmWithServer,
  syncRequired,
}

/// The subscription fields the lifecycle needs.
@immutable
final class SubscriptionTerms {
  const SubscriptionTerms({
    required this.status,
    this.trialEndsAt,
    this.currentPeriodEnd,
    this.graceDays = 7,
    this.graceUntil,
    this.cancelledAt,
    this.cancelledReadOnlyDays = 90,
  });

  final SubscriptionStatus status;
  final DateTime? trialEndsAt;

  /// Null on an active plan = no end (a complimentary account).
  final DateTime? currentPeriodEnd;
  final int graceDays;

  /// Set by the super-admin to extend grace to an exact moment.
  final DateTime? graceUntil;
  final DateTime? cancelledAt;
  final int cancelledReadOnlyDays;

  /// When full access ends for an unpaid plan.
  DateTime? get graceEnd =>
      graceUntil ?? currentPeriodEnd?.add(Duration(days: graceDays));
}

/// The evaluated state.
@immutable
final class LifecycleState {
  const LifecycleState({
    required this.effective,
    required this.access,
    required this.reason,
    this.daysLeft,
    this.endsAt,
  });

  /// `trial`, `active`, `grace`, `locked` or `cancelled`.
  final SubscriptionStatus effective;
  final AccessLevel access;
  final LifecycleReason reason;

  /// Whole days until the next change (trial end, grace end), if any.
  final int? daysLeft;
  final DateTime? endsAt;

  bool get canWrite => access == AccessLevel.full;
  bool get canView => access != AccessLevel.exportOnly;

  /// Whether the app should show a banner.
  bool get needsBanner => switch (reason) {
    LifecycleReason.none => false,
    LifecycleReason.trialRunning => (daysLeft ?? 99) <= 7,
    _ => true,
  };

  @override
  bool operator ==(Object other) =>
      other is LifecycleState &&
      other.effective == effective &&
      other.access == access &&
      other.reason == reason &&
      other.daysLeft == daysLeft;

  @override
  int get hashCode => Object.hash(effective, access, reason, daysLeft);

  @override
  String toString() =>
      'LifecycleState($effective, $access, $reason, $daysLeft)';
}

/// Trial, grace, lock (docs/domain/saas-rules.md section 3).
abstract final class Lifecycle {
  static const _day = Duration(days: 1);

  static int _daysUntil(DateTime to, DateTime now) {
    final d = to.difference(now);
    if (d.isNegative) return 0;
    return (d.inHours / 24).ceil();
  }

  /// The state at [now].
  ///
  /// [lastSyncedAt] and [offlineToleranceDays] implement the offline rule:
  /// a time-based lock that the device may not know about yet (it has not
  /// synced since) is held off for the tolerance, then becomes read-only
  /// until the next sync. A lock the server stored (`locked`, `cancelled`)
  /// is never held off: the device already knows it.
  static LifecycleState evaluate(
    SubscriptionTerms t,
    DateTime now, {
    DateTime? lastSyncedAt,
    int offlineToleranceDays = 7,
  }) {
    final base = _byDates(t, now);
    if (base.access == AccessLevel.full) return base;
    final lockMoment = _timeLockMoment(t);
    final timeBased =
        lockMoment != null &&
        (t.status == SubscriptionStatus.trial ||
            t.status == SubscriptionStatus.active ||
            t.status == SubscriptionStatus.pastDue ||
            t.status == SubscriptionStatus.grace);
    if (!timeBased) return base;
    final knowsLock =
        lastSyncedAt != null && !lastSyncedAt.isBefore(lockMoment);
    if (knowsLock) return base;
    final toleranceEnd = lockMoment.add(_day * offlineToleranceDays);
    if (now.isBefore(toleranceEnd)) {
      return LifecycleState(
        effective: SubscriptionStatus.grace,
        access: AccessLevel.full,
        reason: LifecycleReason.confirmWithServer,
        daysLeft: _daysUntil(toleranceEnd, now),
        endsAt: toleranceEnd,
      );
    }
    return LifecycleState(
      effective: SubscriptionStatus.locked,
      access: AccessLevel.readOnly,
      reason: LifecycleReason.syncRequired,
      endsAt: toleranceEnd,
    );
  }

  /// When a date-based lock starts, null if the status never locks by date.
  static DateTime? _timeLockMoment(SubscriptionTerms t) =>
      t.status == SubscriptionStatus.trial ? t.trialEndsAt : t.graceEnd;

  static LifecycleState _byDates(SubscriptionTerms t, DateTime now) {
    switch (t.status) {
      case SubscriptionStatus.trial:
        final end = t.trialEndsAt;
        if (end == null || !now.isBefore(end)) {
          return const LifecycleState(
            effective: SubscriptionStatus.locked,
            access: AccessLevel.readOnly,
            reason: LifecycleReason.trialEnded,
          );
        }
        return LifecycleState(
          effective: SubscriptionStatus.trial,
          access: AccessLevel.full,
          reason: LifecycleReason.trialRunning,
          daysLeft: _daysUntil(end, now),
          endsAt: end,
        );
      case SubscriptionStatus.active:
      case SubscriptionStatus.pastDue:
      case SubscriptionStatus.grace:
        final periodEnd = t.currentPeriodEnd;
        final graceEnd = t.graceEnd;
        if (t.status == SubscriptionStatus.active &&
            (periodEnd == null || !now.isAfter(periodEnd))) {
          return LifecycleState(
            effective: SubscriptionStatus.active,
            access: AccessLevel.full,
            reason: LifecycleReason.none,
            endsAt: periodEnd,
          );
        }
        // Overdue (or flagged past due / grace by billing).
        if (graceEnd == null || now.isBefore(graceEnd)) {
          return LifecycleState(
            effective: SubscriptionStatus.grace,
            access: AccessLevel.full,
            reason: LifecycleReason.renewalOverdue,
            daysLeft: graceEnd == null ? null : _daysUntil(graceEnd, now),
            endsAt: graceEnd,
          );
        }
        return LifecycleState(
          effective: SubscriptionStatus.locked,
          access: AccessLevel.readOnly,
          reason: LifecycleReason.graceEnded,
          endsAt: graceEnd,
        );
      case SubscriptionStatus.locked:
        return const LifecycleState(
          effective: SubscriptionStatus.locked,
          access: AccessLevel.readOnly,
          reason: LifecycleReason.lockedByVendor,
        );
      case SubscriptionStatus.cancelled:
        final at = t.cancelledAt;
        final until = at?.add(_day * t.cancelledReadOnlyDays);
        if (until != null && now.isBefore(until)) {
          return LifecycleState(
            effective: SubscriptionStatus.cancelled,
            access: AccessLevel.readOnly,
            reason: LifecycleReason.cancelled,
            daysLeft: _daysUntil(until, now),
            endsAt: until,
          );
        }
        return const LifecycleState(
          effective: SubscriptionStatus.cancelled,
          access: AccessLevel.exportOnly,
          reason: LifecycleReason.cancelledExpired,
        );
    }
  }
}
