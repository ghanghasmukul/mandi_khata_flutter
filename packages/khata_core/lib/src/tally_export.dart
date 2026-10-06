import 'package:khata_core/src/journal.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/report_table.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

/// Tally Prime's reserved groups (what a ledger's PARENT may be).
const tallyGroups = [
  'Bank Accounts',
  'Bank OD A/c',
  'Branch / Divisions',
  'Capital Account',
  'Cash-in-Hand',
  'Current Assets',
  'Current Liabilities',
  'Deposits (Asset)',
  'Direct Expenses',
  'Direct Incomes',
  'Duties & Taxes',
  'Fixed Assets',
  'Indirect Expenses',
  'Indirect Incomes',
  'Investments',
  'Loans & Advances (Asset)',
  'Loans (Liability)',
  'Misc. Expenses (ASSET)',
  'Provisions',
  'Purchase Accounts',
  'Reserves & Surplus',
  'Sales Accounts',
  'Secured Loans',
  'Stock-in-Hand',
  'Sundry Creditors',
  'Sundry Debtors',
  'Suspense A/c',
  'Unsecured Loans',
];

/// Our group code → Tally group (docs/domain/posting-rules.md, 11.6). The
/// business may change it (setting `tally.group_map`).
const defaultTallyGroupMap = {
  'capital': 'Capital Account',
  'current_assets': 'Current Assets',
  'sundry_debtors': 'Sundry Debtors',
  'cash_in_hand': 'Cash-in-Hand',
  'bank_accounts': 'Bank Accounts',
  'stock_in_hand': 'Stock-in-Hand',
  'loans_and_advances': 'Loans & Advances (Asset)',
  'current_liabilities': 'Current Liabilities',
  'sundry_creditors': 'Sundry Creditors',
  'duties_and_taxes': 'Duties & Taxes',
  'direct_income': 'Direct Incomes',
  'indirect_income': 'Indirect Incomes',
  'direct_expenses': 'Direct Expenses',
  'indirect_expenses': 'Indirect Expenses',
  'sales_accounts': 'Sales Accounts',
  'purchase_accounts': 'Purchase Accounts',
};

/// What kind of ledger an account is, for choosing the voucher type.
enum TallyLedgerKind { party, book, sales, purchase, other }

/// One account to export as a Tally ledger.
@immutable
final class TallyLedgerIn {
  const TallyLedgerIn({
    required this.id,
    required this.name,
    required this.groupCode,
    this.kind = TallyLedgerKind.other,
    this.code,
  });

  final String id;
  final String name;

  /// Our group code (a group the business added: its own code).
  final String groupCode;
  final TallyLedgerKind kind;

  /// A party's code, appended when two ledgers share a name.
  final String? code;
}

/// One journal entry to export as a Tally voucher.
@immutable
final class TallyVoucherIn {
  const TallyVoucherIn({
    required this.id,
    required this.date,
    required this.lines,
    this.number,
    this.narration,
    this.voucherType,
  });

  /// The journal entry id (Tally's REMOTEID, so a second import of the same
  /// voucher is refused by Tally instead of doubled).
  final String id;
  final LedgerDate date;

  /// (ledger id, debit, credit) per line.
  final List<(String ledgerId, Money debit, Money credit)> lines;
  final String? number;
  final String? narration;

  /// `sales` / `purchase` when our voucher says so; null otherwise.
  final String? voucherType;
}

/// Why something cannot go to Tally as it is.
enum TallyIssueKind {
  /// The ledger's group has no Tally group.
  unmappedGroup,

  /// Tally refuses an empty name or more than 99 characters.
  badName,

  /// Two ledgers had the same name; the code was added (information).
  renamed,

  /// The voucher's lines do not balance.
  unbalanced,

  /// A voucher line uses an account that is not in the chart yet.
  unknownLedger,
}

@immutable
final class TallyIssue {
  const TallyIssue(this.kind, this.subject, {this.detail});

  final TallyIssueKind kind;

  /// The ledger or voucher it is about.
  final String subject;
  final String? detail;

