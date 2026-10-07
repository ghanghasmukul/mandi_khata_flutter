import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// A product whose tax data would fail a GST filing.
@immutable
final class GstProductFlag {
  const GstProductFlag({
    required this.productId,
    required this.sku,
    required this.name,
    required this.hsn,
    required this.rateBp,
    required this.issues,
  });

  final String productId;
  final String sku;
  final String name;
  final String? hsn;
  final int? rateBp;
  final List<GstIssue> issues;
}

/// Totals of a group of invoices (credit notes count negative).
@immutable
final class GstTotals {
  const GstTotals({
    this.count = 0,
    this.taxable = Money.zero,
    this.cgst = Money.zero,
    this.sgst = Money.zero,
    this.igst = Money.zero,
  });

  final int count;
  final Money taxable;
  final Money cgst;
  final Money sgst;
  final Money igst;

  Money get tax => cgst + sgst + igst;
  Money get total => taxable + tax;

  GstTotals add(Gstr1Invoice inv) {
    var s = GstSplit.zero;
    for (final l in inv.lines) {
      s += l.split;
    }
    if (inv.isCreditNote) s = -s;
    return GstTotals(
      count: count + 1,
      taxable: taxable + s.taxable,
      cgst: cgst + s.cgst,
      sgst: sgst + s.sgst,
      igst: igst + s.igst,
    );
  }
}

/// The shape of a period: registered (B2B) and unregistered (B2C) sales,
/// the credit notes, and the whole.
@immutable
final class GstSummary {
  const GstSummary({
    required this.b2b,
    required this.b2c,
    required this.creditNotes,
    required this.net,
  });

  factory GstSummary.of(Iterable<Gstr1Invoice> invoices) {
    var b2b = const GstTotals();
    var b2c = const GstTotals();
    var notes = const GstTotals();
    var net = const GstTotals();
    for (final inv in invoices) {
      net = net.add(inv);
      if (inv.isCreditNote) {
        notes = notes.add(inv);
      } else if (inv.isRegistered) {
        b2b = b2b.add(inv);
      } else {
        b2c = b2c.add(inv);
      }
    }
    return GstSummary(b2b: b2b, b2c: b2c, creditNotes: notes, net: net);
  }

  final GstTotals b2b;
  final GstTotals b2c;

  /// Negative amounts: they reduce the period's tax.
  final GstTotals creditNotes;

  /// Sales less credit notes.
  final GstTotals net;
}

/// Everything the GST screen shows for one month.
@immutable
final class GstMonthData {
  const GstMonthData({
    required this.report,
    required this.invoices,
    required this.summary,
    required this.flags,
    required this.tenantGstin,
    required this.tenantStateCode,
  });

  final Gstr1Report report;
  final List<Gstr1Invoice> invoices;
  final GstSummary summary;
  final List<GstProductFlag> flags;
  final String tenantGstin;
  final String tenantStateCode;

  bool get gstinMissing => !GstStates.isValidGstin(tenantGstin);
  bool get stateMissing => !GstStates.isValid(tenantStateCode);
}
