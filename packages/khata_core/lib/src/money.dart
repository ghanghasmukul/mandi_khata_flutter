import 'package:meta/meta.dart';

/// How [Money.format] shows the paise part.
enum PaiseDisplay {
  /// Show `.xx` only when the amount has paise (`₹1,109.59`, `₹1,55,580`).
  auto,

  /// Always show two decimals (`₹1,55,580.00`).
  always,

  /// Round to whole rupees, half-up away from zero (`₹1,110`).
  never,
}

/// An amount of Indian money, held as whole paise.
///
/// Money is never a `double` anywhere in Mandi Khata. All arithmetic is integer
/// paise; this type only adds safe operators and Indian-style formatting.
/// Formatting here is display only — it never changes the stored amount.
@immutable
final class Money implements Comparable<Money> {
  const Money(this.paise);

  /// Whole rupees, for constants and tests.
  const Money.rupees(int rupees) : paise = rupees * 100;

  static const zero = Money(0);

  /// Largest number of whole-rupee digits [tryParse] accepts. Keeps every
  /// parsed amount inside the range an `int` holds exactly on the web.
  static const _maxRupeeDigits = 13;

  static const _symbol = '₹';

  /// One lakh rupees and one crore rupees, in paise.
  static const _lakhPaise = 10000000;
  static const _crorePaise = 1000000000;

  final int paise;

  /// Whole rupees, truncated toward zero.
  int get rupees => paise ~/ 100;

  bool get isZero => paise == 0;
  bool get isNegative => paise < 0;
  bool get isPositive => paise > 0;

  Money abs() => Money(paise.abs());

  Money operator +(Money other) => Money(paise + other.paise);
  Money operator -(Money other) => Money(paise - other.paise);
  Money operator -() => Money(-paise);

  bool operator <(Money other) => paise < other.paise;
  bool operator <=(Money other) => paise <= other.paise;
  bool operator >(Money other) => paise > other.paise;
  bool operator >=(Money other) => paise >= other.paise;

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  @override
  bool operator ==(Object other) => other is Money && other.paise == paise;

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() => 'Money($paise paise)';

  /// Full amount with Indian digit grouping: `₹1,55,580`, `₹1,109.59`,
  /// `-₹40`.
  String format({PaiseDisplay paise = PaiseDisplay.auto, bool symbol = true}) {
    final abs = this.paise.abs();
    final String body;
    if (paise == PaiseDisplay.never) {
      body = _groupIndian(_roundHalfUp(abs, 100));
    } else {
      final fraction = abs % 100;
      final whole = _groupIndian(abs ~/ 100);
      body = fraction == 0 && paise == PaiseDisplay.auto
          ? whole
          : '$whole.${fraction.toString().padLeft(2, '0')}';
    }
    return _signed(body, symbol: symbol);
  }

  /// Compact amount for tiles and charts: `₹45,600`, `₹13.28 L`, `₹1.20 Cr`.
  ///
  /// Below one lakh the whole-rupee amount is shown. Lakh and crore values
  /// have two decimals, rounded half-up away from zero; a value that rounds to
  /// 100.00 L is shown as 1.00 Cr.
  String short() {
    final abs = paise.abs();
    final String body;
    if (_roundHalfUp(abs, 100) * 100 < _lakhPaise) {
      body = _groupIndian(_roundHalfUp(abs, 100));
    } else {
      final lakhHundredths = _roundHalfUp(abs, _lakhPaise ~/ 100);
      if (lakhHundredths < 10000) {
        body = '${_twoDecimals(lakhHundredths)} L';
      } else {
        body = '${_twoDecimals(_roundHalfUp(abs, _crorePaise ~/ 100))} Cr';
      }
    }
    return _signed(body, symbol: true);
  }

  /// Parses typed rupee input such as `1,55,580`, `₹1,109.5` or `-40.25`.
  ///
  /// Returns `null` for anything that is not an exact paise amount: more than
  /// two decimals is rejected rather than rounded, so a typing mistake can
  /// never silently change an amount.
  static Money? tryParse(String input) {
    var text = input.replaceAll(RegExp(r'[\s,]'), '');
    var negative = false;
    if (text.startsWith('-$_symbol')) {
      negative = true;
      text = text.substring(2);
    } else if (text.startsWith('$_symbol-')) {
      negative = true;
      text = text.substring(2);
    } else if (text.startsWith(_symbol)) {
      text = text.substring(1);
    } else if (text.startsWith('-')) {
      negative = true;
      text = text.substring(1);
    }

    final match = RegExp(r'^(\d*)(?:\.(\d{0,2}))?$').firstMatch(text);
    if (match == null) return null;
    final whole = match.group(1)!;
    final fraction = match.group(2) ?? '';
    if (whole.isEmpty && fraction.isEmpty) return null;
    if (whole.length > _maxRupeeDigits) return null;

    final rupees = whole.isEmpty ? 0 : int.parse(whole);
    final paise = fraction.isEmpty ? 0 : int.parse(fraction.padRight(2, '0'));
    final total = rupees * 100 + paise;
    return Money(negative ? -total : total);
  }

  String _signed(String body, {required bool symbol}) {
    final prefix = symbol ? _symbol : '';
    return paise < 0 ? '-$prefix$body' : '$prefix$body';
  }

  /// `value / unit` for a non-negative value, rounded half-up.
  static int _roundHalfUp(int value, int unit) => (value + unit ~/ 2) ~/ unit;

  /// `1328` → `13.28`, with Indian grouping on the whole part.
  static String _twoDecimals(int hundredths) {
    final whole = _groupIndian(hundredths ~/ 100);
    return '$whole.${(hundredths % 100).toString().padLeft(2, '0')}';
  }

  /// Indian digit grouping for a non-negative integer: the last three digits,
  /// then groups of two (`12,00,00,000`).
  static String _groupIndian(int value) {
    final digits = value.toString();
    if (digits.length <= 3) return digits;
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final groups = <String>[];
    for (var end = head.length; end > 0; end -= 2) {
      groups.insert(0, head.substring(end - 2 < 0 ? 0 : end - 2, end));
    }
    return '${groups.join(',')},$tail';
  }
}
