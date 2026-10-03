import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

/// Turns report rows into a [ReportTable] in the user's language. Pure: the
/// same table feeds the screen and every export, so they can never differ.
abstract final class ReportTables {
  static ReportColumn _text(String t) => ReportColumn(t, ReportColumnKind.text);
  static ReportColumn _date(String t) => ReportColumn(t, ReportColumnKind.date);
  static ReportColumn _money(String t) =>
      ReportColumn(t, ReportColumnKind.money);
  static ReportColumn _number(String t) =>
      ReportColumn(t, ReportColumnKind.number);
  static ReportColumn _qty(String t) =>
      ReportColumn(t, ReportColumnKind.quantity);

  static String ageingName(AppLocalizations l10n, AgeingBucket b) =>
      switch (b) {
        AgeingBucket.upTo30 => l10n.reportAgeUpTo30,
        AgeingBucket.upTo90 => l10n.reportAgeUpTo90,
        AgeingBucket.upTo180 => l10n.reportAgeUpTo180,
        AgeingBucket.over180 => l10n.reportAgeOver180,
      };

  /// Money per ageing bucket, payable and receivable side by side.
  static Map<AgeingBucket, ({Money weOwe, Money theyOwe})> ageingTotals(
    List<OutstandingRow> rows,
    LedgerDate asOf,
  ) {
    final out = {
      for (final b in AgeingBucket.values)
        b: (weOwe: Money.zero, theyOwe: Money.zero),
    };
    for (final r in rows) {
      final b = Ageing.bucketOf(r.lastEntry, asOf);
      final t = out[b]!;
      out[b] = r.weOwe
          ? (weOwe: t.weOwe + r.balance, theyOwe: t.theyOwe)
          : (weOwe: t.weOwe, theyOwe: t.theyOwe - r.balance);
    }
    return out;
  }

  static ReportTable outstanding(
    AppLocalizations l10n,
    List<OutstandingRow> rows,
    LedgerDate asOf,
  ) {
    var owe = Money.zero;
    var owed = Money.zero;
    final cells = <List<Object?>>[];
    for (final r in rows) {
      if (r.weOwe) {
        owe += r.balance;
      } else {
        owed -= r.balance;
      }
      cells.add([
        r.code,
        r.name,
        r.village,
        if (r.weOwe) r.balance else null,
        if (!r.weOwe) r.balance.abs() else null,
        r.lastEntry,
        Ageing.daysSince(r.lastEntry, asOf),
        ageingName(l10n, Ageing.bucketOf(r.lastEntry, asOf)),
      ]);
    }
    return ReportTable(
      columns: [
        _text(l10n.reportColCode),
        _text(l10n.reportColParty),
        _text(l10n.reportColVillage),
        _money(l10n.reportColWeOwe),
        _money(l10n.reportColTheyOwe),
        _date(l10n.reportColLastEntry),
        _number(l10n.reportColDays),
        _text(l10n.reportColAgeing),
      ],
      rows: cells,
      totals: [l10n.reportTotal, null, null, owe, owed, null, null, null],
    );
  }

  static ReportTable arrivals(
    AppLocalizations l10n,
    List<ArrivalRow> rows,
    String language,
  ) {
    var bags = 0;
    var qtl = 0;
    var gross = Money.zero;
    var charges = Money.zero;
    var net = Money.zero;
    for (final r in rows) {
      bags += r.bags;
      qtl += r.qtlMilli ?? 0;
      gross += r.gross ?? Money.zero;
      charges += r.deductions ?? Money.zero;
      net += r.netToFarmer ?? Money.zero;
    }
    return ReportTable(
      columns: [
        _text(l10n.reportColLot),
        _date(l10n.reportColDate),
        _text(l10n.reportColFarmer),
        _text(l10n.reportColCrop),
        _number(l10n.reportColBags),
        _qty(l10n.reportColQtl),
        _money(l10n.reportColRate),
        _money(l10n.reportColGross),
        _money(l10n.reportColCharges),
        _money(l10n.reportColNet),
        _text(l10n.reportColBuyer),
        _text(l10n.reportColStatus),
      ],
      rows: [
        for (final r in rows)
          [
            r.lotNo,
            r.date,
            r.farmerName,
            r.crop.pick(language),
            r.bags,
            r.qtlMilli,
            r.ratePerQtl,
            r.gross,
            r.deductions,
            r.netToFarmer,
            r.buyerName,
            l10n.lotStatusName(r.status),
          ],
      ],
      totals: [
        l10n.reportTotal,
        null,
        null,
        null,
        bags,
        qtl,
        null,
        gross,
        charges,
        net,
        null,
        null,
      ],
    );
  }

