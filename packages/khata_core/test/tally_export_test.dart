import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

const ledgers = [
  TallyLedgerIn(
    id: 'farmer',
    name: 'Gurmeet Singh',
    groupCode: 'sundry_creditors',
    kind: TallyLedgerKind.party,
    code: 'P-W1-0001',
  ),
  TallyLedgerIn(
    id: 'farmer2',
    name: 'Gurmeet Singh',
    groupCode: 'sundry_creditors',
    kind: TallyLedgerKind.party,
    code: 'P-W1-0002',
  ),
  TallyLedgerIn(
    id: 'cash',
    name: 'Cash',
    groupCode: 'cash_in_hand',
    kind: TallyLedgerKind.book,
  ),
  TallyLedgerIn(
    id: 'sbi',
    name: 'SBI',
    groupCode: 'bank_accounts',
    kind: TallyLedgerKind.book,
  ),
  TallyLedgerIn(
    id: 'commission',
    name: 'Commission Income',
    groupCode: 'direct_income',
  ),
];

TallyVoucherIn v(
  String id,
  List<(String, int, int)> lines, {
  String? number,
  String? type,
}) => TallyVoucherIn(
  id: id,
  date: LedgerDate(2027, 4, 9),
  number: number,
  narration: 'n & <x>',
  voucherType: type,
  lines: [for (final (l, d, c) in lines) (l, Money.rupees(d), Money.rupees(c))],
);

