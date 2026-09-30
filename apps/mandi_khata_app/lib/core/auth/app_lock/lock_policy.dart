/// App-lock timing rules. Device behaviour, not business configuration, so
/// they are constants rather than settings.
abstract final class LockPolicy {
  /// Lock again after the app has been in the background this long.
  static const backgroundTimeout = Duration(minutes: 2);

  /// Wrong PINs allowed before a cooldown starts.
  static const freeAttempts = 5;

  static const _firstCooldown = Duration(seconds: 30);
  static const _maxCooldown = Duration(minutes: 15);

  /// Wait imposed after [failures] wrong PINs in a row: none for the first
  /// [freeAttempts], then 30 s doubling each time, capped at 15 min.
  static Duration cooldownAfter(int failures) {
    if (failures < freeAttempts) return Duration.zero;
    final doublings = failures - freeAttempts;
    if (doublings >= 5) return _maxCooldown;
    final wait = _firstCooldown * (1 << doublings);
    return wait > _maxCooldown ? _maxCooldown : wait;
  }

  /// Whether returning to the foreground after [away] should lock.
  static bool shouldLockAfter(Duration away) => away >= backgroundTimeout;
}