  /// Information only; the export still works.
  bool get isWarning => kind == TallyIssueKind.renamed;
}

/// The two files to import (masters first, then vouchers) and what was
/// found on the way.
@immutable
final class TallyExportResult {
  const TallyExportResult({
    required this.mastersXml,
    required this.vouchersXml,
    required this.issues,
    required this.ledgerCount,
    required this.voucherCount,
  });

  final String mastersXml;
  final String vouchersXml;
  final List<TallyIssue> issues;
  final int ledgerCount;
  final int voucherCount;

  /// No issue that would make Tally refuse the import.
  bool get isClean => issues.every((i) => i.isWarning);
}

/// Builds Tally Prime XML (docs/domain/posting-rules.md, 11.6).
abstract final class TallyExport {
  static const maxNameLength = 99;

  /// The Tally voucher type of a journal entry: our sales / purchase
  /// voucher keeps its type; only cash / bank lines → Contra; a cash / bank
  /// credited → Payment; debited → Receipt; else Journal.
  static String voucherType(
    List<(TallyLedgerKind, bool)> lines, {
    String? ours,
  }) {
    if (ours == 'sales') return 'Sales';
    if (ours == 'purchase') return 'Purchase';
    final books = [
      for (final (kind, isDebit) in lines)
        if (kind == TallyLedgerKind.book) isDebit,
    ];
    if (books.isEmpty) return 'Journal';
    if (books.length == lines.length) return 'Contra';
    return books.contains(false) ? 'Payment' : 'Receipt';
  }

  /// Unique Tally names: a name used twice gets the party code appended,
  /// then a counter.
  static Map<String, String> uniqueNames(
    List<TallyLedgerIn> ledgers,
    List<TallyIssue> issues,
  ) {
    final count = <String, int>{};
    for (final l in ledgers) {
      final k = l.name.trim().toLowerCase();
      count[k] = (count[k] ?? 0) + 1;
    }
    final taken = <String>{};
    final out = <String, String>{};
    for (final l in ledgers) {
      final base = l.name.trim();
      var name = base;
      if ((count[base.toLowerCase()] ?? 0) > 1 && l.code != null) {
        name = '$base (${l.code})';
      }
      var n = 2;
      final first = name;
      while (!taken.add(name.toLowerCase())) {
        name = '$first ($n)';
        n++;
      }
      if (name != base) {
        issues.add(TallyIssue(TallyIssueKind.renamed, base, detail: name));
      }
      out[l.id] = name;
    }
    return out;
  }