  static ReportTable commission(
    AppLocalizations l10n,
    List<CommissionRow> rows,
    String language,
  ) {
    var lots = 0;
    var qtl = 0;
    var gross = Money.zero;
    var arhat = Money.zero;
    for (final r in rows) {
      lots += r.lots;
      qtl += r.qtlMilli;
      gross += r.gross;
      arhat += r.commission;
    }
    return ReportTable(
      columns: [
        _text(l10n.reportColCrop),
        _number(l10n.reportColLots),
        _qty(l10n.reportColQtl),
        _money(l10n.reportColSaleValue),
        _money(l10n.reportColArhat),
      ],
      rows: [
        for (final r in rows)
          [r.crop.pick(language), r.lots, r.qtlMilli, r.gross, r.commission],
      ],
      totals: [l10n.reportTotal, lots, qtl, gross, arhat],
    );
  }

  static ReportTable payments(AppLocalizations l10n, List<PaymentRow> rows) {
    var received = Money.zero;
    var paid = Money.zero;
    final cells = <List<Object?>>[];
    for (final r in rows) {
      final isReceipt = r.direction == PaymentDirection.fromParty;
      if (isReceipt) {
        received += r.amount;
      } else {
        paid += r.amount;
      }
      cells.add([
        r.receiptNo,
        r.date,
        [r.partyName, if (r.partyCode != null) '(${r.partyCode})'].join(' '),
        l10n.paymentModeName(r.mode),
        if (isReceipt) r.amount else null,
        if (!isReceipt) r.amount else null,
        r.reference,
      ]);
    }
    return ReportTable(
      columns: [
        _text(l10n.reportColReceipt),
        _date(l10n.reportColDate),
        _text(l10n.reportColParty),
        _text(l10n.reportColMode),
        _money(l10n.reportColReceived),
        _money(l10n.reportColPaid),
        _text(l10n.reportColReference),
      ],
      rows: cells,
      totals: [l10n.reportTotal, null, null, null, received, paid, null],
    );
  }

  /// Received and paid per mode, in the register's order.
  static Map<PaymentMode, ({Money received, Money paid})> modeTotals(
    List<PaymentRow> rows,
  ) {
    final out = <PaymentMode, ({Money received, Money paid})>{};
    for (final r in rows) {
      final t = out[r.mode] ?? (received: Money.zero, paid: Money.zero);
      if (r.direction == PaymentDirection.fromParty) {
        out[r.mode] = (received: t.received + r.amount, paid: t.paid);
      } else {
        out[r.mode] = (received: t.received, paid: t.paid + r.amount);
      }
    }
    return out;
  }

  static ReportTable statements(
    AppLocalizations l10n,
    List<PartyStatement> rows,
  ) {
    var opening = Money.zero;
    var udhaar = Money.zero;
    var jama = Money.zero;
    var closing = Money.zero;
    for (final r in rows) {
      opening += r.statement.opening;
      udhaar += r.statement.totalUdhaar;
      jama += r.statement.totalJama;
      closing += r.statement.closing;
    }
    return ReportTable(
      columns: [
        _text(l10n.reportColCode),
        _text(l10n.reportColParty),
        _text(l10n.reportColVillage),
        _money(l10n.reportColOpening),
        _money(l10n.reportColUdhaar),
        _money(l10n.reportColJama),
        _money(l10n.reportColClosing),
      ],
      rows: [
        for (final r in rows)
          [
            r.code,
            r.name,
            r.village,
            r.statement.opening,
            r.statement.totalUdhaar,
            r.statement.totalJama,
            r.statement.closing,
          ],
      ],
      totals: [l10n.reportTotal, null, null, opening, udhaar, jama, closing],
    );
  }
}
