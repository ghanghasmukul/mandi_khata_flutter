import 'package:khata_core/src/gst.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/report_table.dart';
import 'package:khata_core/src/stock_rules.dart';
import 'package:meta/meta.dart';

/// Translates a report column title (the English text is the key). The
/// default keeps English.
typedef ReportTitle = String Function(String english);

String _en(String s) => s;

// ---------------------------------------------------------------------------
// Profit
// ---------------------------------------------------------------------------

/// A sold (or returned) line for the profit report. A return is a negative
/// record: negative quantity, revenue and cost.
@immutable
final class SaleLineRecord {
  const SaleLineRecord({
    required this.productId,
    required this.productName,
    required this.date,
    required this.qtyMilli,
    required this.revenue,
    required this.cogs,
    this.categoryId,
    this.categoryName,
  });

  final String productId;
  final String productName;
  final String? categoryId;
  final String? categoryName;
  final LedgerDate date;
  final int qtyMilli;

  /// Taxable value (without GST, after discounts).
  final Money revenue;

  /// Cost of goods sold at batch cost.
  final Money cogs;
}

@immutable
final class ProfitRow {
  const ProfitRow({
    required this.key,
    required this.label,
    required this.qtyMilli,
    required this.revenue,
    required this.cogs,
  });

  final String key;
  final String label;
  final int qtyMilli;
  final Money revenue;
  final Money cogs;

  Money get profit => revenue - cogs;

  /// Profit / revenue in basis points; null without revenue.
  int? get marginBp => Margin.basisPoints(revenue, cogs);

  /// `25.5%`, or null without revenue.
  String? get marginText {
    final bp = marginBp;
    return bp == null ? null : Margin.format(bp);
  }
}

abstract final class ShopProfit {
  static List<ProfitRow> _group(
    Iterable<SaleLineRecord> records,
    (String, String) Function(SaleLineRecord) keyOf,
  ) {
    final rows = <String, ProfitRow>{};
    for (final r in records) {
      final (key, label) = keyOf(r);
      final old = rows[key];
      rows[key] = ProfitRow(
        key: key,
        label: label,
        qtyMilli: (old?.qtyMilli ?? 0) + r.qtyMilli,
        revenue: (old?.revenue ?? Money.zero) + r.revenue,
        cogs: (old?.cogs ?? Money.zero) + r.cogs,
      );
    }
    return rows.values.toList();
  }

  static int _byProfit(ProfitRow a, ProfitRow b) {
    final c = b.profit.compareTo(a.profit);
    return c != 0 ? c : a.label.compareTo(b.label);
  }

  /// Per product, best profit first.
  static List<ProfitRow> byProduct(Iterable<SaleLineRecord> records) =>
      _group(records, (r) => (r.productId, r.productName))..sort(_byProfit);

  /// Per category, best profit first; no category is grouped under
  /// [uncategorised].
  static List<ProfitRow> byCategory(
    Iterable<SaleLineRecord> records, {
    String uncategorised = 'Uncategorised',
  }) => _group(
    records,
    (r) => (r.categoryId ?? '', r.categoryName ?? uncategorised),
  )..sort(_byProfit);

