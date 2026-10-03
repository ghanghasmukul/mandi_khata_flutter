import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:powersync/powersync.dart';

import '../../integration_test/support/perf_bench.dart';

const tenant = '11111111-1111-4111-8111-111111111111';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_perf_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test(
    '5k parties + 50k ledger rows: lists and search < 100 ms, reports < 2 s',
    () async {
      final seeding = Stopwatch()..start();
      await seedBench(db, tenant);
      // ignore: avoid_print — the numbers are the point of this test.
      print(
        'seeded $benchEntries entries in ${seeding.elapsedMilliseconds} ms',
      );

      final timings = await runBench(db, tenant);
      // ignore: avoid_print — see above.
      timings.forEach(print);

      // Shared CI runners are slower than a laptop: MK_PERF_SLACK scales the
      // budgets there (CI sets 3). Locally the budgets are exact.
      final slack =
          int.tryParse(Platform.environment['MK_PERF_SLACK'] ?? '') ?? 1;
      final over = timings.where((t) => t.worst >= t.budget * slack).toList();
      expect(over, isEmpty, reason: 'over budget: ${over.join('\n')}');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
