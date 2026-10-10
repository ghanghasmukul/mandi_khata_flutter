import 'dart:convert';
import 'dart:typed_data';

import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/report_table.dart';
import 'package:khata_core/src/sheet_reader.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

/// A party ledger read from a Tally export (step 6.5).
@immutable
final class TallyLedger {
  const TallyLedger({
    required this.name,
    required this.parent,
    required this.openingPaise,
    this.address,
    this.mobile,
  });

  final String name;

  /// The Tally group (`Sundry Debtors`, `Sundry Creditors`, ...).
  final String parent;

  /// Tally's sign: a debit is negative, a credit is positive.
  final int openingPaise;
  final String? address;
  final String? mobile;
}

/// What a Tally export (masters and/or vouchers) holds, as far as party
/// balances go.
///
/// **What is imported:** party ledgers (Sundry Debtors / Creditors) with their
/// balance. The balance is Tally's opening balance plus every voucher line on
/// the ledger found in the files, i.e. the closing balance of the files'
/// period. Voucher history is **not** re-created as khata entries: the
/// balance comes in as one opening-balance entry per party (the same safe,
/// audited path as the opening-balance import). Decision recorded in
/// docs/decisions.md.
@immutable
final class TallyData {
  const TallyData({
    required this.ledgers,
    required this.movementPaise,
    required this.voucherCount,
    required this.skippedVouchers,
    this.firstVoucher,
    this.lastVoucher,
  });

  /// Every ledger found, in file order (all groups).
  final List<TallyLedger> ledgers;

  /// Σ of voucher line amounts per ledger name, Tally's sign.
  final Map<String, int> movementPaise;
  final int voucherCount;

  /// Cancelled or optional vouchers, ignored.
  final int skippedVouchers;
  final DateTime? firstVoucher;
  final DateTime? lastVoucher;

  /// Ledgers that are parties.
  List<TallyLedger> get parties => [
    for (final l in ledgers)
      if (TallyImport.partyRole(l.parent) != null) l,
  ];

  /// Ledgers that are not parties (cash, bank, income, expense...), skipped.
  int get skippedLedgers => ledgers.length - parties.length;

  /// Voucher lines on a ledger that has no master in the files.
  List<String> get unknownLedgersInVouchers => [
    for (final n in movementPaise.keys)
      if (!ledgers.any((l) => l.name == n)) n,
  ];

  /// Closing balance in Tally's sign (debit negative).
  int closingPaise(TallyLedger l) =>
      l.openingPaise + (movementPaise[l.name] ?? 0);

  /// The parties as a table the opening-balance import reads: Name, Role,
  /// Village, Mobile, Amount, Side.
  Sheet toSheet() {
    final rows = <SheetRow>[
      const SheetRow(1, [
        'Name',
        'Role',
        'Village',
        'Mobile',
        'Amount',
        'Side',
      ]),
    ];
    var n = 2;
    for (final l in parties) {
      final closing = closingPaise(l);
      final amount = Money(closing.abs());
      rows.add(
        SheetRow(n++, [
          l.name,
          TallyImport.partyRole(l.parent)!,
          l.address ?? '',
          l.mobile ?? '',
          if (closing == 0) ...[
            '',
            '',
          ] else ...[
            amount.plainRupees,
            if (closing < 0) 'Dr' else 'Cr',
          ],
        ]),
      );
    }
    return Sheet(rows);
  }
}

/// Reads Tally Prime / ERP 9 XML exports.
abstract final class TallyImport {
  /// The role a Tally group stands for, or null when the group is not a party
  /// group. Sundry Debtors = customers, Sundry Creditors = suppliers.
  static String? partyRole(String parent) {
    final p = parent.trim().toLowerCase();
    if (p == 'sundry debtors') return 'customer';
    if (p == 'sundry creditors') return 'supplier';
    return null;
  }

