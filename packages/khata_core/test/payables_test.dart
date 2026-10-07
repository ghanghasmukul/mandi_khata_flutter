import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

PayableBill bill(
  String id, {
  String supplier = 's1',
  required int rupees,
  required LedgerDate due,
  int credit = 0,
}) => PayableBill(
  purchaseId: id,
  supplierId: supplier,
  invoiceDate: due.addDays(-30),
  dueDate: due,
  booked: Money.rupees(rupees),
  creditNote: Money.rupees(credit),
);

void main() {
  final today = LedgerDate(2027, 5, 20);

  test('no payments: every bill is open, overdue days from the due date', () {
    final r = Payables.derive(
      bills: [
        bill('a', rupees: 1000, due: LedgerDate(2027, 5, 10)),
        bill('b', rupees: 500, due: LedgerDate(2027, 6, 1)),
      ],
      paidBySupplier: const {},
      today: today,
    );
    expect(r, hasLength(1));
    expect(r.single.outstanding, const Money.rupees(1500));
    expect(r.single.dueDate, LedgerDate(2027, 5, 10));
    expect(r.single.overdueDays, 10);
    expect(r.single.bills.map((b) => b.overdueDays), [10, 0]);
  });

  test('payments are allocated FIFO by due date, not by entry order', () {
    final r = Payables.derive(
      bills: [
        bill('late', rupees: 1000, due: LedgerDate(2027, 6, 30)),
        bill('early', rupees: 1000, due: LedgerDate(2027, 5, 1)),
      ],
      paidBySupplier: {'s1': const Money.rupees(1400)},
      today: today,
    );
    final s = r.single;
    expect(s.outstanding, const Money.rupees(600));
    // "early" is settled, "late" has 600 left.
    expect(s.bills.single.bill.purchaseId, 'late');
    expect(s.bills.single.outstanding, const Money.rupees(600));
    expect(s.overdueDays, 0);
  });

  test('a credit note reduces its own bill first; any excess is a payment', () {
    final r = Payables.derive(
      bills: [
        bill('a', rupees: 1000, due: LedgerDate(2027, 5, 1), credit: 300),
        bill('b', rupees: 400, due: LedgerDate(2027, 5, 2), credit: 500),
      ],
      paidBySupplier: const {},
      today: today,
    );
    // a: 700 left; b: settled, 100 excess goes to a -> 600.
    expect(r.single.outstanding, const Money.rupees(600));
    expect(r.single.bills.single.bill.purchaseId, 'a');
  });

  test('fully settled suppliers disappear; advances show nothing', () {
    final r = Payables.derive(
      bills: [bill('a', rupees: 1000, due: LedgerDate(2027, 5, 1))],
      paidBySupplier: {'s1': const Money.rupees(5000)},
      today: today,
    );
    expect(r, isEmpty);
  });

  test('suppliers are independent and sorted by earliest due date', () {
    final r = Payables.derive(
      bills: [
        bill('a', supplier: 's1', rupees: 100, due: LedgerDate(2027, 7, 1)),
        bill('b', supplier: 's2', rupees: 200, due: LedgerDate(2027, 6, 1)),
      ],
      paidBySupplier: {'s1': const Money.rupees(50)},
      today: today,
    );
    expect(r.map((s) => s.supplierId), ['s2', 's1']);
    expect(r.last.outstanding, const Money.rupees(50));
  });
}
