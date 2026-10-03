// Device benchmark: 5,000 parties + 50,000 ledger entries on the real local
// database of the device it runs on. Prints the timings; fails when a list /
// search is over 100 ms or a report over 2 s.
//
//   flutter test integration_test/performance_test.dart -d emulator-5554
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

import 'support/perf_bench.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('5k parties + 50k entries: lists < 100 ms, reports < 2 s', (
    tester,
  ) async {
    const tenant = '11111111-1111-4111-8111-111111111111';
    final name = 'perf_${const Uuid().v4()}.db';
    final path = kIsWeb
        ? name
        : p.join((await getTemporaryDirectory()).path, name);
    final db = PowerSyncDatabase(schema: powerSyncSchema, path: path);
    await db.initialize();
    addTearDown(db.close);

    final seeding = Stopwatch()..start();
    await seedBench(db, tenant);
    debugPrint(
      'PERF seeded $benchEntries entries in ${seeding.elapsedMilliseconds} ms',
    );
    final timings = await runBench(db, tenant);
    for (final t in timings) {
      debugPrint('PERF $t');
    }

    final over = timings.where((t) => !t.ok).toList();
    expect(over, isEmpty, reason: 'over budget: ${over.join('\n')}');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