void main() {
  test('tally.group_map setting accepts only Tally groups', () {
    final def = SettingsSchema.parse('tally.group_map')!.def;
    expect(def.validate(const {'my_group': 'Indirect Incomes'}), isNull);
    expect(def.validate(const {'my_group': 'Nope'}), isNotNull);
    expect(def.validate(const {'Bad Key': 'Indirect Incomes'}), isNotNull);
    expect(def.validate('x'), isNotNull);
    expect(def.hidden, isTrue);
  });

  group('voucherType', () {
    const book = TallyLedgerKind.book;
    const party = TallyLedgerKind.party;
    test('by lines and our type', () {
      expect(TallyExport.voucherType([(book, true), (book, false)]), 'Contra');
      expect(
        TallyExport.voucherType([(party, true), (book, false)]),
        'Payment',
      );
      expect(
        TallyExport.voucherType([(book, true), (party, false)]),
        'Receipt',
      );
      expect(
        TallyExport.voucherType([(party, true), (party, false)]),
        'Journal',
      );
      expect(
        TallyExport.voucherType([(book, true), (party, false)], ours: 'sales'),
        'Sales',
      );
      expect(
        TallyExport.voucherType([(party, true)], ours: 'purchase'),
        'Purchase',
      );
    });
  });

  group('build', () {
    final r = TallyExport.build(
      company: 'Bansal & Sons',
      ledgers: ledgers,
      vouchers: [
        v('e1', [('farmer', 5000, 0), ('cash', 0, 5000)], number: 'PY-W1-0001'),
        v('e2', [('sbi', 1000, 0), ('cash', 0, 1000)]),
        v('e3', [('farmer', 1, 0), ('cash', 0, 2)], number: 'BAD'),
        v('e4', [('ghost', 1, 0), ('cash', 0, 1)], number: 'GHOST'),
      ],
    );

    test('masters: one ledger each, Tally group, unique names', () {
      final doc = XmlDocument.parse(r.mastersXml);
      expect(doc.findAllElements('REPORTNAME').single.innerText, 'All Masters');
      expect(
        doc.findAllElements('SVCURRENTCOMPANY').single.innerText,
        'Bansal & Sons',
      );
      final names = [
        for (final l in doc.findAllElements('LEDGER')) l.getAttribute('NAME'),
      ];
      expect(names, [
        'Gurmeet Singh (P-W1-0001)',
        'Gurmeet Singh (P-W1-0002)',
        'Cash',
        'SBI',
        'Commission Income',
      ]);
      final parents = [
        for (final l in doc.findAllElements('PARENT')) l.innerText,
      ];
      expect(parents, [
        'Sundry Creditors',
        'Sundry Creditors',
        'Cash-in-Hand',
        'Bank Accounts',
        'Direct Incomes',
      ]);
      expect(r.ledgerCount, 5);
    });

    test('vouchers: Tally signs, types, numbers, escaped narration', () {
      final doc = XmlDocument.parse(r.vouchersXml);
      final vouchers = doc.findAllElements('VOUCHER').toList();
      expect(vouchers, hasLength(2));
      expect(r.voucherCount, 2);
      final pay = vouchers.first;
      expect(pay.getAttribute('VCHTYPE'), 'Payment');
      expect(pay.getAttribute('REMOTEID'), 'e1');
      expect(pay.findElements('DATE').single.innerText, '20270409');
      expect(pay.findElements('VOUCHERNUMBER').single.innerText, 'PY-W1-0001');
      expect(pay.findElements('NARRATION').single.innerText, 'n & <x>');
      final entries = pay.findElements('ALLLEDGERENTRIES.LIST').toList();
      expect(
        [
          for (final e in entries)
            (
              e.findElements('LEDGERNAME').single.innerText,
              e.findElements('ISDEEMEDPOSITIVE').single.innerText,
              e.findElements('AMOUNT').single.innerText,
            ),
        ],
        [
          ('Gurmeet Singh (P-W1-0001)', 'Yes', '-5000.00'),
          ('Cash', 'No', '5000.00'),
        ],
      );
      expect(vouchers[1].getAttribute('VCHTYPE'), 'Contra');
      expect(vouchers[1].findElements('VOUCHERNUMBER'), isEmpty);
      expect(r.mastersXml, contains('Bansal &amp; Sons'));
    });

    test('validation: unbalanced and unknown ledgers are reported, renames '
        'are warnings', () {
      expect(
        {for (final i in r.issues) (i.kind, i.subject)},
        {
          (TallyIssueKind.renamed, 'Gurmeet Singh'),
          (TallyIssueKind.unbalanced, 'BAD'),
          (TallyIssueKind.unknownLedger, 'GHOST'),
        },
      );
      expect(r.isClean, isFalse);
      expect(r.issues.where((i) => i.isWarning), hasLength(2));
    });

    test('unmapped group and bad names', () {
      final x = TallyExport.build(
        company: 'X',
        ledgers: [
          const TallyLedgerIn(id: 'a', name: 'Odd', groupCode: 'my_group'),
          TallyLedgerIn(id: 'b', name: 'y' * 120, groupCode: 'capital'),
          const TallyLedgerIn(id: 'c', name: 'Rent', groupCode: 'capital'),
        ],
        vouchers: const [],
        groupMap: const {...defaultTallyGroupMap, 'my_group': 'Not Tally'},
      );
      expect(
        [for (final i in x.issues) i.kind],
        [TallyIssueKind.unmappedGroup, TallyIssueKind.badName],
      );
      final clean = TallyExport.build(
        company: 'X',
        ledgers: const [
          TallyLedgerIn(id: 'a', name: 'Odd', groupCode: 'my_group'),
        ],
        vouchers: const [],
        groupMap: const {'my_group': 'Indirect Incomes'},
      );
      expect(clean.isClean, isTrue);
    });

    test('same name twice without a code gets a counter', () {
      final issues = <TallyIssue>[];
      final names = TallyExport.uniqueNames(const [
        TallyLedgerIn(id: 'a', name: 'Rent', groupCode: 'capital'),
        TallyLedgerIn(id: 'b', name: 'rent', groupCode: 'capital'),
      ], issues);
      expect(names, {'a': 'Rent', 'b': 'rent (2)'});
    });

    test('kinds of chart accounts', () {
      expect(
        TallyExport.kindOf(const PartyAccount('p')),
        TallyLedgerKind.party,
      );
      expect(TallyExport.kindOf(const BookAccount('b')), TallyLedgerKind.book);
      expect(
        TallyExport.kindOf(const ChartAccount('s'), sales: true),
        TallyLedgerKind.sales,
      );
      expect(
        TallyExport.kindOf(const ChartAccount('p'), purchase: true),
        TallyLedgerKind.purchase,
      );
      expect(
        TallyExport.kindOf(const ChartAccount('o')),
        TallyLedgerKind.other,
      );
      for (final code in defaultTallyGroupMap.values) {
        expect(tallyGroups, contains(code));
      }
      for (final g in AccountGroup.values) {
        expect(defaultTallyGroupMap, contains(g.code));
      }
    });
  });
}
