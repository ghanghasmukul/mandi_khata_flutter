import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';

LedgerDate d(String iso) => LedgerDate.parse(iso);

int rupees(num r) => (r * 100).round();

var _seq = 0;

LedgerEvent udhaar(String date, int rupeesAmount, {DateTime? createdAt}) =>
    LedgerEvent(
      id: 'e${_seq++}',
      date: d(date),
      side: Side.udhaar,
      amountPaise: rupees(rupeesAmount),
      createdAt: createdAt,
    );

LedgerEvent jama(String date, int rupeesAmount, {DateTime? createdAt}) =>
    LedgerEvent(
      id: 'e${_seq++}',
      date: d(date),
      side: Side.jama,
      amountPaise: rupees(rupeesAmount),
      createdAt: createdAt,
    );

/// Paise rounding so worked examples show exact figures.
InterestConfig cfg({
  String rate = '18',
  InterestMethod method = InterestMethod.simple,
  CompoundingPeriod compounding = CompoundingPeriod.quarterly,
  int dayBasis = 365,
  int graceDays = 0,
  Appropriation appropriation = Appropriation.interestFirst,
  ApplyOn applyOn = ApplyOn.netUdhaar,
  int minDays = 0,
  InterestRounding rounding = InterestRounding.paise,
  bool payOnJama = false,
  String payRate = '0',
  bool enabled = true,
}) => InterestConfig(
  ratePa: Decimal.parse(rate),
  method: method,
  compounding: compounding,
  dayBasis: dayBasis,
  graceDays: graceDays,
  appropriation: appropriation,
  applyOn: applyOn,
  minDays: minDays,
  rounding: rounding,
  payOnJama: payOnJama,
  payRatePa: Decimal.parse(payRate),
  enabled: enabled,
);