  static TallyExportResult build({
    required String company,
    required List<TallyLedgerIn> ledgers,
    required List<TallyVoucherIn> vouchers,
    Map<String, String> groupMap = defaultTallyGroupMap,
  }) {
    final issues = <TallyIssue>[];
    final names = uniqueNames(ledgers, issues);
    final byId = {for (final l in ledgers) l.id: l};

    final masters = XmlBuilder();
    _envelope(masters, company, 'All Masters', () {
      for (final l in ledgers) {
        final name = names[l.id]!;
        if (name.isEmpty || name.length > maxNameLength) {
          issues.add(TallyIssue(TallyIssueKind.badName, l.name));
        }
        final parent = groupMap[l.groupCode];
        if (parent == null || !tallyGroups.contains(parent)) {
          issues.add(
            TallyIssue(TallyIssueKind.unmappedGroup, name, detail: l.groupCode),
          );
          continue;
        }
        masters.element(
          'TALLYMESSAGE',
          attributes: {'xmlns:UDF': 'TallyUDF'},
          nest: () => masters.element(
            'LEDGER',
            attributes: {'NAME': name, 'ACTION': 'Create'},
            nest: () {
              masters
                ..element(
                  'NAME.LIST',
                  nest: () => masters.element('NAME', nest: name),
                )
                ..element('PARENT', nest: parent)
                ..element(
                  'ISBILLWISEON',
                  nest: l.kind == TallyLedgerKind.party ? 'Yes' : 'No',
                );
            },
          ),
        );
      }
    });

    final out = XmlBuilder();
    var written = 0;
    _envelope(out, company, 'Vouchers', () {
      for (final v in vouchers) {
        final debit = v.lines.fold(Money.zero, (s, l) => s + l.$2);
        final credit = v.lines.fold(Money.zero, (s, l) => s + l.$3);
        final subject = v.number ?? v.id;
        if (debit != credit) {
          issues.add(TallyIssue(TallyIssueKind.unbalanced, subject));
          continue;
        }
        final missing = v.lines.where((l) => !byId.containsKey(l.$1));
        if (missing.isNotEmpty) {
          issues.add(
            TallyIssue(
              TallyIssueKind.unknownLedger,
              subject,
              detail: missing.first.$1,
            ),
          );
          continue;
        }
        final type = voucherType([
          for (final l in v.lines) (byId[l.$1]!.kind, l.$2.isPositive),
        ], ours: v.voucherType);
        final date = _tallyDate(v.date);
        written++;
        out.element(
          'TALLYMESSAGE',
          attributes: {'xmlns:UDF': 'TallyUDF'},
          nest: () => out.element(
            'VOUCHER',
            attributes: {
              'REMOTEID': v.id,
              'VCHTYPE': type,
              'ACTION': 'Create',
              'OBJVIEW': 'Accounting Voucher View',
            },
            nest: () {
              out
                ..element('DATE', nest: date)
                ..element('EFFECTIVEDATE', nest: date)
                ..element('VOUCHERTYPENAME', nest: type)
                ..element('PERSISTEDVIEW', nest: 'Accounting Voucher View');
              if (v.number != null) {
                out.element('VOUCHERNUMBER', nest: v.number);
              }
              if (v.narration != null && v.narration!.isNotEmpty) {
                out.element('NARRATION', nest: v.narration);
              }
              for (final (id, dr, cr) in v.lines) {
                final isDebit = dr.isPositive;
                out.element(
                  'ALLLEDGERENTRIES.LIST',
                  nest: () {
                    out
                      ..element('LEDGERNAME', nest: names[id])
                      ..element(
                        'ISDEEMEDPOSITIVE',
                        nest: isDebit ? 'Yes' : 'No',
                      )
                      // Tally: a debit is negative, a credit positive.
                      ..element(
                        'AMOUNT',
                        nest: (isDebit ? -dr : cr).plainRupees,
                      );
                  },
                );
              }
            },
          ),
        );
      }
    });

    return TallyExportResult(
      mastersXml: masters.buildDocument().toXmlString(pretty: true),
      vouchersXml: out.buildDocument().toXmlString(pretty: true),
      issues: issues,
      ledgerCount: ledgers.length,
      voucherCount: written,
    );
  }

  static String _tallyDate(LedgerDate d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';

  static void _envelope(
    XmlBuilder b,
    String company,
    String report,
    void Function() body,
  ) {
    b.element(
      'ENVELOPE',
      nest: () {
        b
          ..element(
            'HEADER',
            nest: () => b.element('TALLYREQUEST', nest: 'Import Data'),
          )
          ..element(
            'BODY',
            nest: () => b.element(
              'IMPORTDATA',
              nest: () {
                b
                  ..element(
                    'REQUESTDESC',
                    nest: () {
                      b
                        ..element('REPORTNAME', nest: report)
                        ..element(
                          'STATICVARIABLES',
                          nest: () =>
                              b.element('SVCURRENTCOMPANY', nest: company),
                        );
                    },
                  )
                  ..element('REQUESTDATA', nest: body);
              },
            ),
          );
      },
    );
  }

  /// The ledger kind of an account of the chart.
  static TallyLedgerKind kindOf(
    JournalAccount account, {
    bool sales = false,
    bool purchase = false,
  }) => switch (account) {
    PartyAccount() => TallyLedgerKind.party,
    BookAccount() => TallyLedgerKind.book,
    _ when sales => TallyLedgerKind.sales,
    _ when purchase => TallyLedgerKind.purchase,
    _ => TallyLedgerKind.other,
  };
}