  /// Per calendar month (`2026-10`), oldest first.
  static List<ProfitRow> byMonth(Iterable<SaleLineRecord> records) {
    String month(LedgerDate d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}';
    return _group(records, (r) => (month(r.date), month(r.date)))
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  /// Rows as a report with a totals row.
  static ReportTable table(
    List<ProfitRow> rows, {
    String keyTitle = 'Product',
    ReportTitle title = _en,
  }) {
    var qty = 0;
    var revenue = Money.zero;
    var cogs = Money.zero;
    for (final r in rows) {
      qty += r.qtyMilli;
      revenue += r.revenue;
      cogs += r.cogs;
    }
    final total = ProfitRow(
      key: '',
      label: title('Total'),
      qtyMilli: qty,
      revenue: revenue,
      cogs: cogs,
    );
    List<Object?> cells(ProfitRow r) => [
      r.label,
      r.qtyMilli,
      r.revenue,
      r.cogs,
      r.profit,
      r.marginText,
    ];
    return ReportTable(
      columns: [
        ReportColumn(title(keyTitle), ReportColumnKind.text),
        ReportColumn(title('Qty'), ReportColumnKind.quantity),
        ReportColumn(title('Revenue'), ReportColumnKind.money),
        ReportColumn(title('Cost'), ReportColumnKind.money),
        ReportColumn(title('Profit'), ReportColumnKind.money),
        ReportColumn(title('Margin'), ReportColumnKind.text),
      ],
      rows: [for (final r in rows) cells(r)],
      totals: cells(total),
    );
  }
}

// ---------------------------------------------------------------------------
// Reorder
// ---------------------------------------------------------------------------

@immutable
final class ReorderInput {
  const ReorderInput({
    required this.productId,
    required this.name,
    required this.stockMilli,
    required this.reorderLevelMilli,
    required this.soldLast30Milli,
  });

  final String productId;
  final String name;
  final int stockMilli;
  final int reorderLevelMilli;

  /// Net quantity sold in the last 30 days.
  final int soldLast30Milli;
}

@immutable
final class ReorderSuggestion {
  const ReorderSuggestion({
    required this.productId,
    required this.name,
    required this.stockMilli,
    required this.reorderLevelMilli,
    required this.soldLast30Milli,
    required this.suggestedMilli,
    required this.daysOfStock,
  });

  final String productId;
  final String name;
  final int stockMilli;
  final int reorderLevelMilli;
  final int soldLast30Milli;

  /// Whole units to buy.
  final int suggestedMilli;

  /// Days the stock lasts at the last-30-day pace; null without sales.
  final int? daysOfStock;
}

abstract final class ReorderReport {
  /// Products that need buying, most urgent first. A product needs it when
  /// its stock is at or below the reorder level, or lasts fewer than
  /// [leadDays] at the last-30-day pace. Suggested quantity = the larger of
  /// the reorder level and [coverDays] of sales, less what is in stock,
  /// rounded up to whole units.
  static List<ReorderSuggestion> suggest(
    Iterable<ReorderInput> products, {
    int coverDays = 30,
    int leadDays = 7,
  }) {
    final out = <ReorderSuggestion>[];
    for (final p in products) {
      final sold = p.soldLast30Milli < 0 ? 0 : p.soldLast30Milli;
      final atLevel =
          p.reorderLevelMilli > 0 && p.stockMilli <= p.reorderLevelMilli;
      final runsOut = sold > 0 && p.stockMilli * 30 < sold * leadDays;
      if (!atLevel && !runsOut) continue;
      final cover = (sold * coverDays + 29) ~/ 30;
      final target = cover > p.reorderLevelMilli ? cover : p.reorderLevelMilli;
      final short = target - (p.stockMilli < 0 ? 0 : p.stockMilli);
      final units = short <= 0 ? 1 : (short + 999) ~/ 1000;
      out.add(
        ReorderSuggestion(
          productId: p.productId,
          name: p.name,
          stockMilli: p.stockMilli,
          reorderLevelMilli: p.reorderLevelMilli,
          soldLast30Milli: sold,
          suggestedMilli: units * 1000,
          daysOfStock: p.stockMilli <= 0
              ? 0
              : (sold > 0 ? p.stockMilli * 30 ~/ sold : null),
        ),
      );
    }
    return out..sort((a, b) {
      final x = a.daysOfStock ?? 1 << 30;
      final y = b.daysOfStock ?? 1 << 30;
      final c = x.compareTo(y);
      return c != 0 ? c : a.name.compareTo(b.name);
    });
  }
}

// ---------------------------------------------------------------------------
// Expiry
// ---------------------------------------------------------------------------

enum ExpiryBucket { expired, within30, within60, within90, later }

@immutable
final class ExpiryRow {
  const ExpiryRow({
    required this.batch,
    required this.productName,
    required this.bucket,
    required this.daysLeft,
  });

