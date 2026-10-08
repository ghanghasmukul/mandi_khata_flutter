import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/features/products/domain/batch_ids.dart';

void main() {
  test('two devices derive the same batch id; inputs change it', () {
    final deviceA = BatchIds.of('t1', 'p1', 'B-1');
    final deviceB = BatchIds.of('t1', 'p1', 'B-1');
    expect(deviceA, deviceB);
    expect(BatchIds.of('t2', 'p1', 'B-1'), isNot(deviceA));
    expect(BatchIds.of('t1', 'p2', 'B-1'), isNot(deviceA));
    expect(BatchIds.of('t1', 'p1', 'B-2'), isNot(deviceA));
  });
}
