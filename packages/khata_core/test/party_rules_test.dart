import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('IndianMobile.normalise → 10 digits', () {
    for (final input in [
      '9814022110',
      '98140 22110',
      '+91 98140-22110',
      '919814022110',
      '09814022110',
    ]) {
      test('accepts "$input"', () {
        expect(IndianMobile.normalise(input), '9814022110');
      });
    }
    for (final input in ['', '5814022110', '98140221', '+1 9814022110']) {
      test('rejects "$input"', () {
        expect(IndianMobile.normalise(input), isNull);
      });
    }
  });

  group('Ifsc', () {
    test('uppercases and checks the format (5th character 0)', () {
      expect(Ifsc.normalise(' sbin0001234 '), 'SBIN0001234');
      expect(Ifsc.normalise('PUNB0ABC123'), 'PUNB0ABC123');
      expect(Ifsc.normalise('SBIN1001234'), isNull);
      expect(Ifsc.normalise('SBI0001234'), isNull);
      expect(Ifsc.normalise('SBIN00012345'), isNull);
    });
  });

  group('Gstin', () {
    // Real-format GSTINs with valid check digits.
    test('accepts valid numbers (checksum)', () {
      expect(Gstin.normalise('27AAPFU0939F1ZV'), '27AAPFU0939F1ZV');
      expect(Gstin.normalise('29aagcr4375j1zu'), '29AAGCR4375J1ZU');
    });

    test('rejects a wrong check digit or format', () {
      expect(Gstin.normalise('27AAPFU0939F1ZW'), isNull);
      expect(Gstin.normalise('27AAPFU0939F1Z'), isNull);
      expect(Gstin.normalise('AAAPFU0939F1ZV1'), isNull);
    });

    test('check digit', () {
      expect(Gstin.checkDigit('27AAPFU0939F1Z'), 'V');
    });
  });

  group('enums match the database checks', () {
    test('party roles', () {
      expect(PartyRole.values.map((r) => r.name), [
        'farmer',
        'customer',
        'supplier',
        'vendor',
        'agency',
        'buyer',
      ]);
      expect(PartyRole.parse('vendor'), PartyRole.vendor);
      expect(PartyRole.parse('alien'), isNull);
      expect(PartyRole.values.map((r) => r.name), SettingsSchema.partyRoles);
    });

    test('relations', () {
      expect(Relation.values.map((r) => r.dbName), [
        's_o',
        'd_o',
        'w_o',
        'prop',
      ]);
      expect(Relation.parse('w_o'), Relation.wifeOf);
      expect(Relation.parse(null), isNull);
    });
  });

  group('PartyInput.validate', () {
    PartyInput valid() => const PartyInput(
      code: 'F-101',
      name: 'Gurmeet Singh',
      roles: {PartyRole.farmer},
    );

    test('a minimal party is valid', () {
      expect(valid().validate(), isEmpty);
    });

    test('code, name and at least one role are required', () {
      const input = PartyInput(code: ' ', name: '', roles: {});
      expect(input.validate(), {
        PartyField.code: PartyFieldError.required,
        PartyField.name: PartyFieldError.required,
        PartyField.roles: PartyFieldError.required,
      });
    });

    test('formats are checked only when filled in', () {
      final input = valid().copyWith(
        mobile: '12345',
        altMobile: '98140 22110',
        ifsc: 'SBIN1',
        gstin: '27AAPFU0939F1ZW',
        aadhaarLast4: '12a4',
      );
      expect(input.validate(), {
        PartyField.mobile: PartyFieldError.invalid,
        PartyField.ifsc: PartyFieldError.invalid,
        PartyField.gstin: PartyFieldError.invalid,
        PartyField.aadhaarLast4: PartyFieldError.invalid,
      });
    });

    test('a relation needs the father / husband name, except prop', () {
      expect(valid().copyWith(relation: Relation.sonOf).validate(), {
        PartyField.fatherOrHusbandName: PartyFieldError.required,
      });
      expect(
        valid()
            .copyWith(relation: Relation.sonOf, fatherOrHusbandName: 'Bachan')
            .validate(),
        isEmpty,
      );
      expect(
        valid().copyWith(relation: Relation.proprietor).validate(),
        isEmpty,
      );
    });

    test('normalised() cleans what will be stored', () {
      final n = valid()
          .copyWith(
            name: '  Gurmeet   Singh ',
            mobile: '+91 98140-22110',
            ifsc: 'sbin0001234',
            gstin: '27aapfu0939f1zv',
            village: '  ',
            bankAccount: '0012 3456 7890',
          )
          .normalised();
      expect(n.name, 'Gurmeet Singh');
      expect(n.mobile, '9814022110');
      expect(n.ifsc, 'SBIN0001234');
      expect(n.gstin, '27AAPFU0939F1ZV');
      expect(n.village, isNull);
      // Only the last 4 digits of a bank account are ever stored.
      expect(n.bankAccount, 'XXXX7890');
    });

    test('bank account masking', () {
      expect(maskBankAccount('0012 3456 7890'), 'XXXX7890');
      expect(maskBankAccount('XXXX7890'), 'XXXX7890');
      expect(maskBankAccount('12'), 'XXXX12');
      expect(maskBankAccount(' '), isNull);
    });
  });
}
