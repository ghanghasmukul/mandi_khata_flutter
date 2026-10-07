import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  test('mulDivRound is half-up away from zero and exact for big numbers', () {
    expect(ShopMath.mulDivRound(5, 1, 2), 3);
    expect(ShopMath.mulDivRound(-5, 1, 2), -3);
    expect(ShopMath.mulDivRound(4, 1, 3), 1);
    expect(
      ShopMath.mulDivRound(1000000000000, 1000000000000, 1000000000000),
      1000000000000,
    );
    expect(() => ShopMath.mulDivRound(1, 1, 0), throwsArgumentError);
  });

  test('mulDivFloor', () {
    expect(ShopMath.mulDivFloor(7, 1, 2), 3);
    expect(() => ShopMath.mulDivFloor(1, 1, 0), throwsArgumentError);
  });

  test('valueOf: price per unit x milli', () {
    expect(ShopMath.valueOf(const Money(9999), 2500), const Money(24998));
  });

  test('apportion: largest remainder, ties to the earlier entry', () {
    expect(ShopMath.apportion(10, [1, 1, 1]), [4, 3, 3]);
    expect(ShopMath.apportion(100, [50, 30, 20]), [50, 30, 20]);
    expect(ShopMath.apportion(1, [3, 5, 2]), [0, 1, 0]);
    expect(ShopMath.apportion(0, [3, 5]), [0, 0]);
    expect(ShopMath.apportion(7, [0, 5]), [0, 7]);
    expect(() => ShopMath.apportion(-1, [1]), throwsArgumentError);
    expect(() => ShopMath.apportion(5, [0, 0]), throwsArgumentError);
    expect(() => ShopMath.apportion(5, [-1, 3]), throwsArgumentError);
  });

  test('apportion always adds up', () {
    for (var total = 0; total < 300; total += 7) {
      final shares = ShopMath.apportion(total, [13, 1, 97, 5, 44]);
      expect(shares.fold(0, (a, b) => a + b), total);
    }
  });

  test('proportional: the completing share takes the remainder', () {
    expect(
      ShopMath.proportional(total: 1000, partMilli: 1, wholeMilli: 3),
      333,
    );
    expect(
      ShopMath.proportional(
        total: 1000,
        partMilli: 2,
        wholeMilli: 3,
        doneMilli: 1,
        doneAmount: 333,
      ),
      667,
    );
  });
}
