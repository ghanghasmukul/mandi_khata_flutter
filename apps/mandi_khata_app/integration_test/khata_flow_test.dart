// Device test: the Phase 1 day on the real local database of the platform it
// runs on (Android emulator / phone, macOS, Chrome). No server needed: it
// proves the offline half. The upload half is `test/hardening/` (fake and
// local-stack servers).
//
//   flutter test integration_test/khata_flow_test.dart -d emulator-5554
//   flutter test integration_test/khata_flow_test.dart -d macos
//   # Chrome needs chromedriver:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/khata_flow_test.dart -d chrome
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

import 'support/khata_flow.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('farmer -> arrival -> post -> payment -> statement (offline)', (
    tester,
  ) async {
    final tenant = const Uuid().v4();
    final name = 'it_${const Uuid().v4()}.db';
    final path = kIsWeb
        ? name
        : p.join((await getTemporaryDirectory()).path, name);
    final db = PowerSyncDatabase(schema: powerSyncSchema, path: path);
    await db.initialize();
    addTearDown(db.close);

    await seedBusiness(db, tenant);
    final ctx = WriteContext(
      tenantId: tenant,
      userId: const Uuid().v4(),
      deviceId: const Uuid().v4(),
      deviceCode: 'W1',
    );
    final result = await runKhataFlow(
      db,
      ctx,
      now: DateTime.utc(2026, 4, 10, 6),
    );
    expect(result.closing, const Money(1483276));

    // Nothing was sent: the whole day waits in the upload queue.
    final queued = await db.getAll('SELECT COUNT(*) AS n FROM ps_crud');
    expect(queued.single['n']! as int, greaterThan(0));
  });
}
