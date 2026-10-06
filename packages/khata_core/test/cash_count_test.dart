import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  test('total, difference and JSON', () {
    final c = CashCount(const {
      500: 20,
      100: 7,
      10: 3,
      1: 4,
    }, loose: const Money(50));
    // 10,000 + 700 + 30 + 4 + 0.50
    expect(c.total, const Money(1073450));
    expect(c.difference(const Money.rupees(10734)), const Money(50));
    expect(c.difference(const Money.rupees(10800)), const Money(-6550));
    final back = CashCount.fromJson(c.toJson());
    expect(back.total, c.total);
    expect(c.toJson(), {'500': 20, '100': 7, '10': 3, '1': 4, 'loose': 50});
    expect(CashCount(const {}).total, Money.zero);
    expect(
      CashCount.fromJson(const {'500': 'x', 'loose': 'y'}).total,
      Money.zero,
    );
  });

  test('refuses unknown notes and negative counts', () {
    expect(() => CashCount(const {2000: 1}), throwsArgumentError);
    expect(() => CashCount(const {500: -1}), throwsArgumentError);
    expect(
      () => CashCount(const {}, loose: const Money(-1)),
      throwsArgumentError,
    );
  });
}