  final StockBatch batch;
  final String productName;
  final ExpiryBucket bucket;

  /// Negative when expired.
  final int daysLeft;

  Money get value => batch.value;
}

abstract final class ExpiryReport {
  static ExpiryBucket bucketOf(LedgerDate expiry, LedgerDate today) {
    final days = today.daysUntil(expiry);
    if (days < 0) return ExpiryBucket.expired;
    if (days <= 30) return ExpiryBucket.within30;
    if (days <= 60) return ExpiryBucket.within60;
    if (days <= 90) return ExpiryBucket.within90;
    return ExpiryBucket.later;
  }

  /// Batches with stock that expire, soonest first, each in its bucket.
  /// Batches without an expiry or without stock are left out.
  static List<ExpiryRow> rows(
    Iterable<(StockBatch, String)> batchesWithNames, {
    required LedgerDate today,
  }) {
    final out = <ExpiryRow>[
      for (final (b, name) in batchesWithNames)
        if (b.expiry != null && b.remainingMilli > 0)
          ExpiryRow(
            batch: b,
            productName: name,
            bucket: bucketOf(b.expiry!, today),
            daysLeft: today.daysUntil(b.expiry!),
          ),
    ];
    return out..sort((a, b) {
      final c = a.daysLeft.compareTo(b.daysLeft);
      return c != 0 ? c : a.productName.compareTo(b.productName);
    });
  }

