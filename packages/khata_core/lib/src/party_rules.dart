import 'package:meta/meta.dart';

/// What a party is to the business (`party_roles.role`). One party can hold
/// several roles.
enum PartyRole {
  farmer,
  customer,
  supplier,
  vendor,
  agency,
  buyer;

  static PartyRole? parse(String value) {
    for (final r in values) {
      if (r.name == value) return r;
    }
    return null;
  }
}

/// `parties.relation`: how the father / husband name reads on a receipt.
enum Relation {
  sonOf('s_o'),
  daughterOf('d_o'),
  wifeOf('w_o'),

  /// A firm's proprietor; no father / husband name needed.
  proprietor('prop');

  const Relation(this.dbName);

  final String dbName;

  static Relation? parse(String? value) {
    for (final r in values) {
      if (r.dbName == value) return r;
    }
    return null;
  }
}

/// Indian mobile numbers as stored on parties: 10 digits, no +91.
abstract final class IndianMobile {
  /// Accepts what people type (`+91 98140-22110`, `098140 22110`, …).
  static String? normalise(String input) {
    var digits = input.replaceAll(RegExp(r'[\s\-().]'), '');
    if (digits.startsWith('+91')) {
      digits = digits.substring(3);
    } else if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits) ? digits : null;
  }
}

/// Bank branch code: 4 letters, `0`, 6 letters/digits (`SBIN0001234`).
abstract final class Ifsc {
  static String? normalise(String input) {
    final v = input.trim().toUpperCase();
    return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v) ? v : null;
  }
}

/// GST number: 2-digit state, PAN, entity, `Z`, check character.
abstract final class Gstin {
  static const _chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final _format = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );

  /// The 15th character for the first 14 (GSTN mod-36 scheme).
  static String checkDigit(String first14) {
    var sum = 0;
    for (var i = 0; i < 14; i++) {
      final product = _chars.indexOf(first14[i]) * (i.isEven ? 1 : 2);
      sum += product ~/ 36 + product % 36;
    }
    return _chars[(36 - sum % 36) % 36];
  }

  static String? normalise(String input) {
    final v = input.trim().toUpperCase();
    if (!_format.hasMatch(v)) return null;
    return checkDigit(v.substring(0, 14)) == v[14] ? v : null;
  }
}

/// Only the last 4 digits of a bank account are ever kept: `XXXX7890`.
String? maskBankAccount(String input) {
  final digits = input.replaceAll(RegExp('[^0-9]'), '');
  if (digits.isEmpty) return null;
  final tail = digits.length <= 4
      ? digits
      : digits.substring(digits.length - 4);
  return 'XXXX$tail';
}

enum PartyField {
  code,
  name,
  fatherOrHusbandName,
  roles,
  mobile,
  altMobile,
  aadhaarLast4,
  ifsc,
  gstin,
}

enum PartyFieldError { required, invalid }

/// What the add / edit party form collects. [validate] and [normalised]
/// are the single source of the rules; the database checks are looser
/// backstops.
@immutable
class PartyInput {
  const PartyInput({
    required this.code,
    required this.name,
    required this.roles,
    this.relation,
    this.fatherOrHusbandName,
    this.village,
    this.district,
    this.state,
    this.mobile,
    this.altMobile,
    this.aadhaarLast4,
    this.bankName,
    this.bankAccount,
    this.ifsc,
    this.gstin,
    this.notes,
  });

  final String code;
  final String name;
  final Set<PartyRole> roles;
  final Relation? relation;
  final String? fatherOrHusbandName;
  final String? village;
  final String? district;
  final String? state;
  final String? mobile;
  final String? altMobile;
  final String? aadhaarLast4;
  final String? bankName;

  /// As typed; [normalised] masks it to the last 4 digits.
  final String? bankAccount;
  final String? ifsc;
  final String? gstin;
  final String? notes;

  PartyInput copyWith({
    String? code,
    String? name,
    Set<PartyRole>? roles,
    Relation? relation,
    String? fatherOrHusbandName,
    String? village,
    String? district,
    String? state,
    String? mobile,
    String? altMobile,
    String? aadhaarLast4,
    String? bankName,
    String? bankAccount,
    String? ifsc,
    String? gstin,
    String? notes,
  }) => PartyInput(
    code: code ?? this.code,
    name: name ?? this.name,
    roles: roles ?? this.roles,
    relation: relation ?? this.relation,
    fatherOrHusbandName: fatherOrHusbandName ?? this.fatherOrHusbandName,
    village: village ?? this.village,
    district: district ?? this.district,
    state: state ?? this.state,
    mobile: mobile ?? this.mobile,
    altMobile: altMobile ?? this.altMobile,
    aadhaarLast4: aadhaarLast4 ?? this.aadhaarLast4,
    bankName: bankName ?? this.bankName,
    bankAccount: bankAccount ?? this.bankAccount,
    ifsc: ifsc ?? this.ifsc,
    gstin: gstin ?? this.gstin,
    notes: notes ?? this.notes,
  );

  static bool _blank(String? v) => v == null || v.trim().isEmpty;

  /// Empty map = valid.
  Map<PartyField, PartyFieldError> validate() {
    final errors = <PartyField, PartyFieldError>{};
    void check(PartyField f, String? v, Object? Function(String) parse) {
      if (!_blank(v) && parse(v!) == null) errors[f] = PartyFieldError.invalid;
    }

    if (_blank(code)) errors[PartyField.code] = PartyFieldError.required;
    if (_blank(name)) errors[PartyField.name] = PartyFieldError.required;
    if (roles.isEmpty) errors[PartyField.roles] = PartyFieldError.required;
    if (relation != null &&
        relation != Relation.proprietor &&
        _blank(fatherOrHusbandName)) {
      errors[PartyField.fatherOrHusbandName] = PartyFieldError.required;
    }
    check(PartyField.mobile, mobile, IndianMobile.normalise);
    check(PartyField.altMobile, altMobile, IndianMobile.normalise);
    check(
      PartyField.aadhaarLast4,
      aadhaarLast4,
      (v) => RegExp(r'^\d{4}$').hasMatch(v.trim()) ? v : null,
    );
    check(PartyField.ifsc, ifsc, Ifsc.normalise);
    check(PartyField.gstin, gstin, Gstin.normalise);
    return errors;
  }

  /// The values to store: trimmed, blanks as null, numbers in canonical
  /// form, bank account masked. Call only when [validate] is empty.
  PartyInput normalised() {
    String? clean(String? v) {
      if (v == null) return null;
      final t = v.trim().replaceAll(RegExp(r'\s+'), ' ');
      return t.isEmpty ? null : t;
    }

    String? mapped(String? v, String? Function(String) f) =>
        _blank(v) ? null : f(v!);

    return PartyInput(
      code: code.trim().toUpperCase(),
      name: clean(name)!,
      roles: roles,
      relation: relation,
      fatherOrHusbandName: relation == Relation.proprietor
          ? null
          : clean(fatherOrHusbandName),
      village: clean(village),
      district: clean(district),
      state: clean(state),
      mobile: mapped(mobile, IndianMobile.normalise),
      altMobile: mapped(altMobile, IndianMobile.normalise),
      aadhaarLast4: clean(aadhaarLast4),
      bankName: clean(bankName),
      bankAccount: mapped(bankAccount, maskBankAccount),
      ifsc: mapped(ifsc, Ifsc.normalise),
      gstin: mapped(gstin, Gstin.normalise),
      notes: notes?.trim().isEmpty ?? true ? null : notes!.trim(),
    );
  }
}
