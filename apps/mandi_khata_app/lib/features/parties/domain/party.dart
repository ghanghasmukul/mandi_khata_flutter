import 'package:flutter/foundation.dart' show immutable, setEquals;
import 'package:khata_core/khata_core.dart';

/// A party as stored locally (active rows only; soft-deleted parties are
/// never shown).
@immutable
class Party {
  const Party({
    required this.id,
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
    this.bankAccountMasked,
    this.ifsc,
    this.gstin,
    this.notes,
    this.partyGroupId,
  });

  /// From a `parties` row plus `roles` = comma-separated active roles.
  factory Party.fromRow(Map<String, Object?> r) => Party(
    id: r['id']! as String,
    code: r['code']! as String,
    name: r['name']! as String,
    roles: {
      for (final s in ((r['roles'] as String?) ?? '').split(','))
        ?PartyRole.parse(s),
    },
    relation: Relation.parse(r['relation'] as String?),
    fatherOrHusbandName: r['father_or_husband_name'] as String?,
    village: r['village'] as String?,
    district: r['district'] as String?,
    state: r['state'] as String?,
    mobile: r['mobile'] as String?,
    altMobile: r['alt_mobile'] as String?,
    aadhaarLast4: r['aadhaar_last4'] as String?,
    bankName: r['bank_name'] as String?,
    bankAccountMasked: r['bank_account_masked'] as String?,
    ifsc: r['ifsc'] as String?,
    gstin: r['gstin'] as String?,
    notes: r['notes'] as String?,
    partyGroupId: r['party_group_id'] as String?,
  );

  final String id;
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
  final String? bankAccountMasked;
  final String? ifsc;
  final String? gstin;
  final String? notes;

  /// Settings group (cascade level between business and party).
  final String? partyGroupId;

  /// Pre-fills the edit form.
  PartyInput toInput() => PartyInput(
    code: code,
    name: name,
    roles: roles,
    relation: relation,
    fatherOrHusbandName: fatherOrHusbandName,
    village: village,
    district: district,
    state: state,
    mobile: mobile,
    altMobile: altMobile,
    aadhaarLast4: aadhaarLast4,
    bankName: bankName,
    bankAccount: bankAccountMasked,
    ifsc: ifsc,
    gstin: gstin,
    notes: notes,
  );

  @override
  bool operator ==(Object other) =>
      other is Party &&
      other.id == id &&
      other.code == code &&
      other.name == name &&
      setEquals(other.roles, roles) &&
      other.relation == relation &&
      other.fatherOrHusbandName == fatherOrHusbandName &&
      other.village == village &&
      other.mobile == mobile &&
      other.notes == notes &&
      other.partyGroupId == partyGroupId;

  @override
  int get hashCode => Object.hash(id, code, name, village, mobile);
}

/// The `parties` columns an input maps to (normalised values).
Map<String, Object?> partyColumns(PartyInput n) => {
  'code': n.code,
  'name': n.name,
  'relation': n.relation?.dbName,
  'father_or_husband_name': n.fatherOrHusbandName,
  'village': n.village,
  'district': n.district,
  'state': n.state,
  'mobile': n.mobile,
  'alt_mobile': n.altMobile,
  'aadhaar_last4': n.aadhaarLast4,
  'bank_name': n.bankName,
  'bank_account_masked': n.bankAccount,
  'ifsc': n.ifsc,
  'gstin': n.gstin,
  'notes': n.notes,
};

/// Why a party could not be saved.
sealed class PartySaveResult {
  const PartySaveResult();
}

final class PartySaved extends PartySaveResult {
  const PartySaved(this.id, this.code);

  final String id;
  final String code;
}

final class PartyInvalid extends PartySaveResult {
  const PartyInvalid(this.errors);

  final Map<PartyField, PartyFieldError> errors;
}

/// Another party in this business already has the code.
final class PartyCodeTaken extends PartySaveResult {
  const PartyCodeTaken();
}

final class PartyNotPermitted extends PartySaveResult {
  const PartyNotPermitted();
}

final class PartyNotFound extends PartySaveResult {
  const PartyNotFound();
}
