import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/auth/phone_number.dart';

void main() {
  group('normaliseIndianMobile', () {
    for (final input in [
      '9814022110',
      '98140 22110',
      '98140-22110',
      '+91 98140 22110',
      '+919814022110',
      '919814022110',
      '09814022110',
      ' (98140) 22110 ',
    ]) {
      test('accepts "$input"', () {
        expect(normaliseIndianMobile(input), '+919814022110');
      });
    }

    for (final input in [
      '',
      '12345',
      '5814022110', // mobiles start 6–9
      '98140221101', // 11 digits, no leading 0
      '+1 9814022110',
      '98140abc10',
      '+91981402211',
    ]) {
      test('rejects "$input"', () {
        expect(normaliseIndianMobile(input), isNull);
      });
    }
  });

  test('formatIndianMobile groups 5 + 5', () {
    expect(formatIndianMobile('+919814022110'), '+91 98140 22110');
    expect(formatIndianMobile('someone@x.in'), 'someone@x.in');
  });
}
