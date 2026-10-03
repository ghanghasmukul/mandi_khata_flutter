import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

OpeningPreview _preview(
  String csv, {
  List<ExistingParty> existing = const [],
  Side? defaultSide = Side.udhaar,
  PartyRole role = PartyRole.farmer,
}) => OpeningBalanceImport.preview(
  DelimitedText.parse(csv),
  existing: existing,
  defaultSide: defaultSide,
  defaultRole: role,
);

void main() {
  group('parseAmount', () {
    test('plain, Indian grouping, rupee sign, paise', () {
      expect(
        OpeningBalanceImport.parseAmount('1,55,580').amount,
        const Money(15558000),
      );
      expect(
        OpeningBalanceImport.parseAmount('₹1,109.5').amount,
        const Money(110950),
      );
      expect(
        OpeningBalanceImport.parseAmount('Rs. 400/-').amount,
        const Money(40000),
      );
      expect(OpeningBalanceImport.parseAmount('0').amount, Money.zero);
    });

    test('Dr / Cr before or after the number gives the side', () {
      final a = OpeningBalanceImport.parseAmount('15,000 Dr');
      expect((a.amount, a.side), (const Money(1500000), Side.udhaar));
      final b = OpeningBalanceImport.parseAmount('Cr 400.50');
      expect((b.amount, b.side), (const Money(40050), Side.jama));
      expect(OpeningBalanceImport.parseAmount('250 jama').side, Side.jama);
    });

    test('blank is no amount, junk and 3 decimals are invalid', () {
      expect(OpeningBalanceImport.parseAmount('  ').amount, isNull);
      expect(OpeningBalanceImport.parseAmount('  ').error, isNull);
      expect(
        OpeningBalanceImport.parseAmount('abc').error,
        OpeningRowError.amountInvalid,
      );
      expect(
        OpeningBalanceImport.parseAmount('12.345').error,
        OpeningRowError.amountInvalid,
      );
      expect(
        OpeningBalanceImport.parseAmount('1,2,3,x').error,
        OpeningRowError.amountInvalid,
      );
    });

    test('negative amounts are rejected, never flipped', () {
      expect(
        OpeningBalanceImport.parseAmount('-500').error,
        OpeningRowError.amountNegative,
      );
      expect(
        OpeningBalanceImport.parseAmount('(500)').error,
        OpeningRowError.amountNegative,
      );
    });
  });

  group('columns', () {
    test('English, Hindi and Punjabi headers are recognised', () {
      final en = DelimitedText.parse('Party Name,Gaon,Mobile No,Baki,Dr/Cr\n');
      expect(OpeningBalanceImport.detectColumns(en.rows.first), {
        OpeningColumn.name: 0,
        OpeningColumn.village: 1,
        OpeningColumn.mobile: 2,
        OpeningColumn.amount: 3,
        OpeningColumn.side: 4,
      });
      final hi = DelimitedText.parse('नाम,गांव,बाकी\n');
      expect(
        OpeningBalanceImport.detectColumns(hi.rows.first)!.keys,
        containsAll([
          OpeningColumn.name,
          OpeningColumn.village,
          OpeningColumn.amount,
        ]),
      );
      final pa = DelimitedText.parse('ਨਾਮ,ਪਿੰਡ,ਬਕਾਇਆ\n');
      expect(OpeningBalanceImport.detectColumns(pa.rows.first), hasLength(3));
    });

    test('no name column or no amount column is a file problem', () {
      expect(
        _preview('Village,Amount\nRampura,100\n').problem,
        SheetProblem.noNameColumn,
      );
      expect(
        _preview('Name,Village\nRamesh,Rampura\n').problem,
        SheetProblem.noAmountColumn,
      );
      expect(_preview('').problem, SheetProblem.empty);
    });

    test('more than the row limit is refused', () {
      final rows = StringBuffer('Name,Amount\n');
      for (var i = 0; i <= OpeningBalanceImport.maxRows; i++) {
        rows.writeln('P$i,1');
      }
      expect(_preview(rows.toString()).problem, SheetProblem.tooManyRows);
    });
  });

  group('worked example: a small arhtiya file', () {
    // Udhaar: Ramesh 15,000 + Gurmeet 2,500.50 = 17,500.50
    // Jama: Sita 4,000 + Kulwant 1,250 = 5,250.00
    // Net (jama - udhaar) = -12,250.50: the arhtiya is owed that overall.
    const csv =
        'Name,Father,Village,Mobile,Amount,Type\n'
        'Ramesh Kumar,Mohan Lal,Rampura,98140 22110,"15,000",Udhaar\n'
        'Sita Devi,,Rampura,,4000,Cr\n'
        'Gurmeet Singh,Harbans Singh,Nabha,+91 98765-43210,"2,500.50",Dr\n'
        'Kulwant,,Bhadaur,,1250,Jama\n'
        'Balbir,,,,,\n';

    test('totals, counts and sides', () {
      final p = _preview(csv);
      expect(p.problem, isNull);
      expect(p.rows, hasLength(5));
      expect(p.invalid, isEmpty);
      expect(p.newParties, 5);
      expect(p.entries, 4);
      expect(p.totalUdhaar, const Money(1750050));
      expect(p.totalJama, const Money(525000));
      expect(p.net, const Money(-1225050));
      expect(p.rows[0].mobile, '9814022110');
      expect(p.rows[2].mobile, '9876543210');
      expect(p.rows[0].fatherName, 'Mohan Lal');
      expect(p.rows[0].role, PartyRole.farmer);
      expect(p.rows[0].signed, const Money(-1500000));
      expect(p.rows[1].signed, const Money(400000));
    });

    test('a party with no amount is added without an entry', () {
      final r = _preview(csv).rows.last;
      expect(r.errors, isEmpty);
      expect(r.warnings, [OpeningRowWarning.noAmount]);
      expect(r.postsEntry, isFalse);
      expect(r.createsParty, isTrue);
      expect(r.number, 6);
    });

    test('the fingerprint is the same for the same rows', () {
      expect(_preview(csv).fingerprint, _preview(csv).fingerprint);
      expect(
        _preview(csv).fingerprint,
        isNot(_preview(csv.replaceAll('4000', '4001')).fingerprint),
      );
    });
  });

  group('side is never guessed', () {
    test('an amount with no side is an error until a default is chosen', () {
      const csv = 'Name,Baki\nRamesh,500\nSita,"1,200"\n';
      final none = _preview(csv, defaultSide: null);
      expect(
        none.rows.map((r) => r.errors),
        everyElement([OpeningRowError.sideMissing]),
      );
      expect(none.canImport, isFalse);

      final udhaar = _preview(csv);
      expect(udhaar.invalid, isEmpty);
      expect(udhaar.totalUdhaar, const Money(170000));
      expect(udhaar.totalJama, Money.zero);

      final jama = _preview(csv, defaultSide: Side.jama);
      expect(jama.totalJama, const Money(170000));
    });

    test('a Dr / Cr suffix or side column beats the default', () {
      final p = _preview('Name,Baki\nRamesh,500 Cr\nSita,300\n');
      expect(p.rows[0].side, Side.jama);
      expect(p.rows[1].side, Side.udhaar);
    });

    test('separate udhaar and jama columns', () {
      final p = _preview(
        'Party,Udhaar,Jama\nRamesh,500,\nSita,,300\nBoth,10,20\nNone,,\n',
      );
      expect(p.rows[0].side, Side.udhaar);
      expect(p.rows[1].side, Side.jama);
      expect(p.rows[2].errors, [OpeningRowError.sideConflict]);
      expect(p.rows[3].warnings, [OpeningRowWarning.noAmount]);
    });

    test('an unknown side word is an error', () {
      final p = _preview('Name,Amount,Type\nRamesh,500,maybe\n');
      expect(p.rows.single.errors, [OpeningRowError.sideUnknown]);
    });
  });

  group('row checks', () {
    test('missing name, bad mobile, bad amount, negative, unknown role', () {
      final p = _preview(
        'Name,Mobile,Amount,Role\n'
        ',,100,\n'
        'A,12345,100,\n'
        'B,,abc,\n'
        'C,,-5,\n'
        'D,,5,wizard\n'
        'E,,5,Buyer\n',
      );
      expect(p.rows[0].errors, [OpeningRowError.nameMissing]);
      expect(p.rows[1].errors, [OpeningRowError.mobileInvalid]);
      expect(p.rows[2].errors, [OpeningRowError.amountInvalid]);
      expect(p.rows[3].errors, [OpeningRowError.amountNegative]);
      expect(p.rows[4].errors, [OpeningRowError.roleUnknown]);
      expect(p.rows[5].errors, isEmpty);
      expect(p.rows[5].role, PartyRole.buyer);
      expect(p.valid, hasLength(1));
    });

    test('the default role applies to rows without one', () {
      final p = _preview('Name,Amount\nRamesh,5\n', role: PartyRole.customer);
      expect(p.rows.single.role, PartyRole.customer);
    });
  });

  group('duplicates inside the file', () {
    test('same code twice: the later row is refused, naming the first', () {
      final p = _preview('Code,Name,Amount\nF-1,Ramesh,5\nF-1,Suresh,6\n');
      expect(p.rows[0].errors, isEmpty);
      expect(p.rows[1].errors, [OpeningRowError.duplicateInFile]);
      expect(p.rows[1].detail, '2');
    });

    test('same name, village and mobile twice', () {
      final p = _preview(
        'Name,Village,Amount\nRamesh,Rampura,5\nramesh ,rampura,6\n'
        'Ramesh,Nabha,7\n',
      );
      expect(p.rows[1].errors, [OpeningRowError.duplicateInFile]);
      // A different village is a different person.
      expect(p.rows[2].errors, isEmpty);
    });
  });

  group('matching existing parties', () {
    const ramesh = ExistingParty(
      id: 'p1',
      code: 'F-1',
      name: 'Ramesh Kumar',
      village: 'Rampura',
      mobile: '9814022110',
    );
    const sita = ExistingParty(id: 'p2', code: 'F-2', name: 'Sita Devi');
    const withOpening = ExistingParty(
      id: 'p3',
      code: 'F-3',
      name: 'Gurmeet',
      village: 'Nabha',
      hasOpeningBalance: true,
    );
    final existing = [ramesh, sita, withOpening];

    test('by code, by name + village, by name + mobile, by bare name', () {
      final p = _preview(
        'Code,Name,Village,Mobile,Amount\n'
        'f-1,Ramesh K.,,,100\n'
        ',RAMESH  KUMAR,rampura,,200\n'
        ',Ramesh Kumar,,98140 22110,300\n'
        ',Sita Devi,,,400\n',
        existing: existing,
      );
      // Rows 3 and 4 are the same party as row 2: only the first stays.
      expect(p.invalid.map((r) => r.number), [3, 4]);
      expect(
        p.invalid.expand((r) => r.errors),
        everyElement(OpeningRowError.duplicateInFile),
      );
      expect(p.rows.map((r) => r.matchedPartyId), ['p1', 'p1', 'p1', 'p2']);
      expect(p.rows.map((r) => r.matchedBy), [
        RowMatch.code,
        RowMatch.nameAndVillage,
        RowMatch.nameAndMobile,
        RowMatch.nameOnly,
      ]);
    });

    test('a different village or mobile makes it a new person', () {
      final p = _preview(
        'Name,Village,Amount\nRamesh Kumar,Nabha,100\n',
        existing: existing,
      );
      expect(p.invalid, isEmpty);
      expect(p.rows.single.matchedPartyId, isNull);
      expect(p.newParties, 1);
    });

    test(
      'same name with nothing to tell them apart is flagged, not guessed',
      () {
        final p = _preview(
          'Name,Amount\nRamesh Kumar,100\n',
          existing: existing,
        );
        expect(p.rows.single.errors, [OpeningRowError.possibleDuplicate]);
        expect(p.rows.single.detail, 'F-1');
      },
    );

    test('a code whose name is someone else is refused', () {
      final p = _preview(
        'Code,Name,Amount\nF-2,Ramesh Kumar,100\n',
        existing: existing,
      );
      expect(p.rows.single.errors, [OpeningRowError.codeTaken]);
    });

    test('a code with a different, unused name is a warning', () {
      final p = _preview(
        'Code,Name,Amount\nF-2,Sita Rani,100\n',
        existing: existing,
      );
      expect(p.rows.single.errors, isEmpty);
      expect(p.rows.single.warnings, [OpeningRowWarning.nameDiffers]);
      expect(p.rows.single.matchedPartyId, 'p2');
    });

    test(
      'a party that already has an opening balance is never given a second',
      () {
        final p = _preview(
          'Name,Village,Amount\nGurmeet,Nabha,100\n',
          existing: existing,
        );
        expect(p.rows.single.errors, [OpeningRowError.alreadyHasOpening]);
        expect(p.canImport, isFalse);
      },
    );

    test('a mobile used by another party is a warning', () {
      final p = _preview(
        'Name,Mobile,Amount\nHarpreet,9814022110,100\n',
        existing: existing,
      );
      expect(p.rows.single.errors, isEmpty);
      expect(p.rows.single.warnings, [OpeningRowWarning.mobileOfOther]);
    });

    test(
      'importing the same file twice: every row is refused the 2nd time',
      () {
        const csv = 'Name,Village,Amount\nRamesh,Rampura,100\nSita,Nabha,200\n';
        final first = _preview(csv);
        expect(first.canImport, isTrue);
        // After the first import both parties exist with an opening balance.
        final saved = [
          const ExistingParty(
            id: 'a',
            code: 'P-1',
            name: 'Ramesh',
            village: 'Rampura',
            hasOpeningBalance: true,
          ),
          const ExistingParty(
            id: 'b',
            code: 'P-2',
            name: 'Sita',
            village: 'Nabha',
            hasOpeningBalance: true,
          ),
        ];
        final second = _preview(csv, existing: saved);
        expect(second.valid, isEmpty);
        expect(
          second.rows.expand((r) => r.errors),
          everyElement(OpeningRowError.alreadyHasOpening),
        );
        expect(second.canImport, isFalse);
      },
    );
  });
}