  /// Text of an export file: UTF-8 or UTF-16 (Tally writes UTF-16 on some
  /// versions), BOM removed.
  static String decode(Uint8List bytes) {
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      final units = <int>[
        for (var i = 2; i + 1 < bytes.length; i += 2)
          bytes[i] | (bytes[i + 1] << 8),
      ];
      return String.fromCharCodes(units);
    }
    if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
      final units = <int>[
        for (var i = 2; i + 1 < bytes.length; i += 2)
          (bytes[i] << 8) | bytes[i + 1],
      ];
      return String.fromCharCodes(units);
    }
    final start =
        bytes.length >= 3 &&
            bytes[0] == 0xEF &&
            bytes[1] == 0xBB &&
            bytes[2] == 0xBF
        ? 3
        : 0;
    return utf8.decode(bytes.sublist(start), allowMalformed: true);
  }

  /// Parses one or more export files. Throws [SheetFormatException] when a
  /// file is not Tally XML.
  static TallyData parse(List<String> xmlFiles) {
    final ledgers = <TallyLedger>[];
    final seenLedgers = <String>{};
    final movement = <String, int>{};
    var vouchers = 0;
    var skipped = 0;
    DateTime? first;
    DateTime? last;

    for (final raw in xmlFiles) {
      final XmlDocument doc;
      try {
        // Tally writes control characters as references (&#4;) that XML 1.0
        // forbids.
        doc = XmlDocument.parse(
          raw.replaceAll(RegExp('&#(?:[0-9]|1[0-9]|2[0-9]|30|31);'), ''),
        );
      } on XmlException catch (e) {
        throw SheetFormatException('Not a valid XML file: ${e.message}');
      }
      final envelope = doc.rootElement;
      if (envelope.name.local.toUpperCase() != 'ENVELOPE') {
        throw const SheetFormatException('Not a Tally export (no ENVELOPE).');
      }

      for (final e in envelope.findAllElements('LEDGER')) {
        final name = _name(e);
        if (name == null || !seenLedgers.add(name)) continue;
        ledgers.add(
          TallyLedger(
            name: name,
            parent: _text(e, 'PARENT') ?? '',
            openingPaise: _amount(_text(e, 'OPENINGBALANCE')) ?? 0,
            address: _firstAddress(e),
            mobile: _mobile(
              _text(e, 'LEDGERMOBILE') ?? _text(e, 'LEDGERPHONE'),
            ),
          ),
        );
      }

      for (final v in envelope.findAllElements('VOUCHER')) {
        if (_yes(_text(v, 'ISCANCELLED')) || _yes(_text(v, 'ISOPTIONAL'))) {
          skipped++;
          continue;
        }
        vouchers++;
        final date = _date(_text(v, 'DATE'));
        if (date != null) {
          if (first == null || date.isBefore(first)) first = date;
          if (last == null || date.isAfter(last)) last = date;
        }
        for (final line in v.childElements.where(
          (c) =>
              c.name.local == 'ALLLEDGERENTRIES.LIST' ||
              c.name.local == 'LEDGERENTRIES.LIST',
        )) {
          final ledger = _text(line, 'LEDGERNAME');
          final amount = _amount(_text(line, 'AMOUNT'));
          if (ledger == null || amount == null) continue;
          movement.update(ledger, (m) => m + amount, ifAbsent: () => amount);
        }
      }
    }
    if (ledgers.isEmpty && vouchers == 0) {
      throw const SheetFormatException('No ledgers or vouchers found.');
    }
    return TallyData(
      ledgers: ledgers,
      movementPaise: movement,
      voucherCount: vouchers,
      skippedVouchers: skipped,
      firstVoucher: first,
      lastVoucher: last,
    );
  }

  static String? _name(XmlElement e) {
    final attr = e.getAttribute('NAME');
    if (attr != null && attr.trim().isNotEmpty) return attr.trim();
    final list = e.getElement('NAME.LIST')?.getElement('NAME');
    final t = list?.innerText.trim();
    return t == null || t.isEmpty ? null : t;
  }

  static String? _text(XmlElement e, String child) {
    final t = e.getElement(child)?.innerText.trim();
    return t == null || t.isEmpty ? null : t;
  }

  static bool _yes(String? s) => s != null && s.toLowerCase() == 'yes';

  static String? _firstAddress(XmlElement e) {
    for (final a in e.findAllElements('ADDRESS')) {
      final t = a.innerText.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }

  static String? _mobile(String? s) {
    if (s == null) return null;
    final digits = s.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 ? digits.substring(digits.length - 10) : null;
  }

  /// `-1234.50`, `1234.50 Dr`, `1,234.50 Cr` → paise in Tally's sign.
  static int? _amount(String? raw) {
    if (raw == null) return null;
    var t = raw.trim().toLowerCase().replaceAll(',', '');
    var sign = 1;
    if (t.endsWith('dr')) {
      sign = -1;
      t = t.substring(0, t.length - 2).trim();
    } else if (t.endsWith('cr')) {
      t = t.substring(0, t.length - 2).trim();
    }
    final negative = t.startsWith('-');
    if (negative) t = t.substring(1);
    final money = Money.tryParse(t);
    if (money == null) return null;
    return (negative ? -money.paise : money.paise) * sign;
  }

  static DateTime? _date(String? s) {
    if (s == null || !RegExp(r'^\d{8}$').hasMatch(s)) return null;
    return DateTime.utc(
      int.parse(s.substring(0, 4)),
      int.parse(s.substring(4, 6)),
      int.parse(s.substring(6, 8)),
    );
  }
}
