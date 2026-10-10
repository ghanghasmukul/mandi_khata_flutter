// Tally XML is written as adjacent string fragments.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:convert';
import 'dart:typed_data';

import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

const masters = '''
<ENVELOPE><BODY><IMPORTDATA><REQUESTDATA>
<TALLYMESSAGE><LEDGER NAME="Gurdev Singh" ACTION="Create">
  <PARENT>Sundry Creditors</PARENT><OPENINGBALANCE>15000.00</OPENINGBALANCE>
  <LEDMAILINGDETAILS.LIST><ADDRESS.LIST><ADDRESS>Village Dhand</ADDRESS></ADDRESS.LIST></LEDMAILINGDETAILS.LIST>
  <LEDGERMOBILE>+91 98765 43210</LEDGERMOBILE>
</LEDGER></TALLYMESSAGE>
<TALLYMESSAGE><LEDGER NAME="Harbans Lal"><PARENT>Sundry Debtors</PARENT>
  <OPENINGBALANCE>-4000.00</OPENINGBALANCE></LEDGER></TALLYMESSAGE>
<TALLYMESSAGE><LEDGER NAME="Cash"><PARENT>Cash-in-Hand</PARENT>
  <OPENINGBALANCE>-500.00</OPENINGBALANCE></LEDGER></TALLYMESSAGE>
<TALLYMESSAGE><LEDGER NAME="Zero Party"><PARENT>Sundry Debtors</PARENT></LEDGER></TALLYMESSAGE>
</REQUESTDATA></IMPORTDATA></BODY></ENVELOPE>''';

const vouchers = '''
<ENVELOPE><BODY><IMPORTDATA><REQUESTDATA>
<TALLYMESSAGE><VOUCHER VCHTYPE="Payment"><DATE>20270410</DATE>
  <ALLLEDGERENTRIES.LIST><LEDGERNAME>Gurdev Singh</LEDGERNAME><ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE><AMOUNT>-5000.00</AMOUNT></ALLLEDGERENTRIES.LIST>
  <ALLLEDGERENTRIES.LIST><LEDGERNAME>Cash</LEDGERNAME><ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE><AMOUNT>5000.00</AMOUNT></ALLLEDGERENTRIES.LIST>
</VOUCHER></TALLYMESSAGE>
<TALLYMESSAGE><VOUCHER VCHTYPE="Sales"><DATE>20270415</DATE>
  <LEDGERENTRIES.LIST><LEDGERNAME>Harbans Lal</LEDGERNAME><AMOUNT>-1000.50</AMOUNT></LEDGERENTRIES.LIST>
</VOUCHER></TALLYMESSAGE>
<TALLYMESSAGE><VOUCHER VCHTYPE="Sales"><DATE>20270416</DATE><ISCANCELLED>Yes</ISCANCELLED>
  <LEDGERENTRIES.LIST><LEDGERNAME>Harbans Lal</LEDGERNAME><AMOUNT>-99999.00</AMOUNT></LEDGERENTRIES.LIST>
</VOUCHER></TALLYMESSAGE>
</REQUESTDATA></IMPORTDATA></BODY></ENVELOPE>''';

void main() {
  test('masters: party ledgers only, with the Tally sign and details', () {
    final d = TallyImport.parse([masters]);
    expect(d.ledgers, hasLength(4));
    expect(d.parties.map((l) => l.name), [
      'Gurdev Singh',
      'Harbans Lal',
      'Zero Party',
    ]);
    expect(d.skippedLedgers, 1);
    final g = d.ledgers.first;
    expect(g.openingPaise, 1500000, reason: 'credit = we owe = positive');
    expect(g.address, 'Village Dhand');
    expect(g.mobile, '9876543210');
    expect(d.ledgers[1].openingPaise, -400000, reason: 'debit = negative');
  });

  test('closing balance = opening + vouchers; cancelled ones ignored', () {
    final d = TallyImport.parse([masters, vouchers]);
    expect(d.voucherCount, 2);
    expect(d.skippedVouchers, 1);
    expect(d.firstVoucher, DateTime.utc(2027, 4, 10));
    expect(d.lastVoucher, DateTime.utc(2027, 4, 15));
    // Gurdev: we owed 15,000, paid 5,000 -> we owe 10,000 (Cr).
    // Harbans: owed us 4,000, sold 1,000.50 more -> owes 5,000.50 (Dr).
    final sheet = d.toSheet();
    expect(sheet.rows.first.cells, [
      'Name',
      'Role',
      'Village',
      'Mobile',
      'Amount',
      'Side',
    ]);
    expect(sheet.rows[1].cells, [
      'Gurdev Singh',
      'supplier',
      'Village Dhand',
      '9876543210',
      '10000.00',
      'Cr',
    ]);
    expect(sheet.rows[2].cells.sublist(4), ['5000.50', 'Dr']);
    expect(sheet.rows[3].cells.sublist(4), ['', ''], reason: 'zero balance');
  });

  test('the sheet goes through the opening balance import unchanged', () {
    final sheet = TallyImport.parse([masters, vouchers]).toSheet();
    final preview = OpeningBalanceImport.preview(sheet, existing: const []);
    expect(preview.problem, isNull);
    expect(preview.invalid, isEmpty);
    expect(preview.totalJama, const Money.rupees(10000));
    expect(preview.totalUdhaar, const Money(500050));
    expect(preview.newParties, 3);
  });

  test('Dr / Cr suffix amounts and UTF-16 files', () {
    const xml =
        '<ENVELOPE><LEDGER NAME="A"><PARENT>Sundry Debtors</PARENT>'
        '<OPENINGBALANCE>1,200.00 Dr</OPENINGBALANCE></LEDGER></ENVELOPE>';
    expect(TallyImport.parse([xml]).ledgers.single.openingPaise, -120000);
    final utf16 = Uint8List.fromList([
      0xFF,
      0xFE,
      for (final u in xml.codeUnits) ...[u & 0xFF, u >> 8],
    ]);
    expect(TallyImport.decode(utf16), xml);
    expect(
      TallyImport.decode(
        Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode('x')]),
      ),
      'x',
    );
  });

  test('not Tally / broken XML is refused with a clear error', () {
    expect(
      () => TallyImport.parse(['<a/>']),
      throwsA(isA<SheetFormatException>()),
    );
    expect(
      () => TallyImport.parse(['<ENVELOPE']),
      throwsA(isA<SheetFormatException>()),
    );
    expect(
      () => TallyImport.parse(['<ENVELOPE/>']),
      throwsA(isA<SheetFormatException>()),
    );
  });

  test('voucher lines on a ledger with no master are listed', () {
    final d = TallyImport.parse([masters, vouchers]);
    expect(d.unknownLedgersInVouchers, isEmpty);
    final only = TallyImport.parse([vouchers]);
    expect(
      only.unknownLedgersInVouchers,
      containsAll(['Gurdev Singh', 'Cash']),
    );
  });
}
