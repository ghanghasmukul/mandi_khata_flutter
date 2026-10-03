import 'package:decimal/decimal.dart';
import 'package:khata_core/src/ledger.dart';

/// Digits kept when a division does not end (one slab of interest is
/// `principal x rate x days / (100 x basis)`; /365 never ends). 20 digits is
/// far below a paise, and slab values are never rounded one by one.
const _scale = 20;

final Decimal _half = Decimal.parse('0.5');

Decimal divide(Decimal a, Decimal b) =>
    (a / b).toDecimal(scaleOnInfinitePrecision: _scale);

/// Round [value] (>= 0, in paise) half-up to a multiple of [unitPaise].
int roundHalfUp(Decimal value, [int unitPaise = 1]) {
  final units = divide(value, Decimal.fromInt(unitPaise));
  return (units + _half).floor().toBigInt().toInt() * unitPaise;
}

int roundHalfUpPaise(Decimal value) => roundHalfUp(value);

/// [months] after [anchor], always counted from the anchor so the day never
/// drifts; a day that does not exist (31 + 1 month) becomes the month's last.
LedgerDate addMonths(LedgerDate anchor, int months) {
  final index = anchor.year * 12 + (anchor.month - 1) + months;
  final year = index ~/ 12;
  final month = index % 12 + 1;
  final lastDay = DateTime.utc(year, month + 1, 0).day;
  return LedgerDate(year, month, anchor.day < lastDay ? anchor.day : lastDay);
}
