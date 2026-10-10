import 'package:flutter_test/flutter_test.dart';
import 'package:mk_admin/src/sync_health_screen.dart';

void main() {
  final now = DateTime(2027, 4, 10);

  test('lag is written in words', () {
    expect(lagText(null), '–');
    expect(lagText(45), '45s');
    expect(lagText(600), '10 min');
    expect(lagText(7200), '2 h');
    expect(lagText(3 * 86400), '3 d');
  });

  test('a business needs attention when lag, late share or silence say so', () {
    bool warn({
      int entries = 100,
      int? p95 = 30,
      int late = 0,
      DateTime? seen,
    }) => needsAttention(
      entries: entries,
      lagP95: p95,
      late: late,
      lastSeen: seen ?? now,
      now: now,
    );
    expect(warn(), isFalse);
    expect(warn(p95: 7200), isTrue, reason: '95% waited over an hour');
    expect(warn(late: 25), isTrue, reason: 'a quarter were late');
    expect(warn(late: 10), isFalse);
    expect(warn(seen: DateTime(2027, 4)), isTrue, reason: 'silent 9 days');
    expect(warn(entries: 0, p95: null), isFalse, reason: 'no entries, no lag');
  });
}
