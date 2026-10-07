import 'package:meta/meta.dart';

/// Kinds of numbered documents. [code] is the stable `number_series.series`
/// value; the printed prefix comes from `business.number_series.<doc>` and
/// may be changed by the owner without resetting counters.
enum DocumentSeries {
  receipt('R', 'receipt'),
  lot('L', 'lot'),
  salesInvoice('SI', 'sales_invoice'),
  purchaseInvoice('PI', 'purchase_invoice'),
  karza('KZ', 'karza'),
  voucher('V', 'voucher'),

  /// Party codes made on a device (`P-W1-0001`); editable before saving.
  party('P', 'party'),

  /// Vouchers entered on the accounts screen (step 3.2), one series each.
  contraVoucher('CV', 'contra_voucher'),
  paymentVoucher('PY', 'payment_voucher'),
  receiptVoucher('RC', 'receipt_voucher'),
  salesVoucher('SV', 'sales_voucher'),
  purchaseVoucher('PU', 'purchase_voucher'),
  journalVoucher('JV', 'journal_voucher'),

  /// Expenses (step 3.4).
  expense('EX', 'expense'),

  /// The shop (phase 4): sales return, purchase bill, purchase return.
  salesReturn('SR', 'sales_return'),
  purchaseBill('PB', 'purchase_bill'),
  purchaseReturn('PR', 'purchase_return');

  const DocumentSeries(this.code, this.doc);

  final String code;

  /// Suffix of the settings key.
  final String doc;

  String get settingKey => 'business.number_series.$doc';
}

/// A document number split into its parts.
@immutable
class DocumentNumber {
  const DocumentNumber(this.prefix, this.deviceCode, this.counter);

  final String prefix;
  final String deviceCode;
  final int counter;

  @override
  String toString() => formatDocumentNumber(prefix, deviceCode, counter);
}

final _prefix = RegExp(r'^[A-Z]{1,4}-$');
final _deviceCode = RegExp(r'^[A-Z][0-9]{1,3}$');
final _number = RegExp(r'^([A-Z]{1,4}-)([A-Z][0-9]{1,3})-(\d{4,})$');

/// `R-` + `W1` + 42 → `R-W1-0042` (CLAUDE.md rule 10). The device code keeps
/// numbers made offline on different devices from ever colliding; the
/// counter is padded to 4 digits and simply grows beyond that.
String formatDocumentNumber(String prefix, String deviceCode, int counter) {
  if (!_prefix.hasMatch(prefix)) {
    throw ArgumentError.value(prefix, 'prefix', 'expected e.g. "R-"');
  }
  if (!_deviceCode.hasMatch(deviceCode)) {
    throw ArgumentError.value(deviceCode, 'deviceCode', 'expected e.g. "W1"');
  }
  if (counter < 1) throw ArgumentError.value(counter, 'counter', 'must be ≥ 1');
  return '$prefix$deviceCode-${counter.toString().padLeft(4, '0')}';
}

/// The parts of a number made by [formatDocumentNumber]; null otherwise.
DocumentNumber? parseDocumentNumber(String text) {
  final m = _number.firstMatch(text.trim());
  if (m == null) return null;
  return DocumentNumber(m[1]!, m[2]!, int.parse(m[3]!));
}