  /// Stock value at cost per bucket.
  static Map<ExpiryBucket, Money> valueByBucket(Iterable<ExpiryRow> rows) {
    final out = {for (final b in ExpiryBucket.values) b: Money.zero};
    for (final r in rows) {
      out[r.bucket] = out[r.bucket]! + r.value;
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// GSTR-1
// ---------------------------------------------------------------------------

/// The unit codes GSTN knows for the units a product can have.
abstract final class Gstr1Uqc {
  static const _codes = {
    'bag': 'BAG',
    'btl': 'BTL',
    'ltr': 'LTR',
    'kg': 'KGS',
    'pkt': 'PAC',
    'pc': 'PCS',
  };

  static String of(String unit) => _codes[unit] ?? 'OTH';
}

@immutable
final class Gstr1Line {
  const Gstr1Line({
    required this.hsn,
    required this.rateBp,
    required this.qtyMilli,
    required this.split,
    this.uqc = 'OTH',
  });

  final String hsn;

  /// Null = the product has no rate.
  final int? rateBp;
  final int qtyMilli;
  final String uqc;
  final GstSplit split;
}

/// A sales invoice, or a credit note ([isCreditNote]: a sales return).
@immutable
final class Gstr1Invoice {
  const Gstr1Invoice({
    required this.number,
    required this.date,
    required this.customerName,
    required this.placeOfSupply,
    required this.lines,
    this.gstin,
    this.roundOff = Money.zero,
    this.isCreditNote = false,
  });

  final String number;
  final LedgerDate date;
  final String customerName;

  /// Customer's GSTIN; only a valid one makes the invoice B2B.
  final String? gstin;

  /// State code the supply is taxed in.
  final String placeOfSupply;
  final List<Gstr1Line> lines;
  final Money roundOff;
  final bool isCreditNote;

  bool get isRegistered => gstin != null && GstStates.isValidGstin(gstin!);

  Money get value =>
      lines.fold(Money.zero, (a, l) => a + l.split.total) + roundOff;

  /// Totals per rate (null rate = 0).
  Map<int, GstSplit> get byRate {
    final out = <int, GstSplit>{};
    for (final l in lines) {
      out.update(l.rateBp ?? 0, (s) => s + l.split, ifAbsent: () => l.split);
    }
    return Map.fromEntries(
      out.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}

@immutable
final class Gstr1Issue {
  const Gstr1Issue(this.invoiceNumber, this.lineIndex, this.issue);

  final String invoiceNumber;
  final int lineIndex;
  final GstIssue issue;
}

/// A B2CS row: unregistered, grouped by place of supply and rate.
@immutable
final class Gstr1B2cs {
  const Gstr1B2cs({
    required this.placeOfSupply,
    required this.interState,
    required this.rateBp,
    required this.split,
  });

  final String placeOfSupply;
  final bool interState;
  final int rateBp;
  final GstSplit split;

  /// GSTN's `sply_ty`.
  String get supplyType => interState ? 'INTER' : 'INTRA';
}

/// One document series in the document summary.
@immutable
final class Gstr1DocRange {
  const Gstr1DocRange({
    required this.nature,
    required this.from,
    required this.to,
    required this.count,
  });

  final String nature;
  final String from;
  final String to;
  final int count;
}

/// The GSTR-1 style return of a period (docs/domain/shop-rules.md
/// section 4): B2B, B2CL, B2CS, credit notes, HSN and document summaries.
/// Credit notes of an unregistered customer are netted into B2CS (negative
/// rows) unless inter-state and above the B2CL limit (CDNUR).
final class Gstr1Report {
  Gstr1Report._({
    required this.tenantGstin,
    required this.tenantStateCode,
    required this.year,
    required this.month,
    required this.b2b,
    required this.b2cl,
    required this.b2cs,
    required this.cdnr,
    required this.cdnur,
    required this.hsn,
    required this.docs,
    required this.issues,
  });

  /// Sorts [invoices] (supplies and credit notes of one month) into the
  /// tables. [b2clLimit] is the invoice value above which an inter-state
  /// sale to an unregistered customer is listed one by one (Rs 1,00,000;
  /// confirm with the CA).
  factory Gstr1Report.build({
    required List<Gstr1Invoice> invoices,
    required String tenantGstin,
    required String tenantStateCode,
    required int year,
    required int month,
    Money b2clLimit = const Money.rupees(100000),
  }) {
    final b2b = <Gstr1Invoice>[];
    final b2cl = <Gstr1Invoice>[];
    final cdnr = <Gstr1Invoice>[];
    final cdnur = <Gstr1Invoice>[];
    final b2csMap = <(String, int), Gstr1B2cs>{};
    final hsnInputs = <HsnInput>[];
    final issues = <Gstr1Issue>[];

    void addB2cs(Gstr1Invoice inv, {required bool negate}) {
      final inter = PlaceOfSupply.isInterState(
        tenantStateCode,
        inv.placeOfSupply,
      );
      for (final e in inv.byRate.entries) {
        final key = (inv.placeOfSupply, e.key);
        final old = b2csMap[key];
        final split = negate ? -e.value : e.value;
        b2csMap[key] = Gstr1B2cs(
          placeOfSupply: inv.placeOfSupply,
          interState: inter,
          rateBp: e.key,
          split: old == null ? split : old.split + split,
        );
      }
    }

    final sorted = [...invoices]
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.number.compareTo(b.number);
      });
    for (final inv in sorted) {
      final inter = PlaceOfSupply.isInterState(
        tenantStateCode,
        inv.placeOfSupply,
      );
      final large = inter && inv.value > b2clLimit;
      if (inv.isCreditNote) {
        if (inv.isRegistered) {
          cdnr.add(inv);
        } else if (large) {
          cdnur.add(inv);
        } else {
          addB2cs(inv, negate: true);
        }
      } else if (inv.isRegistered) {
        b2b.add(inv);
      } else if (large) {
        b2cl.add(inv);
      } else {
        addB2cs(inv, negate: false);
      }
      for (var i = 0; i < inv.lines.length; i++) {
        final l = inv.lines[i];
        for (final issue in GstChecks.issues(hsn: l.hsn, rateBp: l.rateBp)) {
          issues.add(Gstr1Issue(inv.number, i, issue));
        }
        hsnInputs.add(
          HsnInput(
            hsn: l.hsn,
            rateBp: l.rateBp ?? 0,
            qtyMilli: inv.isCreditNote ? -l.qtyMilli : l.qtyMilli,
            split: inv.isCreditNote ? -l.split : l.split,
          ),
        );
      }
    }
    final units = <String, String>{
      for (final inv in sorted)
        for (final l in inv.lines) l.hsn: l.uqc,
    };
    final hsn = HsnSummary.build(hsnInputs);
    return Gstr1Report._(
      tenantGstin: tenantGstin,
      tenantStateCode: tenantStateCode,
      year: year,
      month: month,
      b2b: b2b,
      b2cl: b2cl,
      b2cs: b2csMap.values.toList()
        ..sort((a, b) {
          final c = a.placeOfSupply.compareTo(b.placeOfSupply);
          return c != 0 ? c : a.rateBp.compareTo(b.rateBp);
        }),
      cdnr: cdnr,
      cdnur: cdnur,
      hsn: hsn,
      docs: _docRanges(sorted),
      issues: issues,
    ).._units.addAll(units);
  }

  final String tenantGstin;
  final String tenantStateCode;
  final int year;
  final int month;
  final List<Gstr1Invoice> b2b;
  final List<Gstr1Invoice> b2cl;
  final List<Gstr1B2cs> b2cs;
  final List<Gstr1Invoice> cdnr;
  final List<Gstr1Invoice> cdnur;
  final List<HsnRow> hsn;
  final List<Gstr1DocRange> docs;

  /// Lines with a missing or invalid HSN or rate.
  final List<Gstr1Issue> issues;

  final Map<String, String> _units = {};

  static const _invoiceNature = 'Invoices for outward supply';
  static const _creditNature = 'Credit Note';

  static final _numberPattern = RegExp(r'^(.*?)(\d+)$');

  static List<Gstr1DocRange> _docRanges(List<Gstr1Invoice> invoices) {
    final groups = <(String, String), List<String>>{};
    for (final inv in invoices) {
      final m = _numberPattern.firstMatch(inv.number);
      final series = m == null ? inv.number : m[1]!;
      groups
          .putIfAbsent((
            inv.isCreditNote ? _creditNature : _invoiceNature,
            series,
          ), () => [])
          .add(inv.number);
    }
    int counter(String n) {
      final m = _numberPattern.firstMatch(n);
      return m == null ? 0 : int.parse(m[2]!);
    }

    final out = <Gstr1DocRange>[];
    for (final e in groups.entries) {
      final nums = e.value..sort((a, b) => counter(a).compareTo(counter(b)));
      out.add(
        Gstr1DocRange(
          nature: e.key.$1,
          from: nums.first,
          to: nums.last,
          count: nums.length,
        ),
      );
    }
    return out..sort((a, b) {
      final c = a.nature.compareTo(b.nature);
      return c != 0 ? c : a.from.compareTo(b.from);
    });
  }

  /// `MMYYYY`, the filing period.
  String get filingPeriod =>
      '${month.toString().padLeft(2, '0')}${year.toString().padLeft(4, '0')}';

  // -- tables ---------------------------------------------------------------

  static ReportTable _invoiceTable(
    List<Gstr1Invoice> invoices,
    ReportTitle t, {
    required bool withGstin,
    required String numberTitle,
  }) {
    final rows = <List<Object?>>[];
    for (final inv in invoices) {
      for (final e in inv.byRate.entries) {
        rows.add([
          if (withGstin) inv.gstin,
          inv.customerName,
          inv.number,
          inv.date,
          inv.value,
          inv.placeOfSupply,
          GstRates.format(e.key),
          e.value.taxable,
          e.value.igst,
          e.value.cgst,
          e.value.sgst,
        ]);
      }
    }
    return ReportTable(
      columns: [
        if (withGstin) ReportColumn(t('GSTIN'), ReportColumnKind.text),
        ReportColumn(t('Customer'), ReportColumnKind.text),
        ReportColumn(t(numberTitle), ReportColumnKind.text),
        ReportColumn(t('Date'), ReportColumnKind.date),
        ReportColumn(t('Invoice value'), ReportColumnKind.money),
        ReportColumn(t('Place of supply'), ReportColumnKind.text),
        ReportColumn(t('Rate %'), ReportColumnKind.text),
        ReportColumn(t('Taxable value'), ReportColumnKind.money),
        ReportColumn(t('IGST'), ReportColumnKind.money),
        ReportColumn(t('CGST'), ReportColumnKind.money),
        ReportColumn(t('SGST'), ReportColumnKind.money),
      ],
      rows: rows,
    );
  }

  ReportTable b2bTable({ReportTitle title = _en}) =>
      _invoiceTable(b2b, title, withGstin: true, numberTitle: 'Invoice no');

  ReportTable b2clTable({ReportTitle title = _en}) =>
      _invoiceTable(b2cl, title, withGstin: false, numberTitle: 'Invoice no');

  /// Credit notes to registered customers, then the others.
  ReportTable cdnTable({ReportTitle title = _en}) => _invoiceTable(
    [...cdnr, ...cdnur],
    title,
    withGstin: true,
    numberTitle: 'Credit note no',
  );

  ReportTable b2csTable({ReportTitle title = _en}) => ReportTable(
    columns: [
      ReportColumn(title('Type'), ReportColumnKind.text),
      ReportColumn(title('Place of supply'), ReportColumnKind.text),
      ReportColumn(title('Rate %'), ReportColumnKind.text),
      ReportColumn(title('Taxable value'), ReportColumnKind.money),
      ReportColumn(title('IGST'), ReportColumnKind.money),
      ReportColumn(title('CGST'), ReportColumnKind.money),
      ReportColumn(title('SGST'), ReportColumnKind.money),
    ],
    rows: [
      for (final r in b2cs)
        [
          r.supplyType,
          r.placeOfSupply,
          GstRates.format(r.rateBp),
          r.split.taxable,
          r.split.igst,
          r.split.cgst,
          r.split.sgst,
        ],
    ],
  );

  ReportTable hsnTable({ReportTitle title = _en}) {
    final rows = [
      for (final h in hsn)
        [
          h.hsn,
          _units[h.hsn] ?? 'OTH',
          h.qtyMilli,
          GstRates.format(h.rateBp),
          h.split.total,
          h.split.taxable,
          h.split.igst,
          h.split.cgst,
          h.split.sgst,
        ],
    ];
    return ReportTable(
      columns: [
        ReportColumn(title('HSN'), ReportColumnKind.text),
        ReportColumn(title('Unit'), ReportColumnKind.text),
        ReportColumn(title('Qty'), ReportColumnKind.quantity),
        ReportColumn(title('Rate %'), ReportColumnKind.text),
        ReportColumn(title('Total value'), ReportColumnKind.money),
        ReportColumn(title('Taxable value'), ReportColumnKind.money),
        ReportColumn(title('IGST'), ReportColumnKind.money),
        ReportColumn(title('CGST'), ReportColumnKind.money),
        ReportColumn(title('SGST'), ReportColumnKind.money),
      ],
      rows: rows,
    );
  }

  ReportTable docsTable({ReportTitle title = _en}) => ReportTable(
    columns: [
      ReportColumn(title('Nature of document'), ReportColumnKind.text),
      ReportColumn(title('From'), ReportColumnKind.text),
      ReportColumn(title('To'), ReportColumnKind.text),
      ReportColumn(title('Total'), ReportColumnKind.number),
    ],
    rows: [
      for (final d in docs) [d.nature, d.from, d.to, d.count],
    ],
  );

  // -- JSON -----------------------------------------------------------------

  // Rupee amounts become JSON numbers only here, at the file boundary; no
  // arithmetic is ever done on them.
  static num _rs(Money m) => num.parse(m.plainRupees);

  static String _dt(LedgerDate d) =>
      '${d.day.toString().padLeft(2, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-${d.year}';

  static Map<String, Object?> _itemDetail(int rateBp, GstSplit s) => {
    'rt': num.parse(GstRates.format(rateBp)),
    'txval': _rs(s.taxable),
    if (s.igst.isPositive || s.igst.isNegative) 'iamt': _rs(s.igst),
    if (s.cgst.isPositive || s.cgst.isNegative) 'camt': _rs(s.cgst),
    if (s.sgst.isPositive || s.sgst.isNegative) 'samt': _rs(s.sgst),
    'csamt': 0,
  };

  static List<Map<String, Object?>> _items(Gstr1Invoice inv) => [
    for (final (i, e) in inv.byRate.entries.indexed)
      {'num': i + 1, 'itm_det': _itemDetail(e.key, e.value)},
  ];

  Map<String, Object?> _invJson(Gstr1Invoice inv, {required bool full}) => {
    'inum': inv.number,
    'idt': _dt(inv.date),
    'val': _rs(inv.value),
    'pos': inv.placeOfSupply,
    if (full) 'rchrg': 'N',
    if (full) 'inv_typ': 'R',
    'itms': _items(inv),
  };

  Map<String, Object?> _noteJson(Gstr1Invoice inv) => {
    'ntty': 'C',
    'nt_num': inv.number,
    'nt_dt': _dt(inv.date),
    'val': _rs(inv.value),
    'pos': inv.placeOfSupply,
    'itms': _items(inv),
  };

  /// The return in the shape of the GST portal's offline JSON (GSTR-1),
  /// ready for `jsonEncode`.
  Map<String, Object?> toJson() {
    List<Map<String, Object?>> byKey(
      List<Gstr1Invoice> list,
      String key,
      String listKey,
      Map<String, Object?> Function(Gstr1Invoice) one,
      String Function(Gstr1Invoice) groupBy,
    ) {
      final groups = <String, List<Gstr1Invoice>>{};
      for (final i in list) {
        groups.putIfAbsent(groupBy(i), () => []).add(i);
      }
      return [
        for (final e in groups.entries)
          {
            key: e.key,
            listKey: [for (final i in e.value) one(i)],
          },
      ];
    }

    return {
      'gstin': tenantGstin,
      'fp': filingPeriod,
      'b2b': byKey(
        b2b,
        'ctin',
        'inv',
        (i) => _invJson(i, full: true),
        (i) => i.gstin!.toUpperCase().replaceAll(RegExp(r'\s'), ''),
      ),
      'b2cl': byKey(
        b2cl,
        'pos',
        'inv',
        (i) => _invJson(i, full: false)..remove('pos'),
        (i) => i.placeOfSupply,
      ),
      'b2cs': [
        for (final r in b2cs)
          {
            'sply_ty': r.supplyType,
            'pos': r.placeOfSupply,
            'typ': 'OE',
            ..._itemDetail(r.rateBp, r.split),
          },
      ],
      'cdnr': byKey(
        cdnr,
        'ctin',
        'nt',
        (i) => _noteJson(i)..addAll({'rchrg': 'N', 'inv_typ': 'R'}),
        (i) => i.gstin!.toUpperCase().replaceAll(RegExp(r'\s'), ''),
      ),
      'cdnur': [
        for (final i in cdnur) {'typ': 'B2CL', ..._noteJson(i)},
      ],
      'hsn': {
        'data': [
          for (final (i, h) in hsn.indexed)
            {
              'num': i + 1,
              'hsn_sc': h.hsn,
              'uqc': _units[h.hsn] ?? 'OTH',
              'qty': num.parse(Qty.format(h.qtyMilli)),
              'val': _rs(h.split.total),
              'txval': _rs(h.split.taxable),
              'iamt': _rs(h.split.igst),
              'camt': _rs(h.split.cgst),
              'samt': _rs(h.split.sgst),
              'csamt': 0,
            },
        ],
      },
      'doc_issue': {
        'doc_det': [
          for (final nature in {for (final d in docs) d.nature})
            {
              'doc_typ': nature,
              'docs': [
                for (final (i, d)
                    in docs.where((d) => d.nature == nature).indexed)
                  {
                    'num': i + 1,
                    'from': d.from,
                    'to': d.to,
                    'totnum': d.count,
                    'cancel': 0,
                    'net_issue': d.count,
                  },
              ],
            },
        ],
      },
    };
  }
}
