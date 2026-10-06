// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TenantsTable extends Tenants with TableInfo<$TenantsTable, Tenant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TenantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legalNameMeta = const VerificationMeta(
    'legalName',
  );
  @override
  late final GeneratedColumn<String> legalName = GeneratedColumn<String>(
    'legal_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateCodeMeta = const VerificationMeta(
    'stateCode',
  );
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
    'state_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mandiNameMeta = const VerificationMeta(
    'mandiName',
  );
  @override
  late final GeneratedColumn<String> mandiName = GeneratedColumn<String>(
    'mandi_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planCodeMeta = const VerificationMeta(
    'planCode',
  );
  @override
  late final GeneratedColumn<String> planCode = GeneratedColumn<String>(
    'plan_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trialEndsAtMeta = const VerificationMeta(
    'trialEndsAt',
  );
  @override
  late final GeneratedColumn<String> trialEndsAt = GeneratedColumn<String>(
    'trial_ends_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    legalName,
    gstin,
    address,
    stateCode,
    mandiName,
    phone,
    planCode,
    status,
    trialEndsAt,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tenant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('legal_name')) {
      context.handle(
        _legalNameMeta,
        legalName.isAcceptableOrUnknown(data['legal_name']!, _legalNameMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('state_code')) {
      context.handle(
        _stateCodeMeta,
        stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta),
      );
    }
    if (data.containsKey('mandi_name')) {
      context.handle(
        _mandiNameMeta,
        mandiName.isAcceptableOrUnknown(data['mandi_name']!, _mandiNameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('plan_code')) {
      context.handle(
        _planCodeMeta,
        planCode.isAcceptableOrUnknown(data['plan_code']!, _planCodeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('trial_ends_at')) {
      context.handle(
        _trialEndsAtMeta,
        trialEndsAt.isAcceptableOrUnknown(
          data['trial_ends_at']!,
          _trialEndsAtMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tenant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tenant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      legalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_name'],
      ),
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      stateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_code'],
      ),
      mandiName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mandi_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      planCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_code'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      trialEndsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trial_ends_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TenantsTable createAlias(String alias) {
    return $TenantsTable(attachedDatabase, alias);
  }
}

class Tenant extends DataClass implements Insertable<Tenant> {
  final String id;
  final String name;
  final String? legalName;
  final String? gstin;
  final String? address;
  final String? stateCode;
  final String? mandiName;
  final String? phone;
  final String? planCode;
  final String? status;
  final String? trialEndsAt;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const Tenant({
    required this.id,
    required this.name,
    this.legalName,
    this.gstin,
    this.address,
    this.stateCode,
    this.mandiName,
    this.phone,
    this.planCode,
    this.status,
    this.trialEndsAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || legalName != null) {
      map['legal_name'] = Variable<String>(legalName);
    }
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || stateCode != null) {
      map['state_code'] = Variable<String>(stateCode);
    }
    if (!nullToAbsent || mandiName != null) {
      map['mandi_name'] = Variable<String>(mandiName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || planCode != null) {
      map['plan_code'] = Variable<String>(planCode);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || trialEndsAt != null) {
      map['trial_ends_at'] = Variable<String>(trialEndsAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  TenantsCompanion toCompanion(bool nullToAbsent) {
    return TenantsCompanion(
      id: Value(id),
      name: Value(name),
      legalName: legalName == null && nullToAbsent
          ? const Value.absent()
          : Value(legalName),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      stateCode: stateCode == null && nullToAbsent
          ? const Value.absent()
          : Value(stateCode),
      mandiName: mandiName == null && nullToAbsent
          ? const Value.absent()
          : Value(mandiName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      planCode: planCode == null && nullToAbsent
          ? const Value.absent()
          : Value(planCode),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      trialEndsAt: trialEndsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(trialEndsAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Tenant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tenant(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      legalName: serializer.fromJson<String?>(json['legalName']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      address: serializer.fromJson<String?>(json['address']),
      stateCode: serializer.fromJson<String?>(json['stateCode']),
      mandiName: serializer.fromJson<String?>(json['mandiName']),
      phone: serializer.fromJson<String?>(json['phone']),
      planCode: serializer.fromJson<String?>(json['planCode']),
      status: serializer.fromJson<String?>(json['status']),
      trialEndsAt: serializer.fromJson<String?>(json['trialEndsAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'legalName': serializer.toJson<String?>(legalName),
      'gstin': serializer.toJson<String?>(gstin),
      'address': serializer.toJson<String?>(address),
      'stateCode': serializer.toJson<String?>(stateCode),
      'mandiName': serializer.toJson<String?>(mandiName),
      'phone': serializer.toJson<String?>(phone),
      'planCode': serializer.toJson<String?>(planCode),
      'status': serializer.toJson<String?>(status),
      'trialEndsAt': serializer.toJson<String?>(trialEndsAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Tenant copyWith({
    String? id,
    String? name,
    Value<String?> legalName = const Value.absent(),
    Value<String?> gstin = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> stateCode = const Value.absent(),
    Value<String?> mandiName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> planCode = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> trialEndsAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Tenant(
    id: id ?? this.id,
    name: name ?? this.name,
    legalName: legalName.present ? legalName.value : this.legalName,
    gstin: gstin.present ? gstin.value : this.gstin,
    address: address.present ? address.value : this.address,
    stateCode: stateCode.present ? stateCode.value : this.stateCode,
    mandiName: mandiName.present ? mandiName.value : this.mandiName,
    phone: phone.present ? phone.value : this.phone,
    planCode: planCode.present ? planCode.value : this.planCode,
    status: status.present ? status.value : this.status,
    trialEndsAt: trialEndsAt.present ? trialEndsAt.value : this.trialEndsAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Tenant copyWithCompanion(TenantsCompanion data) {
    return Tenant(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      legalName: data.legalName.present ? data.legalName.value : this.legalName,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      address: data.address.present ? data.address.value : this.address,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      mandiName: data.mandiName.present ? data.mandiName.value : this.mandiName,
      phone: data.phone.present ? data.phone.value : this.phone,
      planCode: data.planCode.present ? data.planCode.value : this.planCode,
      status: data.status.present ? data.status.value : this.status,
      trialEndsAt: data.trialEndsAt.present
          ? data.trialEndsAt.value
          : this.trialEndsAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tenant(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('legalName: $legalName, ')
          ..write('gstin: $gstin, ')
          ..write('address: $address, ')
          ..write('stateCode: $stateCode, ')
          ..write('mandiName: $mandiName, ')
          ..write('phone: $phone, ')
          ..write('planCode: $planCode, ')
          ..write('status: $status, ')
          ..write('trialEndsAt: $trialEndsAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    legalName,
    gstin,
    address,
    stateCode,
    mandiName,
    phone,
    planCode,
    status,
    trialEndsAt,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tenant &&
          other.id == this.id &&
          other.name == this.name &&
          other.legalName == this.legalName &&
          other.gstin == this.gstin &&
          other.address == this.address &&
          other.stateCode == this.stateCode &&
          other.mandiName == this.mandiName &&
          other.phone == this.phone &&
          other.planCode == this.planCode &&
          other.status == this.status &&
          other.trialEndsAt == this.trialEndsAt &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TenantsCompanion extends UpdateCompanion<Tenant> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> legalName;
  final Value<String?> gstin;
  final Value<String?> address;
  final Value<String?> stateCode;
  final Value<String?> mandiName;
  final Value<String?> phone;
  final Value<String?> planCode;
  final Value<String?> status;
  final Value<String?> trialEndsAt;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const TenantsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.legalName = const Value.absent(),
    this.gstin = const Value.absent(),
    this.address = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.mandiName = const Value.absent(),
    this.phone = const Value.absent(),
    this.planCode = const Value.absent(),
    this.status = const Value.absent(),
    this.trialEndsAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TenantsCompanion.insert({
    required String id,
    required String name,
    this.legalName = const Value.absent(),
    this.gstin = const Value.absent(),
    this.address = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.mandiName = const Value.absent(),
    this.phone = const Value.absent(),
    this.planCode = const Value.absent(),
    this.status = const Value.absent(),
    this.trialEndsAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Tenant> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? legalName,
    Expression<String>? gstin,
    Expression<String>? address,
    Expression<String>? stateCode,
    Expression<String>? mandiName,
    Expression<String>? phone,
    Expression<String>? planCode,
    Expression<String>? status,
    Expression<String>? trialEndsAt,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (legalName != null) 'legal_name': legalName,
      if (gstin != null) 'gstin': gstin,
      if (address != null) 'address': address,
      if (stateCode != null) 'state_code': stateCode,
      if (mandiName != null) 'mandi_name': mandiName,
      if (phone != null) 'phone': phone,
      if (planCode != null) 'plan_code': planCode,
      if (status != null) 'status': status,
      if (trialEndsAt != null) 'trial_ends_at': trialEndsAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TenantsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? legalName,
    Value<String?>? gstin,
    Value<String?>? address,
    Value<String?>? stateCode,
    Value<String?>? mandiName,
    Value<String?>? phone,
    Value<String?>? planCode,
    Value<String?>? status,
    Value<String?>? trialEndsAt,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return TenantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      legalName: legalName ?? this.legalName,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      stateCode: stateCode ?? this.stateCode,
      mandiName: mandiName ?? this.mandiName,
      phone: phone ?? this.phone,
      planCode: planCode ?? this.planCode,
      status: status ?? this.status,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (legalName.present) {
      map['legal_name'] = Variable<String>(legalName.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (mandiName.present) {
      map['mandi_name'] = Variable<String>(mandiName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (planCode.present) {
      map['plan_code'] = Variable<String>(planCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (trialEndsAt.present) {
      map['trial_ends_at'] = Variable<String>(trialEndsAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TenantsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('legalName: $legalName, ')
          ..write('gstin: $gstin, ')
          ..write('address: $address, ')
          ..write('stateCode: $stateCode, ')
          ..write('mandiName: $mandiName, ')
          ..write('phone: $phone, ')
          ..write('planCode: $planCode, ')
          ..write('status: $status, ')
          ..write('trialEndsAt: $trialEndsAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUsersTable extends AppUsers with TableInfo<$AppUsersTable, AppUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredLanguageMeta = const VerificationMeta(
    'preferredLanguage',
  );
  @override
  late final GeneratedColumn<String> preferredLanguage =
      GeneratedColumn<String>(
        'preferred_language',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    phone,
    fullName,
    preferredLanguage,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('preferred_language')) {
      context.handle(
        _preferredLanguageMeta,
        preferredLanguage.isAcceptableOrUnknown(
          data['preferred_language']!,
          _preferredLanguageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      preferredLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_language'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUser extends DataClass implements Insertable<AppUser> {
  final String id;
  final String? phone;
  final String? fullName;
  final String? preferredLanguage;
  final String? createdAt;
  final String? updatedAt;
  const AppUser({
    required this.id,
    this.phone,
    this.fullName,
    this.preferredLanguage,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || preferredLanguage != null) {
      map['preferred_language'] = Variable<String>(preferredLanguage);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      id: Value(id),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      preferredLanguage: preferredLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredLanguage),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AppUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUser(
      id: serializer.fromJson<String>(json['id']),
      phone: serializer.fromJson<String?>(json['phone']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      preferredLanguage: serializer.fromJson<String?>(
        json['preferredLanguage'],
      ),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'phone': serializer.toJson<String?>(phone),
      'fullName': serializer.toJson<String?>(fullName),
      'preferredLanguage': serializer.toJson<String?>(preferredLanguage),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  AppUser copyWith({
    String? id,
    Value<String?> phone = const Value.absent(),
    Value<String?> fullName = const Value.absent(),
    Value<String?> preferredLanguage = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => AppUser(
    id: id ?? this.id,
    phone: phone.present ? phone.value : this.phone,
    fullName: fullName.present ? fullName.value : this.fullName,
    preferredLanguage: preferredLanguage.present
        ? preferredLanguage.value
        : this.preferredLanguage,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  AppUser copyWithCompanion(AppUsersCompanion data) {
    return AppUser(
      id: data.id.present ? data.id.value : this.id,
      phone: data.phone.present ? data.phone.value : this.phone,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      preferredLanguage: data.preferredLanguage.present
          ? data.preferredLanguage.value
          : this.preferredLanguage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUser(')
          ..write('id: $id, ')
          ..write('phone: $phone, ')
          ..write('fullName: $fullName, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, phone, fullName, preferredLanguage, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUser &&
          other.id == this.id &&
          other.phone == this.phone &&
          other.fullName == this.fullName &&
          other.preferredLanguage == this.preferredLanguage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUser> {
  final Value<String> id;
  final Value<String?> phone;
  final Value<String?> fullName;
  final Value<String?> preferredLanguage;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const AppUsersCompanion({
    this.id = const Value.absent(),
    this.phone = const Value.absent(),
    this.fullName = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsersCompanion.insert({
    required String id,
    this.phone = const Value.absent(),
    this.fullName = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<AppUser> custom({
    Expression<String>? id,
    Expression<String>? phone,
    Expression<String>? fullName,
    Expression<String>? preferredLanguage,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phone != null) 'phone': phone,
      if (fullName != null) 'full_name': fullName,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? phone,
    Value<String?>? fullName,
    Value<String?>? preferredLanguage,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppUsersCompanion(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (preferredLanguage.present) {
      map['preferred_language'] = Variable<String>(preferredLanguage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('id: $id, ')
          ..write('phone: $phone, ')
          ..write('fullName: $fullName, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TenantMembersTable extends TenantMembers
    with TableInfo<$TenantMembersTable, TenantMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TenantMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customPermissionsMeta = const VerificationMeta(
    'customPermissions',
  );
  @override
  late final GeneratedColumn<String> customPermissions =
      GeneratedColumn<String>(
        'custom_permissions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _deviceLimitMeta = const VerificationMeta(
    'deviceLimit',
  );
  @override
  late final GeneratedColumn<int> deviceLimit = GeneratedColumn<int>(
    'device_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    userId,
    role,
    customPermissions,
    isActive,
    deviceLimit,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenant_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<TenantMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('custom_permissions')) {
      context.handle(
        _customPermissionsMeta,
        customPermissions.isAcceptableOrUnknown(
          data['custom_permissions']!,
          _customPermissionsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('device_limit')) {
      context.handle(
        _deviceLimitMeta,
        deviceLimit.isAcceptableOrUnknown(
          data['device_limit']!,
          _deviceLimitMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TenantMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TenantMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      customPermissions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_permissions'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      ),
      deviceLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_limit'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TenantMembersTable createAlias(String alias) {
    return $TenantMembersTable(attachedDatabase, alias);
  }
}

class TenantMember extends DataClass implements Insertable<TenantMember> {
  final String id;
  final String tenantId;
  final String userId;
  final String role;
  final String? customPermissions;
  final bool? isActive;
  final int? deviceLimit;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const TenantMember({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.role,
    this.customPermissions,
    this.isActive,
    this.deviceLimit,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || customPermissions != null) {
      map['custom_permissions'] = Variable<String>(customPermissions);
    }
    if (!nullToAbsent || isActive != null) {
      map['is_active'] = Variable<bool>(isActive);
    }
    if (!nullToAbsent || deviceLimit != null) {
      map['device_limit'] = Variable<int>(deviceLimit);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  TenantMembersCompanion toCompanion(bool nullToAbsent) {
    return TenantMembersCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      userId: Value(userId),
      role: Value(role),
      customPermissions: customPermissions == null && nullToAbsent
          ? const Value.absent()
          : Value(customPermissions),
      isActive: isActive == null && nullToAbsent
          ? const Value.absent()
          : Value(isActive),
      deviceLimit: deviceLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceLimit),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TenantMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TenantMember(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      customPermissions: serializer.fromJson<String?>(
        json['customPermissions'],
      ),
      isActive: serializer.fromJson<bool?>(json['isActive']),
      deviceLimit: serializer.fromJson<int?>(json['deviceLimit']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'customPermissions': serializer.toJson<String?>(customPermissions),
      'isActive': serializer.toJson<bool?>(isActive),
      'deviceLimit': serializer.toJson<int?>(deviceLimit),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  TenantMember copyWith({
    String? id,
    String? tenantId,
    String? userId,
    String? role,
    Value<String?> customPermissions = const Value.absent(),
    Value<bool?> isActive = const Value.absent(),
    Value<int?> deviceLimit = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => TenantMember(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    customPermissions: customPermissions.present
        ? customPermissions.value
        : this.customPermissions,
    isActive: isActive.present ? isActive.value : this.isActive,
    deviceLimit: deviceLimit.present ? deviceLimit.value : this.deviceLimit,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TenantMember copyWithCompanion(TenantMembersCompanion data) {
    return TenantMember(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      customPermissions: data.customPermissions.present
          ? data.customPermissions.value
          : this.customPermissions,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      deviceLimit: data.deviceLimit.present
          ? data.deviceLimit.value
          : this.deviceLimit,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TenantMember(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('customPermissions: $customPermissions, ')
          ..write('isActive: $isActive, ')
          ..write('deviceLimit: $deviceLimit, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    userId,
    role,
    customPermissions,
    isActive,
    deviceLimit,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TenantMember &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.customPermissions == this.customPermissions &&
          other.isActive == this.isActive &&
          other.deviceLimit == this.deviceLimit &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TenantMembersCompanion extends UpdateCompanion<TenantMember> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> userId;
  final Value<String> role;
  final Value<String?> customPermissions;
  final Value<bool?> isActive;
  final Value<int?> deviceLimit;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const TenantMembersCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.customPermissions = const Value.absent(),
    this.isActive = const Value.absent(),
    this.deviceLimit = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TenantMembersCompanion.insert({
    required String id,
    required String tenantId,
    required String userId,
    required String role,
    this.customPermissions = const Value.absent(),
    this.isActive = const Value.absent(),
    this.deviceLimit = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       userId = Value(userId),
       role = Value(role);
  static Insertable<TenantMember> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? customPermissions,
    Expression<bool>? isActive,
    Expression<int>? deviceLimit,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (customPermissions != null) 'custom_permissions': customPermissions,
      if (isActive != null) 'is_active': isActive,
      if (deviceLimit != null) 'device_limit': deviceLimit,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TenantMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? userId,
    Value<String>? role,
    Value<String?>? customPermissions,
    Value<bool?>? isActive,
    Value<int?>? deviceLimit,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return TenantMembersCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      customPermissions: customPermissions ?? this.customPermissions,
      isActive: isActive ?? this.isActive,
      deviceLimit: deviceLimit ?? this.deviceLimit,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (customPermissions.present) {
      map['custom_permissions'] = Variable<String>(customPermissions.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (deviceLimit.present) {
      map['device_limit'] = Variable<int>(deviceLimit.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TenantMembersCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('customPermissions: $customPermissions, ')
          ..write('isActive: $isActive, ')
          ..write('deviceLimit: $deviceLimit, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceCodeMeta = const VerificationMeta(
    'deviceCode',
  );
  @override
  late final GeneratedColumn<String> deviceCode = GeneratedColumn<String>(
    'device_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<String> lastSeenAt = GeneratedColumn<String>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<String> revokedAt = GeneratedColumn<String>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revokedByMeta = const VerificationMeta(
    'revokedBy',
  );
  @override
  late final GeneratedColumn<String> revokedBy = GeneratedColumn<String>(
    'revoked_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    userId,
    deviceCode,
    platform,
    name,
    lastSeenAt,
    revokedAt,
    revokedBy,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_code')) {
      context.handle(
        _deviceCodeMeta,
        deviceCode.isAcceptableOrUnknown(data['device_code']!, _deviceCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceCodeMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    if (data.containsKey('revoked_by')) {
      context.handle(
        _revokedByMeta,
        revokedBy.isAcceptableOrUnknown(data['revoked_by']!, _revokedByMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      deviceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_code'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_seen_at'],
      ),
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revoked_at'],
      ),
      revokedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revoked_by'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String tenantId;
  final String userId;
  final String deviceCode;
  final String platform;
  final String? name;
  final String? lastSeenAt;
  final String? revokedAt;
  final String? revokedBy;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const Device({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.deviceCode,
    required this.platform,
    this.name,
    this.lastSeenAt,
    this.revokedAt,
    this.revokedBy,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['user_id'] = Variable<String>(userId);
    map['device_code'] = Variable<String>(deviceCode);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<String>(lastSeenAt);
    }
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<String>(revokedAt);
    }
    if (!nullToAbsent || revokedBy != null) {
      map['revoked_by'] = Variable<String>(revokedBy);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      userId: Value(userId),
      deviceCode: Value(deviceCode),
      platform: Value(platform),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
      revokedBy: revokedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedBy),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      userId: serializer.fromJson<String>(json['userId']),
      deviceCode: serializer.fromJson<String>(json['deviceCode']),
      platform: serializer.fromJson<String>(json['platform']),
      name: serializer.fromJson<String?>(json['name']),
      lastSeenAt: serializer.fromJson<String?>(json['lastSeenAt']),
      revokedAt: serializer.fromJson<String?>(json['revokedAt']),
      revokedBy: serializer.fromJson<String?>(json['revokedBy']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'userId': serializer.toJson<String>(userId),
      'deviceCode': serializer.toJson<String>(deviceCode),
      'platform': serializer.toJson<String>(platform),
      'name': serializer.toJson<String?>(name),
      'lastSeenAt': serializer.toJson<String?>(lastSeenAt),
      'revokedAt': serializer.toJson<String?>(revokedAt),
      'revokedBy': serializer.toJson<String?>(revokedBy),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Device copyWith({
    String? id,
    String? tenantId,
    String? userId,
    String? deviceCode,
    String? platform,
    Value<String?> name = const Value.absent(),
    Value<String?> lastSeenAt = const Value.absent(),
    Value<String?> revokedAt = const Value.absent(),
    Value<String?> revokedBy = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Device(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    userId: userId ?? this.userId,
    deviceCode: deviceCode ?? this.deviceCode,
    platform: platform ?? this.platform,
    name: name.present ? name.value : this.name,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
    revokedBy: revokedBy.present ? revokedBy.value : this.revokedBy,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceCode: data.deviceCode.present
          ? data.deviceCode.value
          : this.deviceCode,
      platform: data.platform.present ? data.platform.value : this.platform,
      name: data.name.present ? data.name.value : this.name,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
      revokedBy: data.revokedBy.present ? data.revokedBy.value : this.revokedBy,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('userId: $userId, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('platform: $platform, ')
          ..write('name: $name, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('revokedBy: $revokedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    userId,
    deviceCode,
    platform,
    name,
    lastSeenAt,
    revokedAt,
    revokedBy,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.userId == this.userId &&
          other.deviceCode == this.deviceCode &&
          other.platform == this.platform &&
          other.name == this.name &&
          other.lastSeenAt == this.lastSeenAt &&
          other.revokedAt == this.revokedAt &&
          other.revokedBy == this.revokedBy &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> userId;
  final Value<String> deviceCode;
  final Value<String> platform;
  final Value<String?> name;
  final Value<String?> lastSeenAt;
  final Value<String?> revokedAt;
  final Value<String?> revokedBy;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceCode = const Value.absent(),
    this.platform = const Value.absent(),
    this.name = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.revokedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String tenantId,
    required String userId,
    required String deviceCode,
    required String platform,
    this.name = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.revokedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       userId = Value(userId),
       deviceCode = Value(deviceCode),
       platform = Value(platform);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? userId,
    Expression<String>? deviceCode,
    Expression<String>? platform,
    Expression<String>? name,
    Expression<String>? lastSeenAt,
    Expression<String>? revokedAt,
    Expression<String>? revokedBy,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (userId != null) 'user_id': userId,
      if (deviceCode != null) 'device_code': deviceCode,
      if (platform != null) 'platform': platform,
      if (name != null) 'name': name,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (revokedBy != null) 'revoked_by': revokedBy,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? userId,
    Value<String>? deviceCode,
    Value<String>? platform,
    Value<String?>? name,
    Value<String?>? lastSeenAt,
    Value<String?>? revokedAt,
    Value<String?>? revokedBy,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      deviceCode: deviceCode ?? this.deviceCode,
      platform: platform ?? this.platform,
      name: name ?? this.name,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedBy: revokedBy ?? this.revokedBy,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceCode.present) {
      map['device_code'] = Variable<String>(deviceCode.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<String>(lastSeenAt.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<String>(revokedAt.value);
    }
    if (revokedBy.present) {
      map['revoked_by'] = Variable<String>(revokedBy.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('userId: $userId, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('platform: $platform, ')
          ..write('name: $name, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('revokedBy: $revokedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemberInvitesTable extends MemberInvites
    with TableInfo<$MemberInvitesTable, MemberInvite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemberInvitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customPermissionsMeta = const VerificationMeta(
    'customPermissions',
  );
  @override
  late final GeneratedColumn<String> customPermissions =
      GeneratedColumn<String>(
        'custom_permissions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<String> expiresAt = GeneratedColumn<String>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acceptedByMeta = const VerificationMeta(
    'acceptedBy',
  );
  @override
  late final GeneratedColumn<String> acceptedBy = GeneratedColumn<String>(
    'accepted_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<String> acceptedAt = GeneratedColumn<String>(
    'accepted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    phone,
    fullName,
    role,
    customPermissions,
    status,
    expiresAt,
    acceptedBy,
    acceptedAt,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member_invites';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberInvite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('custom_permissions')) {
      context.handle(
        _customPermissionsMeta,
        customPermissions.isAcceptableOrUnknown(
          data['custom_permissions']!,
          _customPermissionsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('accepted_by')) {
      context.handle(
        _acceptedByMeta,
        acceptedBy.isAcceptableOrUnknown(data['accepted_by']!, _acceptedByMeta),
      );
    }
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberInvite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberInvite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      customPermissions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_permissions'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expires_at'],
      ),
      acceptedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accepted_by'],
      ),
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accepted_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $MemberInvitesTable createAlias(String alias) {
    return $MemberInvitesTable(attachedDatabase, alias);
  }
}

class MemberInvite extends DataClass implements Insertable<MemberInvite> {
  final String id;
  final String tenantId;
  final String phone;
  final String? fullName;
  final String role;
  final String? customPermissions;
  final String status;
  final String? expiresAt;
  final String? acceptedBy;
  final String? acceptedAt;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const MemberInvite({
    required this.id,
    required this.tenantId,
    required this.phone,
    this.fullName,
    required this.role,
    this.customPermissions,
    required this.status,
    this.expiresAt,
    this.acceptedBy,
    this.acceptedAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || customPermissions != null) {
      map['custom_permissions'] = Variable<String>(customPermissions);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<String>(expiresAt);
    }
    if (!nullToAbsent || acceptedBy != null) {
      map['accepted_by'] = Variable<String>(acceptedBy);
    }
    if (!nullToAbsent || acceptedAt != null) {
      map['accepted_at'] = Variable<String>(acceptedAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  MemberInvitesCompanion toCompanion(bool nullToAbsent) {
    return MemberInvitesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      phone: Value(phone),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      role: Value(role),
      customPermissions: customPermissions == null && nullToAbsent
          ? const Value.absent()
          : Value(customPermissions),
      status: Value(status),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      acceptedBy: acceptedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedBy),
      acceptedAt: acceptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory MemberInvite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberInvite(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      phone: serializer.fromJson<String>(json['phone']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      role: serializer.fromJson<String>(json['role']),
      customPermissions: serializer.fromJson<String?>(
        json['customPermissions'],
      ),
      status: serializer.fromJson<String>(json['status']),
      expiresAt: serializer.fromJson<String?>(json['expiresAt']),
      acceptedBy: serializer.fromJson<String?>(json['acceptedBy']),
      acceptedAt: serializer.fromJson<String?>(json['acceptedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'phone': serializer.toJson<String>(phone),
      'fullName': serializer.toJson<String?>(fullName),
      'role': serializer.toJson<String>(role),
      'customPermissions': serializer.toJson<String?>(customPermissions),
      'status': serializer.toJson<String>(status),
      'expiresAt': serializer.toJson<String?>(expiresAt),
      'acceptedBy': serializer.toJson<String?>(acceptedBy),
      'acceptedAt': serializer.toJson<String?>(acceptedAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  MemberInvite copyWith({
    String? id,
    String? tenantId,
    String? phone,
    Value<String?> fullName = const Value.absent(),
    String? role,
    Value<String?> customPermissions = const Value.absent(),
    String? status,
    Value<String?> expiresAt = const Value.absent(),
    Value<String?> acceptedBy = const Value.absent(),
    Value<String?> acceptedAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => MemberInvite(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    phone: phone ?? this.phone,
    fullName: fullName.present ? fullName.value : this.fullName,
    role: role ?? this.role,
    customPermissions: customPermissions.present
        ? customPermissions.value
        : this.customPermissions,
    status: status ?? this.status,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    acceptedBy: acceptedBy.present ? acceptedBy.value : this.acceptedBy,
    acceptedAt: acceptedAt.present ? acceptedAt.value : this.acceptedAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  MemberInvite copyWithCompanion(MemberInvitesCompanion data) {
    return MemberInvite(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      phone: data.phone.present ? data.phone.value : this.phone,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      role: data.role.present ? data.role.value : this.role,
      customPermissions: data.customPermissions.present
          ? data.customPermissions.value
          : this.customPermissions,
      status: data.status.present ? data.status.value : this.status,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      acceptedBy: data.acceptedBy.present
          ? data.acceptedBy.value
          : this.acceptedBy,
      acceptedAt: data.acceptedAt.present
          ? data.acceptedAt.value
          : this.acceptedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberInvite(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('phone: $phone, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('customPermissions: $customPermissions, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('acceptedBy: $acceptedBy, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    phone,
    fullName,
    role,
    customPermissions,
    status,
    expiresAt,
    acceptedBy,
    acceptedAt,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberInvite &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.phone == this.phone &&
          other.fullName == this.fullName &&
          other.role == this.role &&
          other.customPermissions == this.customPermissions &&
          other.status == this.status &&
          other.expiresAt == this.expiresAt &&
          other.acceptedBy == this.acceptedBy &&
          other.acceptedAt == this.acceptedAt &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MemberInvitesCompanion extends UpdateCompanion<MemberInvite> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> phone;
  final Value<String?> fullName;
  final Value<String> role;
  final Value<String?> customPermissions;
  final Value<String> status;
  final Value<String?> expiresAt;
  final Value<String?> acceptedBy;
  final Value<String?> acceptedAt;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const MemberInvitesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.phone = const Value.absent(),
    this.fullName = const Value.absent(),
    this.role = const Value.absent(),
    this.customPermissions = const Value.absent(),
    this.status = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.acceptedBy = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberInvitesCompanion.insert({
    required String id,
    required String tenantId,
    required String phone,
    this.fullName = const Value.absent(),
    required String role,
    this.customPermissions = const Value.absent(),
    required String status,
    this.expiresAt = const Value.absent(),
    this.acceptedBy = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       phone = Value(phone),
       role = Value(role),
       status = Value(status);
  static Insertable<MemberInvite> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? phone,
    Expression<String>? fullName,
    Expression<String>? role,
    Expression<String>? customPermissions,
    Expression<String>? status,
    Expression<String>? expiresAt,
    Expression<String>? acceptedBy,
    Expression<String>? acceptedAt,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (phone != null) 'phone': phone,
      if (fullName != null) 'full_name': fullName,
      if (role != null) 'role': role,
      if (customPermissions != null) 'custom_permissions': customPermissions,
      if (status != null) 'status': status,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (acceptedBy != null) 'accepted_by': acceptedBy,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberInvitesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? phone,
    Value<String?>? fullName,
    Value<String>? role,
    Value<String?>? customPermissions,
    Value<String>? status,
    Value<String?>? expiresAt,
    Value<String?>? acceptedBy,
    Value<String?>? acceptedAt,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return MemberInvitesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      customPermissions: customPermissions ?? this.customPermissions,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (customPermissions.present) {
      map['custom_permissions'] = Variable<String>(customPermissions.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<String>(expiresAt.value);
    }
    if (acceptedBy.present) {
      map['accepted_by'] = Variable<String>(acceptedBy.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<String>(acceptedAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemberInvitesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('phone: $phone, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('customPermissions: $customPermissions, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('acceptedBy: $acceptedBy, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    scope,
    scopeId,
    key,
    value,
    updatedBy,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String id;
  final String tenantId;
  final String scope;
  final String? scopeId;
  final String key;
  final String? value;
  final String? updatedBy;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const Setting({
    required this.id,
    required this.tenantId,
    required this.scope,
    this.scopeId,
    required this.key,
    this.value,
    this.updatedBy,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || scopeId != null) {
      map['scope_id'] = Variable<String>(scopeId);
    }
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      scope: Value(scope),
      scopeId: scopeId == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeId),
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      scope: serializer.fromJson<String>(json['scope']),
      scopeId: serializer.fromJson<String?>(json['scopeId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'scope': serializer.toJson<String>(scope),
      'scopeId': serializer.toJson<String?>(scopeId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Setting copyWith({
    String? id,
    String? tenantId,
    String? scope,
    Value<String?> scopeId = const Value.absent(),
    String? key,
    Value<String?> value = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Setting(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    scope: scope ?? this.scope,
    scopeId: scopeId.present ? scopeId.value : this.scopeId,
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      scope: data.scope.present ? data.scope.value : this.scope,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    scope,
    scopeId,
    key,
    value,
    updatedBy,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.scope == this.scope &&
          other.scopeId == this.scopeId &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedBy == this.updatedBy &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> scope;
  final Value<String?> scopeId;
  final Value<String> key;
  final Value<String?> value;
  final Value<String?> updatedBy;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.scope = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String id,
    required String tenantId,
    required String scope,
    this.scopeId = const Value.absent(),
    required String key,
    this.value = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       scope = Value(scope),
       key = Value(key);
  static Insertable<Setting> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? scope,
    Expression<String>? scopeId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? updatedBy,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (scope != null) 'scope': scope,
      if (scopeId != null) 'scope_id': scopeId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? scope,
    Value<String?>? scopeId,
    Value<String>? key,
    Value<String?>? value,
    Value<String?>? updatedBy,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      scope: scope ?? this.scope,
      scopeId: scopeId ?? this.scopeId,
      key: key ?? this.key,
      value: value ?? this.value,
      updatedBy: updatedBy ?? this.updatedBy,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableNameValueMeta = const VerificationMeta(
    'tableNameValue',
  );
  @override
  late final GeneratedColumn<String> tableNameValue = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beforeMeta = const VerificationMeta('before');
  @override
  late final GeneratedColumn<String> before = GeneratedColumn<String>(
    'before',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterMeta = const VerificationMeta('after');
  @override
  late final GeneratedColumn<String> after = GeneratedColumn<String>(
    'after',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    tableNameValue,
    rowId,
    action,
    before,
    after,
    userId,
    deviceId,
    role,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _tableNameValueMeta,
        tableNameValue.isAcceptableOrUnknown(
          data['table_name']!,
          _tableNameValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tableNameValueMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('before')) {
      context.handle(
        _beforeMeta,
        before.isAcceptableOrUnknown(data['before']!, _beforeMeta),
      );
    }
    if (data.containsKey('after')) {
      context.handle(
        _afterMeta,
        after.isAcceptableOrUnknown(data['after']!, _afterMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      tableNameValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      before: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before'],
      ),
      after: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditEntry extends DataClass implements Insertable<AuditEntry> {
  final String id;
  final String tenantId;
  final String tableNameValue;
  final String rowId;
  final String action;
  final String? before;
  final String? after;
  final String userId;
  final String? deviceId;
  final String? role;
  final String? createdAt;
  const AuditEntry({
    required this.id,
    required this.tenantId,
    required this.tableNameValue,
    required this.rowId,
    required this.action,
    this.before,
    this.after,
    required this.userId,
    this.deviceId,
    this.role,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['table_name'] = Variable<String>(tableNameValue);
    map['row_id'] = Variable<String>(rowId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || before != null) {
      map['before'] = Variable<String>(before);
    }
    if (!nullToAbsent || after != null) {
      map['after'] = Variable<String>(after);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      tableNameValue: Value(tableNameValue),
      rowId: Value(rowId),
      action: Value(action),
      before: before == null && nullToAbsent
          ? const Value.absent()
          : Value(before),
      after: after == null && nullToAbsent
          ? const Value.absent()
          : Value(after),
      userId: Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory AuditEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditEntry(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      tableNameValue: serializer.fromJson<String>(json['tableNameValue']),
      rowId: serializer.fromJson<String>(json['rowId']),
      action: serializer.fromJson<String>(json['action']),
      before: serializer.fromJson<String?>(json['before']),
      after: serializer.fromJson<String?>(json['after']),
      userId: serializer.fromJson<String>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      role: serializer.fromJson<String?>(json['role']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'tableNameValue': serializer.toJson<String>(tableNameValue),
      'rowId': serializer.toJson<String>(rowId),
      'action': serializer.toJson<String>(action),
      'before': serializer.toJson<String?>(before),
      'after': serializer.toJson<String?>(after),
      'userId': serializer.toJson<String>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'role': serializer.toJson<String?>(role),
      'createdAt': serializer.toJson<String?>(createdAt),
    };
  }

  AuditEntry copyWith({
    String? id,
    String? tenantId,
    String? tableNameValue,
    String? rowId,
    String? action,
    Value<String?> before = const Value.absent(),
    Value<String?> after = const Value.absent(),
    String? userId,
    Value<String?> deviceId = const Value.absent(),
    Value<String?> role = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
  }) => AuditEntry(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    tableNameValue: tableNameValue ?? this.tableNameValue,
    rowId: rowId ?? this.rowId,
    action: action ?? this.action,
    before: before.present ? before.value : this.before,
    after: after.present ? after.value : this.after,
    userId: userId ?? this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    role: role.present ? role.value : this.role,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  AuditEntry copyWithCompanion(AuditLogCompanion data) {
    return AuditEntry(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      tableNameValue: data.tableNameValue.present
          ? data.tableNameValue.value
          : this.tableNameValue,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      action: data.action.present ? data.action.value : this.action,
      before: data.before.present ? data.before.value : this.before,
      after: data.after.present ? data.after.value : this.after,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditEntry(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('tableNameValue: $tableNameValue, ')
          ..write('rowId: $rowId, ')
          ..write('action: $action, ')
          ..write('before: $before, ')
          ..write('after: $after, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    tableNameValue,
    rowId,
    action,
    before,
    after,
    userId,
    deviceId,
    role,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditEntry &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.tableNameValue == this.tableNameValue &&
          other.rowId == this.rowId &&
          other.action == this.action &&
          other.before == this.before &&
          other.after == this.after &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.role == this.role &&
          other.createdAt == this.createdAt);
}

class AuditLogCompanion extends UpdateCompanion<AuditEntry> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> tableNameValue;
  final Value<String> rowId;
  final Value<String> action;
  final Value<String?> before;
  final Value<String?> after;
  final Value<String> userId;
  final Value<String?> deviceId;
  final Value<String?> role;
  final Value<String?> createdAt;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.tableNameValue = const Value.absent(),
    this.rowId = const Value.absent(),
    this.action = const Value.absent(),
    this.before = const Value.absent(),
    this.after = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String tenantId,
    required String tableNameValue,
    required String rowId,
    required String action,
    this.before = const Value.absent(),
    this.after = const Value.absent(),
    required String userId,
    this.deviceId = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       tableNameValue = Value(tableNameValue),
       rowId = Value(rowId),
       action = Value(action),
       userId = Value(userId);
  static Insertable<AuditEntry> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? tableNameValue,
    Expression<String>? rowId,
    Expression<String>? action,
    Expression<String>? before,
    Expression<String>? after,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<String>? role,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (tableNameValue != null) 'table_name': tableNameValue,
      if (rowId != null) 'row_id': rowId,
      if (action != null) 'action': action,
      if (before != null) 'before': before,
      if (after != null) 'after': after,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? tableNameValue,
    Value<String>? rowId,
    Value<String>? action,
    Value<String?>? before,
    Value<String?>? after,
    Value<String>? userId,
    Value<String?>? deviceId,
    Value<String?>? role,
    Value<String?>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      tableNameValue: tableNameValue ?? this.tableNameValue,
      rowId: rowId ?? this.rowId,
      action: action ?? this.action,
      before: before ?? this.before,
      after: after ?? this.after,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (tableNameValue.present) {
      map['table_name'] = Variable<String>(tableNameValue.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (before.present) {
      map['before'] = Variable<String>(before.value);
    }
    if (after.present) {
      map['after'] = Variable<String>(after.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('tableNameValue: $tableNameValue, ')
          ..write('rowId: $rowId, ')
          ..write('action: $action, ')
          ..write('before: $before, ')
          ..write('after: $after, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherOrHusbandNameMeta =
      const VerificationMeta('fatherOrHusbandName');
  @override
  late final GeneratedColumn<String> fatherOrHusbandName =
      GeneratedColumn<String>(
        'father_or_husband_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageMeta = const VerificationMeta(
    'village',
  );
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
    'mobile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altMobileMeta = const VerificationMeta(
    'altMobile',
  );
  @override
  late final GeneratedColumn<String> altMobile = GeneratedColumn<String>(
    'alt_mobile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aadhaarLast4Meta = const VerificationMeta(
    'aadhaarLast4',
  );
  @override
  late final GeneratedColumn<String> aadhaarLast4 = GeneratedColumn<String>(
    'aadhaar_last4',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankAccountMaskedMeta = const VerificationMeta(
    'bankAccountMasked',
  );
  @override
  late final GeneratedColumn<String> bankAccountMasked =
      GeneratedColumn<String>(
        'bank_account_masked',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ifscMeta = const VerificationMeta('ifsc');
  @override
  late final GeneratedColumn<String> ifsc = GeneratedColumn<String>(
    'ifsc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partyGroupIdMeta = const VerificationMeta(
    'partyGroupId',
  );
  @override
  late final GeneratedColumn<String> partyGroupId = GeneratedColumn<String>(
    'party_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    code,
    name,
    fatherOrHusbandName,
    relation,
    village,
    district,
    state,
    mobile,
    altMobile,
    aadhaarLast4,
    bankName,
    bankAccountMasked,
    ifsc,
    gstin,
    notes,
    partyGroupId,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Party> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('father_or_husband_name')) {
      context.handle(
        _fatherOrHusbandNameMeta,
        fatherOrHusbandName.isAcceptableOrUnknown(
          data['father_or_husband_name']!,
          _fatherOrHusbandNameMeta,
        ),
      );
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    }
    if (data.containsKey('village')) {
      context.handle(
        _villageMeta,
        village.isAcceptableOrUnknown(data['village']!, _villageMeta),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('mobile')) {
      context.handle(
        _mobileMeta,
        mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta),
      );
    }
    if (data.containsKey('alt_mobile')) {
      context.handle(
        _altMobileMeta,
        altMobile.isAcceptableOrUnknown(data['alt_mobile']!, _altMobileMeta),
      );
    }
    if (data.containsKey('aadhaar_last4')) {
      context.handle(
        _aadhaarLast4Meta,
        aadhaarLast4.isAcceptableOrUnknown(
          data['aadhaar_last4']!,
          _aadhaarLast4Meta,
        ),
      );
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    }
    if (data.containsKey('bank_account_masked')) {
      context.handle(
        _bankAccountMaskedMeta,
        bankAccountMasked.isAcceptableOrUnknown(
          data['bank_account_masked']!,
          _bankAccountMaskedMeta,
        ),
      );
    }
    if (data.containsKey('ifsc')) {
      context.handle(
        _ifscMeta,
        ifsc.isAcceptableOrUnknown(data['ifsc']!, _ifscMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('party_group_id')) {
      context.handle(
        _partyGroupIdMeta,
        partyGroupId.isAcceptableOrUnknown(
          data['party_group_id']!,
          _partyGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fatherOrHusbandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_or_husband_name'],
      ),
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      ),
      village: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village'],
      ),
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      mobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile'],
      ),
      altMobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_mobile'],
      ),
      aadhaarLast4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aadhaar_last4'],
      ),
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      ),
      bankAccountMasked: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_account_masked'],
      ),
      ifsc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ifsc'],
      ),
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      partyGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_group_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String tenantId;
  final String code;
  final String name;
  final String? fatherOrHusbandName;
  final String? relation;
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
  final String? partyGroupId;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  const Party({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    this.fatherOrHusbandName,
    this.relation,
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
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || fatherOrHusbandName != null) {
      map['father_or_husband_name'] = Variable<String>(fatherOrHusbandName);
    }
    if (!nullToAbsent || relation != null) {
      map['relation'] = Variable<String>(relation);
    }
    if (!nullToAbsent || village != null) {
      map['village'] = Variable<String>(village);
    }
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || mobile != null) {
      map['mobile'] = Variable<String>(mobile);
    }
    if (!nullToAbsent || altMobile != null) {
      map['alt_mobile'] = Variable<String>(altMobile);
    }
    if (!nullToAbsent || aadhaarLast4 != null) {
      map['aadhaar_last4'] = Variable<String>(aadhaarLast4);
    }
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || bankAccountMasked != null) {
      map['bank_account_masked'] = Variable<String>(bankAccountMasked);
    }
    if (!nullToAbsent || ifsc != null) {
      map['ifsc'] = Variable<String>(ifsc);
    }
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || partyGroupId != null) {
      map['party_group_id'] = Variable<String>(partyGroupId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      code: Value(code),
      name: Value(name),
      fatherOrHusbandName: fatherOrHusbandName == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherOrHusbandName),
      relation: relation == null && nullToAbsent
          ? const Value.absent()
          : Value(relation),
      village: village == null && nullToAbsent
          ? const Value.absent()
          : Value(village),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      mobile: mobile == null && nullToAbsent
          ? const Value.absent()
          : Value(mobile),
      altMobile: altMobile == null && nullToAbsent
          ? const Value.absent()
          : Value(altMobile),
      aadhaarLast4: aadhaarLast4 == null && nullToAbsent
          ? const Value.absent()
          : Value(aadhaarLast4),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      bankAccountMasked: bankAccountMasked == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountMasked),
      ifsc: ifsc == null && nullToAbsent ? const Value.absent() : Value(ifsc),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      partyGroupId: partyGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyGroupId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      fatherOrHusbandName: serializer.fromJson<String?>(
        json['fatherOrHusbandName'],
      ),
      relation: serializer.fromJson<String?>(json['relation']),
      village: serializer.fromJson<String?>(json['village']),
      district: serializer.fromJson<String?>(json['district']),
      state: serializer.fromJson<String?>(json['state']),
      mobile: serializer.fromJson<String?>(json['mobile']),
      altMobile: serializer.fromJson<String?>(json['altMobile']),
      aadhaarLast4: serializer.fromJson<String?>(json['aadhaarLast4']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      bankAccountMasked: serializer.fromJson<String?>(
        json['bankAccountMasked'],
      ),
      ifsc: serializer.fromJson<String?>(json['ifsc']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      notes: serializer.fromJson<String?>(json['notes']),
      partyGroupId: serializer.fromJson<String?>(json['partyGroupId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'fatherOrHusbandName': serializer.toJson<String?>(fatherOrHusbandName),
      'relation': serializer.toJson<String?>(relation),
      'village': serializer.toJson<String?>(village),
      'district': serializer.toJson<String?>(district),
      'state': serializer.toJson<String?>(state),
      'mobile': serializer.toJson<String?>(mobile),
      'altMobile': serializer.toJson<String?>(altMobile),
      'aadhaarLast4': serializer.toJson<String?>(aadhaarLast4),
      'bankName': serializer.toJson<String?>(bankName),
      'bankAccountMasked': serializer.toJson<String?>(bankAccountMasked),
      'ifsc': serializer.toJson<String?>(ifsc),
      'gstin': serializer.toJson<String?>(gstin),
      'notes': serializer.toJson<String?>(notes),
      'partyGroupId': serializer.toJson<String?>(partyGroupId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Party copyWith({
    String? id,
    String? tenantId,
    String? code,
    String? name,
    Value<String?> fatherOrHusbandName = const Value.absent(),
    Value<String?> relation = const Value.absent(),
    Value<String?> village = const Value.absent(),
    Value<String?> district = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> mobile = const Value.absent(),
    Value<String?> altMobile = const Value.absent(),
    Value<String?> aadhaarLast4 = const Value.absent(),
    Value<String?> bankName = const Value.absent(),
    Value<String?> bankAccountMasked = const Value.absent(),
    Value<String?> ifsc = const Value.absent(),
    Value<String?> gstin = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> partyGroupId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
  }) => Party(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    code: code ?? this.code,
    name: name ?? this.name,
    fatherOrHusbandName: fatherOrHusbandName.present
        ? fatherOrHusbandName.value
        : this.fatherOrHusbandName,
    relation: relation.present ? relation.value : this.relation,
    village: village.present ? village.value : this.village,
    district: district.present ? district.value : this.district,
    state: state.present ? state.value : this.state,
    mobile: mobile.present ? mobile.value : this.mobile,
    altMobile: altMobile.present ? altMobile.value : this.altMobile,
    aadhaarLast4: aadhaarLast4.present ? aadhaarLast4.value : this.aadhaarLast4,
    bankName: bankName.present ? bankName.value : this.bankName,
    bankAccountMasked: bankAccountMasked.present
        ? bankAccountMasked.value
        : this.bankAccountMasked,
    ifsc: ifsc.present ? ifsc.value : this.ifsc,
    gstin: gstin.present ? gstin.value : this.gstin,
    notes: notes.present ? notes.value : this.notes,
    partyGroupId: partyGroupId.present ? partyGroupId.value : this.partyGroupId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      fatherOrHusbandName: data.fatherOrHusbandName.present
          ? data.fatherOrHusbandName.value
          : this.fatherOrHusbandName,
      relation: data.relation.present ? data.relation.value : this.relation,
      village: data.village.present ? data.village.value : this.village,
      district: data.district.present ? data.district.value : this.district,
      state: data.state.present ? data.state.value : this.state,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      altMobile: data.altMobile.present ? data.altMobile.value : this.altMobile,
      aadhaarLast4: data.aadhaarLast4.present
          ? data.aadhaarLast4.value
          : this.aadhaarLast4,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      bankAccountMasked: data.bankAccountMasked.present
          ? data.bankAccountMasked.value
          : this.bankAccountMasked,
      ifsc: data.ifsc.present ? data.ifsc.value : this.ifsc,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      notes: data.notes.present ? data.notes.value : this.notes,
      partyGroupId: data.partyGroupId.present
          ? data.partyGroupId.value
          : this.partyGroupId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('fatherOrHusbandName: $fatherOrHusbandName, ')
          ..write('relation: $relation, ')
          ..write('village: $village, ')
          ..write('district: $district, ')
          ..write('state: $state, ')
          ..write('mobile: $mobile, ')
          ..write('altMobile: $altMobile, ')
          ..write('aadhaarLast4: $aadhaarLast4, ')
          ..write('bankName: $bankName, ')
          ..write('bankAccountMasked: $bankAccountMasked, ')
          ..write('ifsc: $ifsc, ')
          ..write('gstin: $gstin, ')
          ..write('notes: $notes, ')
          ..write('partyGroupId: $partyGroupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    tenantId,
    code,
    name,
    fatherOrHusbandName,
    relation,
    village,
    district,
    state,
    mobile,
    altMobile,
    aadhaarLast4,
    bankName,
    bankAccountMasked,
    ifsc,
    gstin,
    notes,
    partyGroupId,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.code == this.code &&
          other.name == this.name &&
          other.fatherOrHusbandName == this.fatherOrHusbandName &&
          other.relation == this.relation &&
          other.village == this.village &&
          other.district == this.district &&
          other.state == this.state &&
          other.mobile == this.mobile &&
          other.altMobile == this.altMobile &&
          other.aadhaarLast4 == this.aadhaarLast4 &&
          other.bankName == this.bankName &&
          other.bankAccountMasked == this.bankAccountMasked &&
          other.ifsc == this.ifsc &&
          other.gstin == this.gstin &&
          other.notes == this.notes &&
          other.partyGroupId == this.partyGroupId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> fatherOrHusbandName;
  final Value<String?> relation;
  final Value<String?> village;
  final Value<String?> district;
  final Value<String?> state;
  final Value<String?> mobile;
  final Value<String?> altMobile;
  final Value<String?> aadhaarLast4;
  final Value<String?> bankName;
  final Value<String?> bankAccountMasked;
  final Value<String?> ifsc;
  final Value<String?> gstin;
  final Value<String?> notes;
  final Value<String?> partyGroupId;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.fatherOrHusbandName = const Value.absent(),
    this.relation = const Value.absent(),
    this.village = const Value.absent(),
    this.district = const Value.absent(),
    this.state = const Value.absent(),
    this.mobile = const Value.absent(),
    this.altMobile = const Value.absent(),
    this.aadhaarLast4 = const Value.absent(),
    this.bankName = const Value.absent(),
    this.bankAccountMasked = const Value.absent(),
    this.ifsc = const Value.absent(),
    this.gstin = const Value.absent(),
    this.notes = const Value.absent(),
    this.partyGroupId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String id,
    required String tenantId,
    required String code,
    required String name,
    this.fatherOrHusbandName = const Value.absent(),
    this.relation = const Value.absent(),
    this.village = const Value.absent(),
    this.district = const Value.absent(),
    this.state = const Value.absent(),
    this.mobile = const Value.absent(),
    this.altMobile = const Value.absent(),
    this.aadhaarLast4 = const Value.absent(),
    this.bankName = const Value.absent(),
    this.bankAccountMasked = const Value.absent(),
    this.ifsc = const Value.absent(),
    this.gstin = const Value.absent(),
    this.notes = const Value.absent(),
    this.partyGroupId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       code = Value(code),
       name = Value(name);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? fatherOrHusbandName,
    Expression<String>? relation,
    Expression<String>? village,
    Expression<String>? district,
    Expression<String>? state,
    Expression<String>? mobile,
    Expression<String>? altMobile,
    Expression<String>? aadhaarLast4,
    Expression<String>? bankName,
    Expression<String>? bankAccountMasked,
    Expression<String>? ifsc,
    Expression<String>? gstin,
    Expression<String>? notes,
    Expression<String>? partyGroupId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (fatherOrHusbandName != null)
        'father_or_husband_name': fatherOrHusbandName,
      if (relation != null) 'relation': relation,
      if (village != null) 'village': village,
      if (district != null) 'district': district,
      if (state != null) 'state': state,
      if (mobile != null) 'mobile': mobile,
      if (altMobile != null) 'alt_mobile': altMobile,
      if (aadhaarLast4 != null) 'aadhaar_last4': aadhaarLast4,
      if (bankName != null) 'bank_name': bankName,
      if (bankAccountMasked != null) 'bank_account_masked': bankAccountMasked,
      if (ifsc != null) 'ifsc': ifsc,
      if (gstin != null) 'gstin': gstin,
      if (notes != null) 'notes': notes,
      if (partyGroupId != null) 'party_group_id': partyGroupId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? fatherOrHusbandName,
    Value<String?>? relation,
    Value<String?>? village,
    Value<String?>? district,
    Value<String?>? state,
    Value<String?>? mobile,
    Value<String?>? altMobile,
    Value<String?>? aadhaarLast4,
    Value<String?>? bankName,
    Value<String?>? bankAccountMasked,
    Value<String?>? ifsc,
    Value<String?>? gstin,
    Value<String?>? notes,
    Value<String?>? partyGroupId,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      code: code ?? this.code,
      name: name ?? this.name,
      fatherOrHusbandName: fatherOrHusbandName ?? this.fatherOrHusbandName,
      relation: relation ?? this.relation,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      mobile: mobile ?? this.mobile,
      altMobile: altMobile ?? this.altMobile,
      aadhaarLast4: aadhaarLast4 ?? this.aadhaarLast4,
      bankName: bankName ?? this.bankName,
      bankAccountMasked: bankAccountMasked ?? this.bankAccountMasked,
      ifsc: ifsc ?? this.ifsc,
      gstin: gstin ?? this.gstin,
      notes: notes ?? this.notes,
      partyGroupId: partyGroupId ?? this.partyGroupId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fatherOrHusbandName.present) {
      map['father_or_husband_name'] = Variable<String>(
        fatherOrHusbandName.value,
      );
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (altMobile.present) {
      map['alt_mobile'] = Variable<String>(altMobile.value);
    }
    if (aadhaarLast4.present) {
      map['aadhaar_last4'] = Variable<String>(aadhaarLast4.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (bankAccountMasked.present) {
      map['bank_account_masked'] = Variable<String>(bankAccountMasked.value);
    }
    if (ifsc.present) {
      map['ifsc'] = Variable<String>(ifsc.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (partyGroupId.present) {
      map['party_group_id'] = Variable<String>(partyGroupId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('fatherOrHusbandName: $fatherOrHusbandName, ')
          ..write('relation: $relation, ')
          ..write('village: $village, ')
          ..write('district: $district, ')
          ..write('state: $state, ')
          ..write('mobile: $mobile, ')
          ..write('altMobile: $altMobile, ')
          ..write('aadhaarLast4: $aadhaarLast4, ')
          ..write('bankName: $bankName, ')
          ..write('bankAccountMasked: $bankAccountMasked, ')
          ..write('ifsc: $ifsc, ')
          ..write('gstin: $gstin, ')
          ..write('notes: $notes, ')
          ..write('partyGroupId: $partyGroupId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartyRolesTable extends PartyRoles
    with TableInfo<$PartyRolesTable, PartyRole> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartyRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    partyId,
    role,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'party_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartyRole> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartyRole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyRole(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PartyRolesTable createAlias(String alias) {
    return $PartyRolesTable(attachedDatabase, alias);
  }
}

class PartyRole extends DataClass implements Insertable<PartyRole> {
  final String id;
  final String tenantId;
  final String partyId;
  final String role;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  const PartyRole({
    required this.id,
    required this.tenantId,
    required this.partyId,
    required this.role,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['party_id'] = Variable<String>(partyId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  PartyRolesCompanion toCompanion(bool nullToAbsent) {
    return PartyRolesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      partyId: Value(partyId),
      role: Value(role),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PartyRole.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyRole(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      partyId: serializer.fromJson<String>(json['partyId']),
      role: serializer.fromJson<String>(json['role']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'partyId': serializer.toJson<String>(partyId),
      'role': serializer.toJson<String>(role),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  PartyRole copyWith({
    String? id,
    String? tenantId,
    String? partyId,
    String? role,
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
  }) => PartyRole(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    partyId: partyId ?? this.partyId,
    role: role ?? this.role,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PartyRole copyWithCompanion(PartyRolesCompanion data) {
    return PartyRole(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      role: data.role.present ? data.role.value : this.role,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyRole(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('partyId: $partyId, ')
          ..write('role: $role, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    partyId,
    role,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyRole &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.partyId == this.partyId &&
          other.role == this.role &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PartyRolesCompanion extends UpdateCompanion<PartyRole> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> partyId;
  final Value<String> role;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const PartyRolesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.role = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartyRolesCompanion.insert({
    required String id,
    required String tenantId,
    required String partyId,
    required String role,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       partyId = Value(partyId),
       role = Value(role);
  static Insertable<PartyRole> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? partyId,
    Expression<String>? role,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (partyId != null) 'party_id': partyId,
      if (role != null) 'role': role,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartyRolesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? partyId,
    Value<String>? role,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PartyRolesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      partyId: partyId ?? this.partyId,
      role: role ?? this.role,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartyRolesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('partyId: $partyId, ')
          ..write('role: $role, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NumberSeriesTable extends NumberSeries
    with TableInfo<$NumberSeriesTable, NumberSeriesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NumberSeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesMeta = const VerificationMeta('series');
  @override
  late final GeneratedColumn<String> series = GeneratedColumn<String>(
    'series',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceCodeMeta = const VerificationMeta(
    'deviceCode',
  );
  @override
  late final GeneratedColumn<String> deviceCode = GeneratedColumn<String>(
    'device_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextValueMeta = const VerificationMeta(
    'nextValue',
  );
  @override
  late final GeneratedColumn<int> nextValue = GeneratedColumn<int>(
    'next_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    series,
    deviceCode,
    nextValue,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'number_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<NumberSeriesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('series')) {
      context.handle(
        _seriesMeta,
        series.isAcceptableOrUnknown(data['series']!, _seriesMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesMeta);
    }
    if (data.containsKey('device_code')) {
      context.handle(
        _deviceCodeMeta,
        deviceCode.isAcceptableOrUnknown(data['device_code']!, _deviceCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceCodeMeta);
    }
    if (data.containsKey('next_value')) {
      context.handle(
        _nextValueMeta,
        nextValue.isAcceptableOrUnknown(data['next_value']!, _nextValueMeta),
      );
    } else if (isInserting) {
      context.missing(_nextValueMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NumberSeriesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NumberSeriesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      series: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series'],
      )!,
      deviceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_code'],
      )!,
      nextValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_value'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $NumberSeriesTable createAlias(String alias) {
    return $NumberSeriesTable(attachedDatabase, alias);
  }
}

class NumberSeriesRow extends DataClass implements Insertable<NumberSeriesRow> {
  final String id;
  final String tenantId;
  final String series;
  final String deviceCode;
  final int nextValue;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const NumberSeriesRow({
    required this.id,
    required this.tenantId,
    required this.series,
    required this.deviceCode,
    required this.nextValue,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['series'] = Variable<String>(series);
    map['device_code'] = Variable<String>(deviceCode);
    map['next_value'] = Variable<int>(nextValue);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  NumberSeriesCompanion toCompanion(bool nullToAbsent) {
    return NumberSeriesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      series: Value(series),
      deviceCode: Value(deviceCode),
      nextValue: Value(nextValue),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory NumberSeriesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NumberSeriesRow(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      series: serializer.fromJson<String>(json['series']),
      deviceCode: serializer.fromJson<String>(json['deviceCode']),
      nextValue: serializer.fromJson<int>(json['nextValue']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'series': serializer.toJson<String>(series),
      'deviceCode': serializer.toJson<String>(deviceCode),
      'nextValue': serializer.toJson<int>(nextValue),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  NumberSeriesRow copyWith({
    String? id,
    String? tenantId,
    String? series,
    String? deviceCode,
    int? nextValue,
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => NumberSeriesRow(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    series: series ?? this.series,
    deviceCode: deviceCode ?? this.deviceCode,
    nextValue: nextValue ?? this.nextValue,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  NumberSeriesRow copyWithCompanion(NumberSeriesCompanion data) {
    return NumberSeriesRow(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      series: data.series.present ? data.series.value : this.series,
      deviceCode: data.deviceCode.present
          ? data.deviceCode.value
          : this.deviceCode,
      nextValue: data.nextValue.present ? data.nextValue.value : this.nextValue,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NumberSeriesRow(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('series: $series, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('nextValue: $nextValue, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    series,
    deviceCode,
    nextValue,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NumberSeriesRow &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.series == this.series &&
          other.deviceCode == this.deviceCode &&
          other.nextValue == this.nextValue &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NumberSeriesCompanion extends UpdateCompanion<NumberSeriesRow> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> series;
  final Value<String> deviceCode;
  final Value<int> nextValue;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const NumberSeriesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.series = const Value.absent(),
    this.deviceCode = const Value.absent(),
    this.nextValue = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NumberSeriesCompanion.insert({
    required String id,
    required String tenantId,
    required String series,
    required String deviceCode,
    required int nextValue,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       series = Value(series),
       deviceCode = Value(deviceCode),
       nextValue = Value(nextValue);
  static Insertable<NumberSeriesRow> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? series,
    Expression<String>? deviceCode,
    Expression<int>? nextValue,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (series != null) 'series': series,
      if (deviceCode != null) 'device_code': deviceCode,
      if (nextValue != null) 'next_value': nextValue,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NumberSeriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? series,
    Value<String>? deviceCode,
    Value<int>? nextValue,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return NumberSeriesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      series: series ?? this.series,
      deviceCode: deviceCode ?? this.deviceCode,
      nextValue: nextValue ?? this.nextValue,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (series.present) {
      map['series'] = Variable<String>(series.value);
    }
    if (deviceCode.present) {
      map['device_code'] = Variable<String>(deviceCode.value);
    }
    if (nextValue.present) {
      map['next_value'] = Variable<int>(nextValue.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NumberSeriesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('series: $series, ')
          ..write('deviceCode: $deviceCode, ')
          ..write('nextValue: $nextValue, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refTypeMeta = const VerificationMeta(
    'refType',
  );
  @override
  late final GeneratedColumn<String> refType = GeneratedColumn<String>(
    'ref_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _narrationMeta = const VerificationMeta(
    'narration',
  );
  @override
  late final GeneratedColumn<String> narration = GeneratedColumn<String>(
    'narration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversesIdMeta = const VerificationMeta(
    'reversesId',
  );
  @override
  late final GeneratedColumn<String> reversesId = GeneratedColumn<String>(
    'reverses_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replacesIdMeta = const VerificationMeta(
    'replacesId',
  );
  @override
  late final GeneratedColumn<String> replacesId = GeneratedColumn<String>(
    'replaces_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<String> receivedAt = GeneratedColumn<String>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    partyId,
    entryDate,
    side,
    amountPaise,
    refType,
    refId,
    narration,
    reversesId,
    replacesId,
    deviceId,
    createdBy,
    createdAt,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('ref_type')) {
      context.handle(
        _refTypeMeta,
        refType.isAcceptableOrUnknown(data['ref_type']!, _refTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_refTypeMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    if (data.containsKey('narration')) {
      context.handle(
        _narrationMeta,
        narration.isAcceptableOrUnknown(data['narration']!, _narrationMeta),
      );
    }
    if (data.containsKey('reverses_id')) {
      context.handle(
        _reversesIdMeta,
        reversesId.isAcceptableOrUnknown(data['reverses_id']!, _reversesIdMeta),
      );
    }
    if (data.containsKey('replaces_id')) {
      context.handle(
        _replacesIdMeta,
        replacesId.isAcceptableOrUnknown(data['replaces_id']!, _replacesIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      refType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_type'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
      narration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narration'],
      ),
      reversesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_id'],
      ),
      replacesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replaces_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_at'],
      ),
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntryRow extends DataClass implements Insertable<LedgerEntryRow> {
  final String id;
  final String tenantId;
  final String partyId;
  final String entryDate;
  final String side;
  final int amountPaise;
  final String refType;
  final String? refId;
  final String? narration;
  final String? reversesId;
  final String? replacesId;
  final String? deviceId;
  final String? createdBy;
  final String createdAt;
  final String? receivedAt;
  const LedgerEntryRow({
    required this.id,
    required this.tenantId,
    required this.partyId,
    required this.entryDate,
    required this.side,
    required this.amountPaise,
    required this.refType,
    this.refId,
    this.narration,
    this.reversesId,
    this.replacesId,
    this.deviceId,
    this.createdBy,
    required this.createdAt,
    this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['party_id'] = Variable<String>(partyId);
    map['entry_date'] = Variable<String>(entryDate);
    map['side'] = Variable<String>(side);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['ref_type'] = Variable<String>(refType);
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    if (!nullToAbsent || narration != null) {
      map['narration'] = Variable<String>(narration);
    }
    if (!nullToAbsent || reversesId != null) {
      map['reverses_id'] = Variable<String>(reversesId);
    }
    if (!nullToAbsent || replacesId != null) {
      map['replaces_id'] = Variable<String>(replacesId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<String>(receivedAt);
    }
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      partyId: Value(partyId),
      entryDate: Value(entryDate),
      side: Value(side),
      amountPaise: Value(amountPaise),
      refType: Value(refType),
      refId: refId == null && nullToAbsent
          ? const Value.absent()
          : Value(refId),
      narration: narration == null && nullToAbsent
          ? const Value.absent()
          : Value(narration),
      reversesId: reversesId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesId),
      replacesId: replacesId == null && nullToAbsent
          ? const Value.absent()
          : Value(replacesId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
    );
  }

  factory LedgerEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntryRow(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      partyId: serializer.fromJson<String>(json['partyId']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      side: serializer.fromJson<String>(json['side']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      refType: serializer.fromJson<String>(json['refType']),
      refId: serializer.fromJson<String?>(json['refId']),
      narration: serializer.fromJson<String?>(json['narration']),
      reversesId: serializer.fromJson<String?>(json['reversesId']),
      replacesId: serializer.fromJson<String?>(json['replacesId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      receivedAt: serializer.fromJson<String?>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'partyId': serializer.toJson<String>(partyId),
      'entryDate': serializer.toJson<String>(entryDate),
      'side': serializer.toJson<String>(side),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'refType': serializer.toJson<String>(refType),
      'refId': serializer.toJson<String?>(refId),
      'narration': serializer.toJson<String?>(narration),
      'reversesId': serializer.toJson<String?>(reversesId),
      'replacesId': serializer.toJson<String?>(replacesId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String>(createdAt),
      'receivedAt': serializer.toJson<String?>(receivedAt),
    };
  }

  LedgerEntryRow copyWith({
    String? id,
    String? tenantId,
    String? partyId,
    String? entryDate,
    String? side,
    int? amountPaise,
    String? refType,
    Value<String?> refId = const Value.absent(),
    Value<String?> narration = const Value.absent(),
    Value<String?> reversesId = const Value.absent(),
    Value<String?> replacesId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    String? createdAt,
    Value<String?> receivedAt = const Value.absent(),
  }) => LedgerEntryRow(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    partyId: partyId ?? this.partyId,
    entryDate: entryDate ?? this.entryDate,
    side: side ?? this.side,
    amountPaise: amountPaise ?? this.amountPaise,
    refType: refType ?? this.refType,
    refId: refId.present ? refId.value : this.refId,
    narration: narration.present ? narration.value : this.narration,
    reversesId: reversesId.present ? reversesId.value : this.reversesId,
    replacesId: replacesId.present ? replacesId.value : this.replacesId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
  );
  LedgerEntryRow copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntryRow(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      side: data.side.present ? data.side.value : this.side,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      refType: data.refType.present ? data.refType.value : this.refType,
      refId: data.refId.present ? data.refId.value : this.refId,
      narration: data.narration.present ? data.narration.value : this.narration,
      reversesId: data.reversesId.present
          ? data.reversesId.value
          : this.reversesId,
      replacesId: data.replacesId.present
          ? data.replacesId.value
          : this.replacesId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntryRow(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('partyId: $partyId, ')
          ..write('entryDate: $entryDate, ')
          ..write('side: $side, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('narration: $narration, ')
          ..write('reversesId: $reversesId, ')
          ..write('replacesId: $replacesId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    partyId,
    entryDate,
    side,
    amountPaise,
    refType,
    refId,
    narration,
    reversesId,
    replacesId,
    deviceId,
    createdBy,
    createdAt,
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntryRow &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.partyId == this.partyId &&
          other.entryDate == this.entryDate &&
          other.side == this.side &&
          other.amountPaise == this.amountPaise &&
          other.refType == this.refType &&
          other.refId == this.refId &&
          other.narration == this.narration &&
          other.reversesId == this.reversesId &&
          other.replacesId == this.replacesId &&
          other.deviceId == this.deviceId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.receivedAt == this.receivedAt);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntryRow> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> partyId;
  final Value<String> entryDate;
  final Value<String> side;
  final Value<int> amountPaise;
  final Value<String> refType;
  final Value<String?> refId;
  final Value<String?> narration;
  final Value<String?> reversesId;
  final Value<String?> replacesId;
  final Value<String?> deviceId;
  final Value<String?> createdBy;
  final Value<String> createdAt;
  final Value<String?> receivedAt;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.side = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.narration = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.replacesId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String tenantId,
    required String partyId,
    required String entryDate,
    required String side,
    required int amountPaise,
    required String refType,
    this.refId = const Value.absent(),
    this.narration = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.replacesId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String createdAt,
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       partyId = Value(partyId),
       entryDate = Value(entryDate),
       side = Value(side),
       amountPaise = Value(amountPaise),
       refType = Value(refType),
       createdAt = Value(createdAt);
  static Insertable<LedgerEntryRow> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? partyId,
    Expression<String>? entryDate,
    Expression<String>? side,
    Expression<int>? amountPaise,
    Expression<String>? refType,
    Expression<String>? refId,
    Expression<String>? narration,
    Expression<String>? reversesId,
    Expression<String>? replacesId,
    Expression<String>? deviceId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (partyId != null) 'party_id': partyId,
      if (entryDate != null) 'entry_date': entryDate,
      if (side != null) 'side': side,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (refType != null) 'ref_type': refType,
      if (refId != null) 'ref_id': refId,
      if (narration != null) 'narration': narration,
      if (reversesId != null) 'reverses_id': reversesId,
      if (replacesId != null) 'replaces_id': replacesId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? partyId,
    Value<String>? entryDate,
    Value<String>? side,
    Value<int>? amountPaise,
    Value<String>? refType,
    Value<String?>? refId,
    Value<String?>? narration,
    Value<String?>? reversesId,
    Value<String?>? replacesId,
    Value<String?>? deviceId,
    Value<String?>? createdBy,
    Value<String>? createdAt,
    Value<String?>? receivedAt,
    Value<int>? rowid,
  }) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      partyId: partyId ?? this.partyId,
      entryDate: entryDate ?? this.entryDate,
      side: side ?? this.side,
      amountPaise: amountPaise ?? this.amountPaise,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      narration: narration ?? this.narration,
      reversesId: reversesId ?? this.reversesId,
      replacesId: replacesId ?? this.replacesId,
      deviceId: deviceId ?? this.deviceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      receivedAt: receivedAt ?? this.receivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (refType.present) {
      map['ref_type'] = Variable<String>(refType.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (narration.present) {
      map['narration'] = Variable<String>(narration.value);
    }
    if (reversesId.present) {
      map['reverses_id'] = Variable<String>(reversesId.value);
    }
    if (replacesId.present) {
      map['replaces_id'] = Variable<String>(replacesId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<String>(receivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('partyId: $partyId, ')
          ..write('entryDate: $entryDate, ')
          ..write('side: $side, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('narration: $narration, ')
          ..write('reversesId: $reversesId, ')
          ..write('replacesId: $replacesId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CropsTable extends Crops with TableInfo<$CropsTable, Crop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameHiMeta = const VerificationMeta('nameHi');
  @override
  late final GeneratedColumn<String> nameHi = GeneratedColumn<String>(
    'name_hi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _namePaMeta = const VerificationMeta('namePa');
  @override
  late final GeneratedColumn<String> namePa = GeneratedColumn<String>(
    'name_pa',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mspOrStdRateMeta = const VerificationMeta(
    'mspOrStdRate',
  );
  @override
  late final GeneratedColumn<int> mspOrStdRate = GeneratedColumn<int>(
    'msp_or_std_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    code,
    nameEn,
    nameHi,
    namePa,
    unit,
    mspOrStdRate,
    sortOrder,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crops';
  @override
  VerificationContext validateIntegrity(
    Insertable<Crop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_hi')) {
      context.handle(
        _nameHiMeta,
        nameHi.isAcceptableOrUnknown(data['name_hi']!, _nameHiMeta),
      );
    }
    if (data.containsKey('name_pa')) {
      context.handle(
        _namePaMeta,
        namePa.isAcceptableOrUnknown(data['name_pa']!, _namePaMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('msp_or_std_rate')) {
      context.handle(
        _mspOrStdRateMeta,
        mspOrStdRate.isAcceptableOrUnknown(
          data['msp_or_std_rate']!,
          _mspOrStdRateMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Crop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Crop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameHi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_hi'],
      ),
      namePa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_pa'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      mspOrStdRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}msp_or_std_rate'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CropsTable createAlias(String alias) {
    return $CropsTable(attachedDatabase, alias);
  }
}

class Crop extends DataClass implements Insertable<Crop> {
  final String id;
  final String tenantId;
  final String code;
  final String nameEn;
  final String? nameHi;
  final String? namePa;
  final String unit;
  final int? mspOrStdRate;
  final int sortOrder;
  final bool isActive;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const Crop({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.nameEn,
    this.nameHi,
    this.namePa,
    required this.unit,
    this.mspOrStdRate,
    required this.sortOrder,
    required this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['code'] = Variable<String>(code);
    map['name_en'] = Variable<String>(nameEn);
    if (!nullToAbsent || nameHi != null) {
      map['name_hi'] = Variable<String>(nameHi);
    }
    if (!nullToAbsent || namePa != null) {
      map['name_pa'] = Variable<String>(namePa);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || mspOrStdRate != null) {
      map['msp_or_std_rate'] = Variable<int>(mspOrStdRate);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CropsCompanion toCompanion(bool nullToAbsent) {
    return CropsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      code: Value(code),
      nameEn: Value(nameEn),
      nameHi: nameHi == null && nullToAbsent
          ? const Value.absent()
          : Value(nameHi),
      namePa: namePa == null && nullToAbsent
          ? const Value.absent()
          : Value(namePa),
      unit: Value(unit),
      mspOrStdRate: mspOrStdRate == null && nullToAbsent
          ? const Value.absent()
          : Value(mspOrStdRate),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Crop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Crop(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      code: serializer.fromJson<String>(json['code']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameHi: serializer.fromJson<String?>(json['nameHi']),
      namePa: serializer.fromJson<String?>(json['namePa']),
      unit: serializer.fromJson<String>(json['unit']),
      mspOrStdRate: serializer.fromJson<int?>(json['mspOrStdRate']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'code': serializer.toJson<String>(code),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameHi': serializer.toJson<String?>(nameHi),
      'namePa': serializer.toJson<String?>(namePa),
      'unit': serializer.toJson<String>(unit),
      'mspOrStdRate': serializer.toJson<int?>(mspOrStdRate),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Crop copyWith({
    String? id,
    String? tenantId,
    String? code,
    String? nameEn,
    Value<String?> nameHi = const Value.absent(),
    Value<String?> namePa = const Value.absent(),
    String? unit,
    Value<int?> mspOrStdRate = const Value.absent(),
    int? sortOrder,
    bool? isActive,
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Crop(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    code: code ?? this.code,
    nameEn: nameEn ?? this.nameEn,
    nameHi: nameHi.present ? nameHi.value : this.nameHi,
    namePa: namePa.present ? namePa.value : this.namePa,
    unit: unit ?? this.unit,
    mspOrStdRate: mspOrStdRate.present ? mspOrStdRate.value : this.mspOrStdRate,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Crop copyWithCompanion(CropsCompanion data) {
    return Crop(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      code: data.code.present ? data.code.value : this.code,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameHi: data.nameHi.present ? data.nameHi.value : this.nameHi,
      namePa: data.namePa.present ? data.namePa.value : this.namePa,
      unit: data.unit.present ? data.unit.value : this.unit,
      mspOrStdRate: data.mspOrStdRate.present
          ? data.mspOrStdRate.value
          : this.mspOrStdRate,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Crop(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('code: $code, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameHi: $nameHi, ')
          ..write('namePa: $namePa, ')
          ..write('unit: $unit, ')
          ..write('mspOrStdRate: $mspOrStdRate, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    code,
    nameEn,
    nameHi,
    namePa,
    unit,
    mspOrStdRate,
    sortOrder,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Crop &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.code == this.code &&
          other.nameEn == this.nameEn &&
          other.nameHi == this.nameHi &&
          other.namePa == this.namePa &&
          other.unit == this.unit &&
          other.mspOrStdRate == this.mspOrStdRate &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CropsCompanion extends UpdateCompanion<Crop> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> code;
  final Value<String> nameEn;
  final Value<String?> nameHi;
  final Value<String?> namePa;
  final Value<String> unit;
  final Value<int?> mspOrStdRate;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CropsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.code = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameHi = const Value.absent(),
    this.namePa = const Value.absent(),
    this.unit = const Value.absent(),
    this.mspOrStdRate = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropsCompanion.insert({
    required String id,
    required String tenantId,
    required String code,
    required String nameEn,
    this.nameHi = const Value.absent(),
    this.namePa = const Value.absent(),
    required String unit,
    this.mspOrStdRate = const Value.absent(),
    required int sortOrder,
    required bool isActive,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       code = Value(code),
       nameEn = Value(nameEn),
       unit = Value(unit),
       sortOrder = Value(sortOrder),
       isActive = Value(isActive);
  static Insertable<Crop> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? code,
    Expression<String>? nameEn,
    Expression<String>? nameHi,
    Expression<String>? namePa,
    Expression<String>? unit,
    Expression<int>? mspOrStdRate,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (code != null) 'code': code,
      if (nameEn != null) 'name_en': nameEn,
      if (nameHi != null) 'name_hi': nameHi,
      if (namePa != null) 'name_pa': namePa,
      if (unit != null) 'unit': unit,
      if (mspOrStdRate != null) 'msp_or_std_rate': mspOrStdRate,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? code,
    Value<String>? nameEn,
    Value<String?>? nameHi,
    Value<String?>? namePa,
    Value<String>? unit,
    Value<int?>? mspOrStdRate,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CropsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      code: code ?? this.code,
      nameEn: nameEn ?? this.nameEn,
      nameHi: nameHi ?? this.nameHi,
      namePa: namePa ?? this.namePa,
      unit: unit ?? this.unit,
      mspOrStdRate: mspOrStdRate ?? this.mspOrStdRate,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameHi.present) {
      map['name_hi'] = Variable<String>(nameHi.value);
    }
    if (namePa.present) {
      map['name_pa'] = Variable<String>(namePa.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (mspOrStdRate.present) {
      map['msp_or_std_rate'] = Variable<int>(mspOrStdRate.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('code: $code, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameHi: $nameHi, ')
          ..write('namePa: $namePa, ')
          ..write('unit: $unit, ')
          ..write('mspOrStdRate: $mspOrStdRate, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotsTable extends Lots with TableInfo<$LotsTable, Lot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotNoMeta = const VerificationMeta('lotNo');
  @override
  late final GeneratedColumn<String> lotNo = GeneratedColumn<String>(
    'lot_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta(
    'farmerId',
  );
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
    'crop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bagsMeta = const VerificationMeta('bags');
  @override
  late final GeneratedColumn<int> bags = GeneratedColumn<int>(
    'bags',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtlMilliMeta = const VerificationMeta(
    'qtlMilli',
  );
  @override
  late final GeneratedColumn<int> qtlMilli = GeneratedColumn<int>(
    'qtl_milli',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qtlFromBagsMeta = const VerificationMeta(
    'qtlFromBags',
  );
  @override
  late final GeneratedColumn<bool> qtlFromBags = GeneratedColumn<bool>(
    'qtl_from_bags',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("qtl_from_bags" IN (0, 1))',
    ),
  );
  static const VerificationMeta _ratePaisePerQtlMeta = const VerificationMeta(
    'ratePaisePerQtl',
  );
  @override
  late final GeneratedColumn<int> ratePaisePerQtl = GeneratedColumn<int>(
    'rate_paise_per_qtl',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buyerPartyIdMeta = const VerificationMeta(
    'buyerPartyId',
  );
  @override
  late final GeneratedColumn<String> buyerPartyId = GeneratedColumn<String>(
    'buyer_party_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jFormNoMeta = const VerificationMeta(
    'jFormNo',
  );
  @override
  late final GeneratedColumn<String> jFormNo = GeneratedColumn<String>(
    'j_form_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleNoMeta = const VerificationMeta(
    'vehicleNo',
  );
  @override
  late final GeneratedColumn<String> vehicleNo = GeneratedColumn<String>(
    'vehicle_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargesSnapshotMeta = const VerificationMeta(
    'chargesSnapshot',
  );
  @override
  late final GeneratedColumn<String> chargesSnapshot = GeneratedColumn<String>(
    'charges_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grossMeta = const VerificationMeta('gross');
  @override
  late final GeneratedColumn<int> gross = GeneratedColumn<int>(
    'gross',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commissionMeta = const VerificationMeta(
    'commission',
  );
  @override
  late final GeneratedColumn<int> commission = GeneratedColumn<int>(
    'commission',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _netToFarmerMeta = const VerificationMeta(
    'netToFarmer',
  );
  @override
  late final GeneratedColumn<int> netToFarmer = GeneratedColumn<int>(
    'net_to_farmer',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buyerTotalMeta = const VerificationMeta(
    'buyerTotal',
  );
  @override
  late final GeneratedColumn<int> buyerTotal = GeneratedColumn<int>(
    'buyer_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postedAtMeta = const VerificationMeta(
    'postedAt',
  );
  @override
  late final GeneratedColumn<String> postedAt = GeneratedColumn<String>(
    'posted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    lotNo,
    entryDate,
    farmerId,
    cropId,
    bags,
    qtlMilli,
    qtlFromBags,
    ratePaisePerQtl,
    buyerPartyId,
    jFormNo,
    vehicleNo,
    notes,
    status,
    chargesSnapshot,
    gross,
    commission,
    netToFarmer,
    buyerTotal,
    postedAt,
    deviceId,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('lot_no')) {
      context.handle(
        _lotNoMeta,
        lotNo.isAcceptableOrUnknown(data['lot_no']!, _lotNoMeta),
      );
    } else if (isInserting) {
      context.missing(_lotNoMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('farmer_id')) {
      context.handle(
        _farmerIdMeta,
        farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('crop_id')) {
      context.handle(
        _cropIdMeta,
        cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('bags')) {
      context.handle(
        _bagsMeta,
        bags.isAcceptableOrUnknown(data['bags']!, _bagsMeta),
      );
    } else if (isInserting) {
      context.missing(_bagsMeta);
    }
    if (data.containsKey('qtl_milli')) {
      context.handle(
        _qtlMilliMeta,
        qtlMilli.isAcceptableOrUnknown(data['qtl_milli']!, _qtlMilliMeta),
      );
    }
    if (data.containsKey('qtl_from_bags')) {
      context.handle(
        _qtlFromBagsMeta,
        qtlFromBags.isAcceptableOrUnknown(
          data['qtl_from_bags']!,
          _qtlFromBagsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qtlFromBagsMeta);
    }
    if (data.containsKey('rate_paise_per_qtl')) {
      context.handle(
        _ratePaisePerQtlMeta,
        ratePaisePerQtl.isAcceptableOrUnknown(
          data['rate_paise_per_qtl']!,
          _ratePaisePerQtlMeta,
        ),
      );
    }
    if (data.containsKey('buyer_party_id')) {
      context.handle(
        _buyerPartyIdMeta,
        buyerPartyId.isAcceptableOrUnknown(
          data['buyer_party_id']!,
          _buyerPartyIdMeta,
        ),
      );
    }
    if (data.containsKey('j_form_no')) {
      context.handle(
        _jFormNoMeta,
        jFormNo.isAcceptableOrUnknown(data['j_form_no']!, _jFormNoMeta),
      );
    }
    if (data.containsKey('vehicle_no')) {
      context.handle(
        _vehicleNoMeta,
        vehicleNo.isAcceptableOrUnknown(data['vehicle_no']!, _vehicleNoMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('charges_snapshot')) {
      context.handle(
        _chargesSnapshotMeta,
        chargesSnapshot.isAcceptableOrUnknown(
          data['charges_snapshot']!,
          _chargesSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('gross')) {
      context.handle(
        _grossMeta,
        gross.isAcceptableOrUnknown(data['gross']!, _grossMeta),
      );
    }
    if (data.containsKey('commission')) {
      context.handle(
        _commissionMeta,
        commission.isAcceptableOrUnknown(data['commission']!, _commissionMeta),
      );
    }
    if (data.containsKey('net_to_farmer')) {
      context.handle(
        _netToFarmerMeta,
        netToFarmer.isAcceptableOrUnknown(
          data['net_to_farmer']!,
          _netToFarmerMeta,
        ),
      );
    }
    if (data.containsKey('buyer_total')) {
      context.handle(
        _buyerTotalMeta,
        buyerTotal.isAcceptableOrUnknown(data['buyer_total']!, _buyerTotalMeta),
      );
    }
    if (data.containsKey('posted_at')) {
      context.handle(
        _postedAtMeta,
        postedAt.isAcceptableOrUnknown(data['posted_at']!, _postedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      lotNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_no'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      farmerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_id'],
      )!,
      cropId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_id'],
      )!,
      bags: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bags'],
      )!,
      qtlMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qtl_milli'],
      ),
      qtlFromBags: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}qtl_from_bags'],
      )!,
      ratePaisePerQtl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_paise_per_qtl'],
      ),
      buyerPartyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buyer_party_id'],
      ),
      jFormNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}j_form_no'],
      ),
      vehicleNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_no'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      chargesSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}charges_snapshot'],
      ),
      gross: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross'],
      ),
      commission: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commission'],
      ),
      netToFarmer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_to_farmer'],
      ),
      buyerTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buyer_total'],
      ),
      postedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LotsTable createAlias(String alias) {
    return $LotsTable(attachedDatabase, alias);
  }
}

class Lot extends DataClass implements Insertable<Lot> {
  final String id;
  final String tenantId;
  final String lotNo;
  final String entryDate;
  final String farmerId;
  final String cropId;
  final int bags;
  final int? qtlMilli;
  final bool qtlFromBags;
  final int? ratePaisePerQtl;
  final String? buyerPartyId;
  final String? jFormNo;
  final String? vehicleNo;
  final String? notes;
  final String status;
  final String? chargesSnapshot;
  final int? gross;
  final int? commission;
  final int? netToFarmer;
  final int? buyerTotal;
  final String? postedAt;
  final String? deviceId;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const Lot({
    required this.id,
    required this.tenantId,
    required this.lotNo,
    required this.entryDate,
    required this.farmerId,
    required this.cropId,
    required this.bags,
    this.qtlMilli,
    required this.qtlFromBags,
    this.ratePaisePerQtl,
    this.buyerPartyId,
    this.jFormNo,
    this.vehicleNo,
    this.notes,
    required this.status,
    this.chargesSnapshot,
    this.gross,
    this.commission,
    this.netToFarmer,
    this.buyerTotal,
    this.postedAt,
    this.deviceId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['lot_no'] = Variable<String>(lotNo);
    map['entry_date'] = Variable<String>(entryDate);
    map['farmer_id'] = Variable<String>(farmerId);
    map['crop_id'] = Variable<String>(cropId);
    map['bags'] = Variable<int>(bags);
    if (!nullToAbsent || qtlMilli != null) {
      map['qtl_milli'] = Variable<int>(qtlMilli);
    }
    map['qtl_from_bags'] = Variable<bool>(qtlFromBags);
    if (!nullToAbsent || ratePaisePerQtl != null) {
      map['rate_paise_per_qtl'] = Variable<int>(ratePaisePerQtl);
    }
    if (!nullToAbsent || buyerPartyId != null) {
      map['buyer_party_id'] = Variable<String>(buyerPartyId);
    }
    if (!nullToAbsent || jFormNo != null) {
      map['j_form_no'] = Variable<String>(jFormNo);
    }
    if (!nullToAbsent || vehicleNo != null) {
      map['vehicle_no'] = Variable<String>(vehicleNo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || chargesSnapshot != null) {
      map['charges_snapshot'] = Variable<String>(chargesSnapshot);
    }
    if (!nullToAbsent || gross != null) {
      map['gross'] = Variable<int>(gross);
    }
    if (!nullToAbsent || commission != null) {
      map['commission'] = Variable<int>(commission);
    }
    if (!nullToAbsent || netToFarmer != null) {
      map['net_to_farmer'] = Variable<int>(netToFarmer);
    }
    if (!nullToAbsent || buyerTotal != null) {
      map['buyer_total'] = Variable<int>(buyerTotal);
    }
    if (!nullToAbsent || postedAt != null) {
      map['posted_at'] = Variable<String>(postedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LotsCompanion toCompanion(bool nullToAbsent) {
    return LotsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      lotNo: Value(lotNo),
      entryDate: Value(entryDate),
      farmerId: Value(farmerId),
      cropId: Value(cropId),
      bags: Value(bags),
      qtlMilli: qtlMilli == null && nullToAbsent
          ? const Value.absent()
          : Value(qtlMilli),
      qtlFromBags: Value(qtlFromBags),
      ratePaisePerQtl: ratePaisePerQtl == null && nullToAbsent
          ? const Value.absent()
          : Value(ratePaisePerQtl),
      buyerPartyId: buyerPartyId == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerPartyId),
      jFormNo: jFormNo == null && nullToAbsent
          ? const Value.absent()
          : Value(jFormNo),
      vehicleNo: vehicleNo == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleNo),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      chargesSnapshot: chargesSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(chargesSnapshot),
      gross: gross == null && nullToAbsent
          ? const Value.absent()
          : Value(gross),
      commission: commission == null && nullToAbsent
          ? const Value.absent()
          : Value(commission),
      netToFarmer: netToFarmer == null && nullToAbsent
          ? const Value.absent()
          : Value(netToFarmer),
      buyerTotal: buyerTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerTotal),
      postedAt: postedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(postedAt),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Lot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lot(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      lotNo: serializer.fromJson<String>(json['lotNo']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      cropId: serializer.fromJson<String>(json['cropId']),
      bags: serializer.fromJson<int>(json['bags']),
      qtlMilli: serializer.fromJson<int?>(json['qtlMilli']),
      qtlFromBags: serializer.fromJson<bool>(json['qtlFromBags']),
      ratePaisePerQtl: serializer.fromJson<int?>(json['ratePaisePerQtl']),
      buyerPartyId: serializer.fromJson<String?>(json['buyerPartyId']),
      jFormNo: serializer.fromJson<String?>(json['jFormNo']),
      vehicleNo: serializer.fromJson<String?>(json['vehicleNo']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      chargesSnapshot: serializer.fromJson<String?>(json['chargesSnapshot']),
      gross: serializer.fromJson<int?>(json['gross']),
      commission: serializer.fromJson<int?>(json['commission']),
      netToFarmer: serializer.fromJson<int?>(json['netToFarmer']),
      buyerTotal: serializer.fromJson<int?>(json['buyerTotal']),
      postedAt: serializer.fromJson<String?>(json['postedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'lotNo': serializer.toJson<String>(lotNo),
      'entryDate': serializer.toJson<String>(entryDate),
      'farmerId': serializer.toJson<String>(farmerId),
      'cropId': serializer.toJson<String>(cropId),
      'bags': serializer.toJson<int>(bags),
      'qtlMilli': serializer.toJson<int?>(qtlMilli),
      'qtlFromBags': serializer.toJson<bool>(qtlFromBags),
      'ratePaisePerQtl': serializer.toJson<int?>(ratePaisePerQtl),
      'buyerPartyId': serializer.toJson<String?>(buyerPartyId),
      'jFormNo': serializer.toJson<String?>(jFormNo),
      'vehicleNo': serializer.toJson<String?>(vehicleNo),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'chargesSnapshot': serializer.toJson<String?>(chargesSnapshot),
      'gross': serializer.toJson<int?>(gross),
      'commission': serializer.toJson<int?>(commission),
      'netToFarmer': serializer.toJson<int?>(netToFarmer),
      'buyerTotal': serializer.toJson<int?>(buyerTotal),
      'postedAt': serializer.toJson<String?>(postedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Lot copyWith({
    String? id,
    String? tenantId,
    String? lotNo,
    String? entryDate,
    String? farmerId,
    String? cropId,
    int? bags,
    Value<int?> qtlMilli = const Value.absent(),
    bool? qtlFromBags,
    Value<int?> ratePaisePerQtl = const Value.absent(),
    Value<String?> buyerPartyId = const Value.absent(),
    Value<String?> jFormNo = const Value.absent(),
    Value<String?> vehicleNo = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? status,
    Value<String?> chargesSnapshot = const Value.absent(),
    Value<int?> gross = const Value.absent(),
    Value<int?> commission = const Value.absent(),
    Value<int?> netToFarmer = const Value.absent(),
    Value<int?> buyerTotal = const Value.absent(),
    Value<String?> postedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Lot(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    lotNo: lotNo ?? this.lotNo,
    entryDate: entryDate ?? this.entryDate,
    farmerId: farmerId ?? this.farmerId,
    cropId: cropId ?? this.cropId,
    bags: bags ?? this.bags,
    qtlMilli: qtlMilli.present ? qtlMilli.value : this.qtlMilli,
    qtlFromBags: qtlFromBags ?? this.qtlFromBags,
    ratePaisePerQtl: ratePaisePerQtl.present
        ? ratePaisePerQtl.value
        : this.ratePaisePerQtl,
    buyerPartyId: buyerPartyId.present ? buyerPartyId.value : this.buyerPartyId,
    jFormNo: jFormNo.present ? jFormNo.value : this.jFormNo,
    vehicleNo: vehicleNo.present ? vehicleNo.value : this.vehicleNo,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    chargesSnapshot: chargesSnapshot.present
        ? chargesSnapshot.value
        : this.chargesSnapshot,
    gross: gross.present ? gross.value : this.gross,
    commission: commission.present ? commission.value : this.commission,
    netToFarmer: netToFarmer.present ? netToFarmer.value : this.netToFarmer,
    buyerTotal: buyerTotal.present ? buyerTotal.value : this.buyerTotal,
    postedAt: postedAt.present ? postedAt.value : this.postedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Lot copyWithCompanion(LotsCompanion data) {
    return Lot(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      lotNo: data.lotNo.present ? data.lotNo.value : this.lotNo,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      bags: data.bags.present ? data.bags.value : this.bags,
      qtlMilli: data.qtlMilli.present ? data.qtlMilli.value : this.qtlMilli,
      qtlFromBags: data.qtlFromBags.present
          ? data.qtlFromBags.value
          : this.qtlFromBags,
      ratePaisePerQtl: data.ratePaisePerQtl.present
          ? data.ratePaisePerQtl.value
          : this.ratePaisePerQtl,
      buyerPartyId: data.buyerPartyId.present
          ? data.buyerPartyId.value
          : this.buyerPartyId,
      jFormNo: data.jFormNo.present ? data.jFormNo.value : this.jFormNo,
      vehicleNo: data.vehicleNo.present ? data.vehicleNo.value : this.vehicleNo,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      chargesSnapshot: data.chargesSnapshot.present
          ? data.chargesSnapshot.value
          : this.chargesSnapshot,
      gross: data.gross.present ? data.gross.value : this.gross,
      commission: data.commission.present
          ? data.commission.value
          : this.commission,
      netToFarmer: data.netToFarmer.present
          ? data.netToFarmer.value
          : this.netToFarmer,
      buyerTotal: data.buyerTotal.present
          ? data.buyerTotal.value
          : this.buyerTotal,
      postedAt: data.postedAt.present ? data.postedAt.value : this.postedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lot(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('lotNo: $lotNo, ')
          ..write('entryDate: $entryDate, ')
          ..write('farmerId: $farmerId, ')
          ..write('cropId: $cropId, ')
          ..write('bags: $bags, ')
          ..write('qtlMilli: $qtlMilli, ')
          ..write('qtlFromBags: $qtlFromBags, ')
          ..write('ratePaisePerQtl: $ratePaisePerQtl, ')
          ..write('buyerPartyId: $buyerPartyId, ')
          ..write('jFormNo: $jFormNo, ')
          ..write('vehicleNo: $vehicleNo, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('chargesSnapshot: $chargesSnapshot, ')
          ..write('gross: $gross, ')
          ..write('commission: $commission, ')
          ..write('netToFarmer: $netToFarmer, ')
          ..write('buyerTotal: $buyerTotal, ')
          ..write('postedAt: $postedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    tenantId,
    lotNo,
    entryDate,
    farmerId,
    cropId,
    bags,
    qtlMilli,
    qtlFromBags,
    ratePaisePerQtl,
    buyerPartyId,
    jFormNo,
    vehicleNo,
    notes,
    status,
    chargesSnapshot,
    gross,
    commission,
    netToFarmer,
    buyerTotal,
    postedAt,
    deviceId,
    createdBy,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lot &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.lotNo == this.lotNo &&
          other.entryDate == this.entryDate &&
          other.farmerId == this.farmerId &&
          other.cropId == this.cropId &&
          other.bags == this.bags &&
          other.qtlMilli == this.qtlMilli &&
          other.qtlFromBags == this.qtlFromBags &&
          other.ratePaisePerQtl == this.ratePaisePerQtl &&
          other.buyerPartyId == this.buyerPartyId &&
          other.jFormNo == this.jFormNo &&
          other.vehicleNo == this.vehicleNo &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.chargesSnapshot == this.chargesSnapshot &&
          other.gross == this.gross &&
          other.commission == this.commission &&
          other.netToFarmer == this.netToFarmer &&
          other.buyerTotal == this.buyerTotal &&
          other.postedAt == this.postedAt &&
          other.deviceId == this.deviceId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LotsCompanion extends UpdateCompanion<Lot> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> lotNo;
  final Value<String> entryDate;
  final Value<String> farmerId;
  final Value<String> cropId;
  final Value<int> bags;
  final Value<int?> qtlMilli;
  final Value<bool> qtlFromBags;
  final Value<int?> ratePaisePerQtl;
  final Value<String?> buyerPartyId;
  final Value<String?> jFormNo;
  final Value<String?> vehicleNo;
  final Value<String?> notes;
  final Value<String> status;
  final Value<String?> chargesSnapshot;
  final Value<int?> gross;
  final Value<int?> commission;
  final Value<int?> netToFarmer;
  final Value<int?> buyerTotal;
  final Value<String?> postedAt;
  final Value<String?> deviceId;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const LotsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.lotNo = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.cropId = const Value.absent(),
    this.bags = const Value.absent(),
    this.qtlMilli = const Value.absent(),
    this.qtlFromBags = const Value.absent(),
    this.ratePaisePerQtl = const Value.absent(),
    this.buyerPartyId = const Value.absent(),
    this.jFormNo = const Value.absent(),
    this.vehicleNo = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.chargesSnapshot = const Value.absent(),
    this.gross = const Value.absent(),
    this.commission = const Value.absent(),
    this.netToFarmer = const Value.absent(),
    this.buyerTotal = const Value.absent(),
    this.postedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotsCompanion.insert({
    required String id,
    required String tenantId,
    required String lotNo,
    required String entryDate,
    required String farmerId,
    required String cropId,
    required int bags,
    this.qtlMilli = const Value.absent(),
    required bool qtlFromBags,
    this.ratePaisePerQtl = const Value.absent(),
    this.buyerPartyId = const Value.absent(),
    this.jFormNo = const Value.absent(),
    this.vehicleNo = const Value.absent(),
    this.notes = const Value.absent(),
    required String status,
    this.chargesSnapshot = const Value.absent(),
    this.gross = const Value.absent(),
    this.commission = const Value.absent(),
    this.netToFarmer = const Value.absent(),
    this.buyerTotal = const Value.absent(),
    this.postedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       lotNo = Value(lotNo),
       entryDate = Value(entryDate),
       farmerId = Value(farmerId),
       cropId = Value(cropId),
       bags = Value(bags),
       qtlFromBags = Value(qtlFromBags),
       status = Value(status);
  static Insertable<Lot> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? lotNo,
    Expression<String>? entryDate,
    Expression<String>? farmerId,
    Expression<String>? cropId,
    Expression<int>? bags,
    Expression<int>? qtlMilli,
    Expression<bool>? qtlFromBags,
    Expression<int>? ratePaisePerQtl,
    Expression<String>? buyerPartyId,
    Expression<String>? jFormNo,
    Expression<String>? vehicleNo,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<String>? chargesSnapshot,
    Expression<int>? gross,
    Expression<int>? commission,
    Expression<int>? netToFarmer,
    Expression<int>? buyerTotal,
    Expression<String>? postedAt,
    Expression<String>? deviceId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (lotNo != null) 'lot_no': lotNo,
      if (entryDate != null) 'entry_date': entryDate,
      if (farmerId != null) 'farmer_id': farmerId,
      if (cropId != null) 'crop_id': cropId,
      if (bags != null) 'bags': bags,
      if (qtlMilli != null) 'qtl_milli': qtlMilli,
      if (qtlFromBags != null) 'qtl_from_bags': qtlFromBags,
      if (ratePaisePerQtl != null) 'rate_paise_per_qtl': ratePaisePerQtl,
      if (buyerPartyId != null) 'buyer_party_id': buyerPartyId,
      if (jFormNo != null) 'j_form_no': jFormNo,
      if (vehicleNo != null) 'vehicle_no': vehicleNo,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (chargesSnapshot != null) 'charges_snapshot': chargesSnapshot,
      if (gross != null) 'gross': gross,
      if (commission != null) 'commission': commission,
      if (netToFarmer != null) 'net_to_farmer': netToFarmer,
      if (buyerTotal != null) 'buyer_total': buyerTotal,
      if (postedAt != null) 'posted_at': postedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? lotNo,
    Value<String>? entryDate,
    Value<String>? farmerId,
    Value<String>? cropId,
    Value<int>? bags,
    Value<int?>? qtlMilli,
    Value<bool>? qtlFromBags,
    Value<int?>? ratePaisePerQtl,
    Value<String?>? buyerPartyId,
    Value<String?>? jFormNo,
    Value<String?>? vehicleNo,
    Value<String?>? notes,
    Value<String>? status,
    Value<String?>? chargesSnapshot,
    Value<int?>? gross,
    Value<int?>? commission,
    Value<int?>? netToFarmer,
    Value<int?>? buyerTotal,
    Value<String?>? postedAt,
    Value<String?>? deviceId,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LotsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      lotNo: lotNo ?? this.lotNo,
      entryDate: entryDate ?? this.entryDate,
      farmerId: farmerId ?? this.farmerId,
      cropId: cropId ?? this.cropId,
      bags: bags ?? this.bags,
      qtlMilli: qtlMilli ?? this.qtlMilli,
      qtlFromBags: qtlFromBags ?? this.qtlFromBags,
      ratePaisePerQtl: ratePaisePerQtl ?? this.ratePaisePerQtl,
      buyerPartyId: buyerPartyId ?? this.buyerPartyId,
      jFormNo: jFormNo ?? this.jFormNo,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      chargesSnapshot: chargesSnapshot ?? this.chargesSnapshot,
      gross: gross ?? this.gross,
      commission: commission ?? this.commission,
      netToFarmer: netToFarmer ?? this.netToFarmer,
      buyerTotal: buyerTotal ?? this.buyerTotal,
      postedAt: postedAt ?? this.postedAt,
      deviceId: deviceId ?? this.deviceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (lotNo.present) {
      map['lot_no'] = Variable<String>(lotNo.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (bags.present) {
      map['bags'] = Variable<int>(bags.value);
    }
    if (qtlMilli.present) {
      map['qtl_milli'] = Variable<int>(qtlMilli.value);
    }
    if (qtlFromBags.present) {
      map['qtl_from_bags'] = Variable<bool>(qtlFromBags.value);
    }
    if (ratePaisePerQtl.present) {
      map['rate_paise_per_qtl'] = Variable<int>(ratePaisePerQtl.value);
    }
    if (buyerPartyId.present) {
      map['buyer_party_id'] = Variable<String>(buyerPartyId.value);
    }
    if (jFormNo.present) {
      map['j_form_no'] = Variable<String>(jFormNo.value);
    }
    if (vehicleNo.present) {
      map['vehicle_no'] = Variable<String>(vehicleNo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (chargesSnapshot.present) {
      map['charges_snapshot'] = Variable<String>(chargesSnapshot.value);
    }
    if (gross.present) {
      map['gross'] = Variable<int>(gross.value);
    }
    if (commission.present) {
      map['commission'] = Variable<int>(commission.value);
    }
    if (netToFarmer.present) {
      map['net_to_farmer'] = Variable<int>(netToFarmer.value);
    }
    if (buyerTotal.present) {
      map['buyer_total'] = Variable<int>(buyerTotal.value);
    }
    if (postedAt.present) {
      map['posted_at'] = Variable<String>(postedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('lotNo: $lotNo, ')
          ..write('entryDate: $entryDate, ')
          ..write('farmerId: $farmerId, ')
          ..write('cropId: $cropId, ')
          ..write('bags: $bags, ')
          ..write('qtlMilli: $qtlMilli, ')
          ..write('qtlFromBags: $qtlFromBags, ')
          ..write('ratePaisePerQtl: $ratePaisePerQtl, ')
          ..write('buyerPartyId: $buyerPartyId, ')
          ..write('jFormNo: $jFormNo, ')
          ..write('vehicleNo: $vehicleNo, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('chargesSnapshot: $chargesSnapshot, ')
          ..write('gross: $gross, ')
          ..write('commission: $commission, ')
          ..write('netToFarmer: $netToFarmer, ')
          ..write('buyerTotal: $buyerTotal, ')
          ..write('postedAt: $postedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BankAccountsTable extends BankAccounts
    with TableInfo<$BankAccountsTable, BankAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountLast4Meta = const VerificationMeta(
    'accountLast4',
  );
  @override
  late final GeneratedColumn<String> accountLast4 = GeneratedColumn<String>(
    'account_last4',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ifscMeta = const VerificationMeta('ifsc');
  @override
  late final GeneratedColumn<String> ifsc = GeneratedColumn<String>(
    'ifsc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    kind,
    name,
    bankName,
    accountLast4,
    ifsc,
    sortOrder,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    }
    if (data.containsKey('account_last4')) {
      context.handle(
        _accountLast4Meta,
        accountLast4.isAcceptableOrUnknown(
          data['account_last4']!,
          _accountLast4Meta,
        ),
      );
    }
    if (data.containsKey('ifsc')) {
      context.handle(
        _ifscMeta,
        ifsc.isAcceptableOrUnknown(data['ifsc']!, _ifscMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      ),
      accountLast4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_last4'],
      ),
      ifsc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ifsc'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $BankAccountsTable createAlias(String alias) {
    return $BankAccountsTable(attachedDatabase, alias);
  }
}

class BankAccount extends DataClass implements Insertable<BankAccount> {
  final String id;
  final String tenantId;
  final String kind;
  final String name;
  final String? bankName;
  final String? accountLast4;
  final String? ifsc;
  final int sortOrder;
  final bool isActive;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const BankAccount({
    required this.id,
    required this.tenantId,
    required this.kind,
    required this.name,
    this.bankName,
    this.accountLast4,
    this.ifsc,
    required this.sortOrder,
    required this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || accountLast4 != null) {
      map['account_last4'] = Variable<String>(accountLast4);
    }
    if (!nullToAbsent || ifsc != null) {
      map['ifsc'] = Variable<String>(ifsc);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  BankAccountsCompanion toCompanion(bool nullToAbsent) {
    return BankAccountsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      kind: Value(kind),
      name: Value(name),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      accountLast4: accountLast4 == null && nullToAbsent
          ? const Value.absent()
          : Value(accountLast4),
      ifsc: ifsc == null && nullToAbsent ? const Value.absent() : Value(ifsc),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory BankAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankAccount(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      accountLast4: serializer.fromJson<String?>(json['accountLast4']),
      ifsc: serializer.fromJson<String?>(json['ifsc']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'bankName': serializer.toJson<String?>(bankName),
      'accountLast4': serializer.toJson<String?>(accountLast4),
      'ifsc': serializer.toJson<String?>(ifsc),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  BankAccount copyWith({
    String? id,
    String? tenantId,
    String? kind,
    String? name,
    Value<String?> bankName = const Value.absent(),
    Value<String?> accountLast4 = const Value.absent(),
    Value<String?> ifsc = const Value.absent(),
    int? sortOrder,
    bool? isActive,
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => BankAccount(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    bankName: bankName.present ? bankName.value : this.bankName,
    accountLast4: accountLast4.present ? accountLast4.value : this.accountLast4,
    ifsc: ifsc.present ? ifsc.value : this.ifsc,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  BankAccount copyWithCompanion(BankAccountsCompanion data) {
    return BankAccount(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountLast4: data.accountLast4.present
          ? data.accountLast4.value
          : this.accountLast4,
      ifsc: data.ifsc.present ? data.ifsc.value : this.ifsc,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankAccount(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('bankName: $bankName, ')
          ..write('accountLast4: $accountLast4, ')
          ..write('ifsc: $ifsc, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    kind,
    name,
    bankName,
    accountLast4,
    ifsc,
    sortOrder,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankAccount &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.bankName == this.bankName &&
          other.accountLast4 == this.accountLast4 &&
          other.ifsc == this.ifsc &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BankAccountsCompanion extends UpdateCompanion<BankAccount> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> kind;
  final Value<String> name;
  final Value<String?> bankName;
  final Value<String?> accountLast4;
  final Value<String?> ifsc;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const BankAccountsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountLast4 = const Value.absent(),
    this.ifsc = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BankAccountsCompanion.insert({
    required String id,
    required String tenantId,
    required String kind,
    required String name,
    this.bankName = const Value.absent(),
    this.accountLast4 = const Value.absent(),
    this.ifsc = const Value.absent(),
    required int sortOrder,
    required bool isActive,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       kind = Value(kind),
       name = Value(name),
       sortOrder = Value(sortOrder),
       isActive = Value(isActive);
  static Insertable<BankAccount> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? bankName,
    Expression<String>? accountLast4,
    Expression<String>? ifsc,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (bankName != null) 'bank_name': bankName,
      if (accountLast4 != null) 'account_last4': accountLast4,
      if (ifsc != null) 'ifsc': ifsc,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BankAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? kind,
    Value<String>? name,
    Value<String?>? bankName,
    Value<String?>? accountLast4,
    Value<String?>? ifsc,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return BankAccountsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      accountLast4: accountLast4 ?? this.accountLast4,
      ifsc: ifsc ?? this.ifsc,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountLast4.present) {
      map['account_last4'] = Variable<String>(accountLast4.value);
    }
    if (ifsc.present) {
      map['ifsc'] = Variable<String>(ifsc.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('bankName: $bankName, ')
          ..write('accountLast4: $accountLast4, ')
          ..write('ifsc: $ifsc, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiptNoMeta = const VerificationMeta(
    'receiptNo',
  );
  @override
  late final GeneratedColumn<String> receiptNo = GeneratedColumn<String>(
    'receipt_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankAccountIdMeta = const VerificationMeta(
    'bankAccountId',
  );
  @override
  late final GeneratedColumn<String> bankAccountId = GeneratedColumn<String>(
    'bank_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chequeNoMeta = const VerificationMeta(
    'chequeNo',
  );
  @override
  late final GeneratedColumn<String> chequeNo = GeneratedColumn<String>(
    'cheque_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chequeDateMeta = const VerificationMeta(
    'chequeDate',
  );
  @override
  late final GeneratedColumn<String> chequeDate = GeneratedColumn<String>(
    'cheque_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chequeStatusMeta = const VerificationMeta(
    'chequeStatus',
  );
  @override
  late final GeneratedColumn<String> chequeStatus = GeneratedColumn<String>(
    'cheque_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _narrationMeta = const VerificationMeta(
    'narration',
  );
  @override
  late final GeneratedColumn<String> narration = GeneratedColumn<String>(
    'narration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reversedAtMeta = const VerificationMeta(
    'reversedAt',
  );
  @override
  late final GeneratedColumn<String> reversedAt = GeneratedColumn<String>(
    'reversed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
    'loan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    receiptNo,
    entryDate,
    partyId,
    direction,
    mode,
    amountPaise,
    bankAccountId,
    reference,
    chequeNo,
    chequeDate,
    chequeStatus,
    narration,
    status,
    reversedAt,
    loanId,
    deviceId,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('receipt_no')) {
      context.handle(
        _receiptNoMeta,
        receiptNo.isAcceptableOrUnknown(data['receipt_no']!, _receiptNoMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptNoMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
        _bankAccountIdMeta,
        bankAccountId.isAcceptableOrUnknown(
          data['bank_account_id']!,
          _bankAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bankAccountIdMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('cheque_no')) {
      context.handle(
        _chequeNoMeta,
        chequeNo.isAcceptableOrUnknown(data['cheque_no']!, _chequeNoMeta),
      );
    }
    if (data.containsKey('cheque_date')) {
      context.handle(
        _chequeDateMeta,
        chequeDate.isAcceptableOrUnknown(data['cheque_date']!, _chequeDateMeta),
      );
    }
    if (data.containsKey('cheque_status')) {
      context.handle(
        _chequeStatusMeta,
        chequeStatus.isAcceptableOrUnknown(
          data['cheque_status']!,
          _chequeStatusMeta,
        ),
      );
    }
    if (data.containsKey('narration')) {
      context.handle(
        _narrationMeta,
        narration.isAcceptableOrUnknown(data['narration']!, _narrationMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reversed_at')) {
      context.handle(
        _reversedAtMeta,
        reversedAt.isAcceptableOrUnknown(data['reversed_at']!, _reversedAtMeta),
      );
    }
    if (data.containsKey('loan_id')) {
      context.handle(
        _loanIdMeta,
        loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      receiptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_no'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      bankAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_account_id'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      chequeNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cheque_no'],
      ),
      chequeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cheque_date'],
      ),
      chequeStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cheque_status'],
      ),
      narration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narration'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reversedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reversed_at'],
      ),
      loanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String tenantId;
  final String receiptNo;
  final String entryDate;
  final String partyId;
  final String direction;
  final String mode;
  final int amountPaise;
  final String bankAccountId;
  final String? reference;
  final String? chequeNo;
  final String? chequeDate;
  final String? chequeStatus;
  final String? narration;
  final String status;
  final String? reversedAt;
  final String? loanId;
  final String? deviceId;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const Payment({
    required this.id,
    required this.tenantId,
    required this.receiptNo,
    required this.entryDate,
    required this.partyId,
    required this.direction,
    required this.mode,
    required this.amountPaise,
    required this.bankAccountId,
    this.reference,
    this.chequeNo,
    this.chequeDate,
    this.chequeStatus,
    this.narration,
    required this.status,
    this.reversedAt,
    this.loanId,
    this.deviceId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['receipt_no'] = Variable<String>(receiptNo);
    map['entry_date'] = Variable<String>(entryDate);
    map['party_id'] = Variable<String>(partyId);
    map['direction'] = Variable<String>(direction);
    map['mode'] = Variable<String>(mode);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['bank_account_id'] = Variable<String>(bankAccountId);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || chequeNo != null) {
      map['cheque_no'] = Variable<String>(chequeNo);
    }
    if (!nullToAbsent || chequeDate != null) {
      map['cheque_date'] = Variable<String>(chequeDate);
    }
    if (!nullToAbsent || chequeStatus != null) {
      map['cheque_status'] = Variable<String>(chequeStatus);
    }
    if (!nullToAbsent || narration != null) {
      map['narration'] = Variable<String>(narration);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reversedAt != null) {
      map['reversed_at'] = Variable<String>(reversedAt);
    }
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<String>(loanId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      receiptNo: Value(receiptNo),
      entryDate: Value(entryDate),
      partyId: Value(partyId),
      direction: Value(direction),
      mode: Value(mode),
      amountPaise: Value(amountPaise),
      bankAccountId: Value(bankAccountId),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      chequeNo: chequeNo == null && nullToAbsent
          ? const Value.absent()
          : Value(chequeNo),
      chequeDate: chequeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(chequeDate),
      chequeStatus: chequeStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(chequeStatus),
      narration: narration == null && nullToAbsent
          ? const Value.absent()
          : Value(narration),
      status: Value(status),
      reversedAt: reversedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reversedAt),
      loanId: loanId == null && nullToAbsent
          ? const Value.absent()
          : Value(loanId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      receiptNo: serializer.fromJson<String>(json['receiptNo']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      partyId: serializer.fromJson<String>(json['partyId']),
      direction: serializer.fromJson<String>(json['direction']),
      mode: serializer.fromJson<String>(json['mode']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      bankAccountId: serializer.fromJson<String>(json['bankAccountId']),
      reference: serializer.fromJson<String?>(json['reference']),
      chequeNo: serializer.fromJson<String?>(json['chequeNo']),
      chequeDate: serializer.fromJson<String?>(json['chequeDate']),
      chequeStatus: serializer.fromJson<String?>(json['chequeStatus']),
      narration: serializer.fromJson<String?>(json['narration']),
      status: serializer.fromJson<String>(json['status']),
      reversedAt: serializer.fromJson<String?>(json['reversedAt']),
      loanId: serializer.fromJson<String?>(json['loanId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'receiptNo': serializer.toJson<String>(receiptNo),
      'entryDate': serializer.toJson<String>(entryDate),
      'partyId': serializer.toJson<String>(partyId),
      'direction': serializer.toJson<String>(direction),
      'mode': serializer.toJson<String>(mode),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'bankAccountId': serializer.toJson<String>(bankAccountId),
      'reference': serializer.toJson<String?>(reference),
      'chequeNo': serializer.toJson<String?>(chequeNo),
      'chequeDate': serializer.toJson<String?>(chequeDate),
      'chequeStatus': serializer.toJson<String?>(chequeStatus),
      'narration': serializer.toJson<String?>(narration),
      'status': serializer.toJson<String>(status),
      'reversedAt': serializer.toJson<String?>(reversedAt),
      'loanId': serializer.toJson<String?>(loanId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Payment copyWith({
    String? id,
    String? tenantId,
    String? receiptNo,
    String? entryDate,
    String? partyId,
    String? direction,
    String? mode,
    int? amountPaise,
    String? bankAccountId,
    Value<String?> reference = const Value.absent(),
    Value<String?> chequeNo = const Value.absent(),
    Value<String?> chequeDate = const Value.absent(),
    Value<String?> chequeStatus = const Value.absent(),
    Value<String?> narration = const Value.absent(),
    String? status,
    Value<String?> reversedAt = const Value.absent(),
    Value<String?> loanId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Payment(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    receiptNo: receiptNo ?? this.receiptNo,
    entryDate: entryDate ?? this.entryDate,
    partyId: partyId ?? this.partyId,
    direction: direction ?? this.direction,
    mode: mode ?? this.mode,
    amountPaise: amountPaise ?? this.amountPaise,
    bankAccountId: bankAccountId ?? this.bankAccountId,
    reference: reference.present ? reference.value : this.reference,
    chequeNo: chequeNo.present ? chequeNo.value : this.chequeNo,
    chequeDate: chequeDate.present ? chequeDate.value : this.chequeDate,
    chequeStatus: chequeStatus.present ? chequeStatus.value : this.chequeStatus,
    narration: narration.present ? narration.value : this.narration,
    status: status ?? this.status,
    reversedAt: reversedAt.present ? reversedAt.value : this.reversedAt,
    loanId: loanId.present ? loanId.value : this.loanId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      receiptNo: data.receiptNo.present ? data.receiptNo.value : this.receiptNo,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      direction: data.direction.present ? data.direction.value : this.direction,
      mode: data.mode.present ? data.mode.value : this.mode,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      reference: data.reference.present ? data.reference.value : this.reference,
      chequeNo: data.chequeNo.present ? data.chequeNo.value : this.chequeNo,
      chequeDate: data.chequeDate.present
          ? data.chequeDate.value
          : this.chequeDate,
      chequeStatus: data.chequeStatus.present
          ? data.chequeStatus.value
          : this.chequeStatus,
      narration: data.narration.present ? data.narration.value : this.narration,
      status: data.status.present ? data.status.value : this.status,
      reversedAt: data.reversedAt.present
          ? data.reversedAt.value
          : this.reversedAt,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('entryDate: $entryDate, ')
          ..write('partyId: $partyId, ')
          ..write('direction: $direction, ')
          ..write('mode: $mode, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('reference: $reference, ')
          ..write('chequeNo: $chequeNo, ')
          ..write('chequeDate: $chequeDate, ')
          ..write('chequeStatus: $chequeStatus, ')
          ..write('narration: $narration, ')
          ..write('status: $status, ')
          ..write('reversedAt: $reversedAt, ')
          ..write('loanId: $loanId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    tenantId,
    receiptNo,
    entryDate,
    partyId,
    direction,
    mode,
    amountPaise,
    bankAccountId,
    reference,
    chequeNo,
    chequeDate,
    chequeStatus,
    narration,
    status,
    reversedAt,
    loanId,
    deviceId,
    createdBy,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.receiptNo == this.receiptNo &&
          other.entryDate == this.entryDate &&
          other.partyId == this.partyId &&
          other.direction == this.direction &&
          other.mode == this.mode &&
          other.amountPaise == this.amountPaise &&
          other.bankAccountId == this.bankAccountId &&
          other.reference == this.reference &&
          other.chequeNo == this.chequeNo &&
          other.chequeDate == this.chequeDate &&
          other.chequeStatus == this.chequeStatus &&
          other.narration == this.narration &&
          other.status == this.status &&
          other.reversedAt == this.reversedAt &&
          other.loanId == this.loanId &&
          other.deviceId == this.deviceId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> receiptNo;
  final Value<String> entryDate;
  final Value<String> partyId;
  final Value<String> direction;
  final Value<String> mode;
  final Value<int> amountPaise;
  final Value<String> bankAccountId;
  final Value<String?> reference;
  final Value<String?> chequeNo;
  final Value<String?> chequeDate;
  final Value<String?> chequeStatus;
  final Value<String?> narration;
  final Value<String> status;
  final Value<String?> reversedAt;
  final Value<String?> loanId;
  final Value<String?> deviceId;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.receiptNo = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.partyId = const Value.absent(),
    this.direction = const Value.absent(),
    this.mode = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.reference = const Value.absent(),
    this.chequeNo = const Value.absent(),
    this.chequeDate = const Value.absent(),
    this.chequeStatus = const Value.absent(),
    this.narration = const Value.absent(),
    this.status = const Value.absent(),
    this.reversedAt = const Value.absent(),
    this.loanId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String tenantId,
    required String receiptNo,
    required String entryDate,
    required String partyId,
    required String direction,
    required String mode,
    required int amountPaise,
    required String bankAccountId,
    this.reference = const Value.absent(),
    this.chequeNo = const Value.absent(),
    this.chequeDate = const Value.absent(),
    this.chequeStatus = const Value.absent(),
    this.narration = const Value.absent(),
    required String status,
    this.reversedAt = const Value.absent(),
    this.loanId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       receiptNo = Value(receiptNo),
       entryDate = Value(entryDate),
       partyId = Value(partyId),
       direction = Value(direction),
       mode = Value(mode),
       amountPaise = Value(amountPaise),
       bankAccountId = Value(bankAccountId),
       status = Value(status);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? receiptNo,
    Expression<String>? entryDate,
    Expression<String>? partyId,
    Expression<String>? direction,
    Expression<String>? mode,
    Expression<int>? amountPaise,
    Expression<String>? bankAccountId,
    Expression<String>? reference,
    Expression<String>? chequeNo,
    Expression<String>? chequeDate,
    Expression<String>? chequeStatus,
    Expression<String>? narration,
    Expression<String>? status,
    Expression<String>? reversedAt,
    Expression<String>? loanId,
    Expression<String>? deviceId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (receiptNo != null) 'receipt_no': receiptNo,
      if (entryDate != null) 'entry_date': entryDate,
      if (partyId != null) 'party_id': partyId,
      if (direction != null) 'direction': direction,
      if (mode != null) 'mode': mode,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (reference != null) 'reference': reference,
      if (chequeNo != null) 'cheque_no': chequeNo,
      if (chequeDate != null) 'cheque_date': chequeDate,
      if (chequeStatus != null) 'cheque_status': chequeStatus,
      if (narration != null) 'narration': narration,
      if (status != null) 'status': status,
      if (reversedAt != null) 'reversed_at': reversedAt,
      if (loanId != null) 'loan_id': loanId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? receiptNo,
    Value<String>? entryDate,
    Value<String>? partyId,
    Value<String>? direction,
    Value<String>? mode,
    Value<int>? amountPaise,
    Value<String>? bankAccountId,
    Value<String?>? reference,
    Value<String?>? chequeNo,
    Value<String?>? chequeDate,
    Value<String?>? chequeStatus,
    Value<String?>? narration,
    Value<String>? status,
    Value<String?>? reversedAt,
    Value<String?>? loanId,
    Value<String?>? deviceId,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      receiptNo: receiptNo ?? this.receiptNo,
      entryDate: entryDate ?? this.entryDate,
      partyId: partyId ?? this.partyId,
      direction: direction ?? this.direction,
      mode: mode ?? this.mode,
      amountPaise: amountPaise ?? this.amountPaise,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      reference: reference ?? this.reference,
      chequeNo: chequeNo ?? this.chequeNo,
      chequeDate: chequeDate ?? this.chequeDate,
      chequeStatus: chequeStatus ?? this.chequeStatus,
      narration: narration ?? this.narration,
      status: status ?? this.status,
      reversedAt: reversedAt ?? this.reversedAt,
      loanId: loanId ?? this.loanId,
      deviceId: deviceId ?? this.deviceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (receiptNo.present) {
      map['receipt_no'] = Variable<String>(receiptNo.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<String>(bankAccountId.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (chequeNo.present) {
      map['cheque_no'] = Variable<String>(chequeNo.value);
    }
    if (chequeDate.present) {
      map['cheque_date'] = Variable<String>(chequeDate.value);
    }
    if (chequeStatus.present) {
      map['cheque_status'] = Variable<String>(chequeStatus.value);
    }
    if (narration.present) {
      map['narration'] = Variable<String>(narration.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reversedAt.present) {
      map['reversed_at'] = Variable<String>(reversedAt.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('entryDate: $entryDate, ')
          ..write('partyId: $partyId, ')
          ..write('direction: $direction, ')
          ..write('mode: $mode, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('reference: $reference, ')
          ..write('chequeNo: $chequeNo, ')
          ..write('chequeDate: $chequeDate, ')
          ..write('chequeStatus: $chequeStatus, ')
          ..write('narration: $narration, ')
          ..write('status: $status, ')
          ..write('reversedAt: $reversedAt, ')
          ..write('loanId: $loanId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashBankEntriesTable extends CashBankEntries
    with TableInfo<$CashBankEntriesTable, CashBankEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashBankEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountKindMeta = const VerificationMeta(
    'accountKind',
  );
  @override
  late final GeneratedColumn<String> accountKind = GeneratedColumn<String>(
    'account_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _narrationMeta = const VerificationMeta(
    'narration',
  );
  @override
  late final GeneratedColumn<String> narration = GeneratedColumn<String>(
    'narration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversesIdMeta = const VerificationMeta(
    'reversesId',
  );
  @override
  late final GeneratedColumn<String> reversesId = GeneratedColumn<String>(
    'reverses_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    accountId,
    accountKind,
    entryDate,
    direction,
    amountPaise,
    paymentId,
    narration,
    reversesId,
    deviceId,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_bank_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashBankEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('account_kind')) {
      context.handle(
        _accountKindMeta,
        accountKind.isAcceptableOrUnknown(
          data['account_kind']!,
          _accountKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountKindMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('narration')) {
      context.handle(
        _narrationMeta,
        narration.isAcceptableOrUnknown(data['narration']!, _narrationMeta),
      );
    }
    if (data.containsKey('reverses_id')) {
      context.handle(
        _reversesIdMeta,
        reversesId.isAcceptableOrUnknown(data['reverses_id']!, _reversesIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashBankEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashBankEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      accountKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_kind'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      narration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narration'],
      ),
      reversesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $CashBankEntriesTable createAlias(String alias) {
    return $CashBankEntriesTable(attachedDatabase, alias);
  }
}

class CashBankEntry extends DataClass implements Insertable<CashBankEntry> {
  final String id;
  final String tenantId;
  final String accountId;
  final String accountKind;
  final String entryDate;
  final String direction;
  final int amountPaise;
  final String paymentId;
  final String? narration;
  final String? reversesId;
  final String? deviceId;
  final String? createdBy;
  final String? createdAt;
  const CashBankEntry({
    required this.id,
    required this.tenantId,
    required this.accountId,
    required this.accountKind,
    required this.entryDate,
    required this.direction,
    required this.amountPaise,
    required this.paymentId,
    this.narration,
    this.reversesId,
    this.deviceId,
    this.createdBy,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['account_id'] = Variable<String>(accountId);
    map['account_kind'] = Variable<String>(accountKind);
    map['entry_date'] = Variable<String>(entryDate);
    map['direction'] = Variable<String>(direction);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['payment_id'] = Variable<String>(paymentId);
    if (!nullToAbsent || narration != null) {
      map['narration'] = Variable<String>(narration);
    }
    if (!nullToAbsent || reversesId != null) {
      map['reverses_id'] = Variable<String>(reversesId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    return map;
  }

  CashBankEntriesCompanion toCompanion(bool nullToAbsent) {
    return CashBankEntriesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      accountId: Value(accountId),
      accountKind: Value(accountKind),
      entryDate: Value(entryDate),
      direction: Value(direction),
      amountPaise: Value(amountPaise),
      paymentId: Value(paymentId),
      narration: narration == null && nullToAbsent
          ? const Value.absent()
          : Value(narration),
      reversesId: reversesId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory CashBankEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashBankEntry(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      accountKind: serializer.fromJson<String>(json['accountKind']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      direction: serializer.fromJson<String>(json['direction']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      paymentId: serializer.fromJson<String>(json['paymentId']),
      narration: serializer.fromJson<String?>(json['narration']),
      reversesId: serializer.fromJson<String?>(json['reversesId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'accountId': serializer.toJson<String>(accountId),
      'accountKind': serializer.toJson<String>(accountKind),
      'entryDate': serializer.toJson<String>(entryDate),
      'direction': serializer.toJson<String>(direction),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'paymentId': serializer.toJson<String>(paymentId),
      'narration': serializer.toJson<String?>(narration),
      'reversesId': serializer.toJson<String?>(reversesId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
    };
  }

  CashBankEntry copyWith({
    String? id,
    String? tenantId,
    String? accountId,
    String? accountKind,
    String? entryDate,
    String? direction,
    int? amountPaise,
    String? paymentId,
    Value<String?> narration = const Value.absent(),
    Value<String?> reversesId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
  }) => CashBankEntry(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    accountId: accountId ?? this.accountId,
    accountKind: accountKind ?? this.accountKind,
    entryDate: entryDate ?? this.entryDate,
    direction: direction ?? this.direction,
    amountPaise: amountPaise ?? this.amountPaise,
    paymentId: paymentId ?? this.paymentId,
    narration: narration.present ? narration.value : this.narration,
    reversesId: reversesId.present ? reversesId.value : this.reversesId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  CashBankEntry copyWithCompanion(CashBankEntriesCompanion data) {
    return CashBankEntry(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      accountKind: data.accountKind.present
          ? data.accountKind.value
          : this.accountKind,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      direction: data.direction.present ? data.direction.value : this.direction,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      narration: data.narration.present ? data.narration.value : this.narration,
      reversesId: data.reversesId.present
          ? data.reversesId.value
          : this.reversesId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashBankEntry(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('accountId: $accountId, ')
          ..write('accountKind: $accountKind, ')
          ..write('entryDate: $entryDate, ')
          ..write('direction: $direction, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('paymentId: $paymentId, ')
          ..write('narration: $narration, ')
          ..write('reversesId: $reversesId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    accountId,
    accountKind,
    entryDate,
    direction,
    amountPaise,
    paymentId,
    narration,
    reversesId,
    deviceId,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashBankEntry &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.accountId == this.accountId &&
          other.accountKind == this.accountKind &&
          other.entryDate == this.entryDate &&
          other.direction == this.direction &&
          other.amountPaise == this.amountPaise &&
          other.paymentId == this.paymentId &&
          other.narration == this.narration &&
          other.reversesId == this.reversesId &&
          other.deviceId == this.deviceId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class CashBankEntriesCompanion extends UpdateCompanion<CashBankEntry> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> accountId;
  final Value<String> accountKind;
  final Value<String> entryDate;
  final Value<String> direction;
  final Value<int> amountPaise;
  final Value<String> paymentId;
  final Value<String?> narration;
  final Value<String?> reversesId;
  final Value<String?> deviceId;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<int> rowid;
  const CashBankEntriesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountKind = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.direction = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.narration = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashBankEntriesCompanion.insert({
    required String id,
    required String tenantId,
    required String accountId,
    required String accountKind,
    required String entryDate,
    required String direction,
    required int amountPaise,
    required String paymentId,
    this.narration = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       accountId = Value(accountId),
       accountKind = Value(accountKind),
       entryDate = Value(entryDate),
       direction = Value(direction),
       amountPaise = Value(amountPaise),
       paymentId = Value(paymentId);
  static Insertable<CashBankEntry> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? accountId,
    Expression<String>? accountKind,
    Expression<String>? entryDate,
    Expression<String>? direction,
    Expression<int>? amountPaise,
    Expression<String>? paymentId,
    Expression<String>? narration,
    Expression<String>? reversesId,
    Expression<String>? deviceId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (accountId != null) 'account_id': accountId,
      if (accountKind != null) 'account_kind': accountKind,
      if (entryDate != null) 'entry_date': entryDate,
      if (direction != null) 'direction': direction,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (paymentId != null) 'payment_id': paymentId,
      if (narration != null) 'narration': narration,
      if (reversesId != null) 'reverses_id': reversesId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashBankEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? accountId,
    Value<String>? accountKind,
    Value<String>? entryDate,
    Value<String>? direction,
    Value<int>? amountPaise,
    Value<String>? paymentId,
    Value<String?>? narration,
    Value<String?>? reversesId,
    Value<String?>? deviceId,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<int>? rowid,
  }) {
    return CashBankEntriesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      accountId: accountId ?? this.accountId,
      accountKind: accountKind ?? this.accountKind,
      entryDate: entryDate ?? this.entryDate,
      direction: direction ?? this.direction,
      amountPaise: amountPaise ?? this.amountPaise,
      paymentId: paymentId ?? this.paymentId,
      narration: narration ?? this.narration,
      reversesId: reversesId ?? this.reversesId,
      deviceId: deviceId ?? this.deviceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (accountKind.present) {
      map['account_kind'] = Variable<String>(accountKind.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (narration.present) {
      map['narration'] = Variable<String>(narration.value);
    }
    if (reversesId.present) {
      map['reverses_id'] = Variable<String>(reversesId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashBankEntriesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('accountId: $accountId, ')
          ..write('accountKind: $accountKind, ')
          ..write('entryDate: $entryDate, ')
          ..write('direction: $direction, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('paymentId: $paymentId, ')
          ..write('narration: $narration, ')
          ..write('reversesId: $reversesId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loanNoMeta = const VerificationMeta('loanNo');
  @override
  late final GeneratedColumn<String> loanNo = GeneratedColumn<String>(
    'loan_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<String> issueDate = GeneratedColumn<String>(
    'issue_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principalPaiseMeta = const VerificationMeta(
    'principalPaise',
  );
  @override
  late final GeneratedColumn<int> principalPaise = GeneratedColumn<int>(
    'principal_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guarantorPartyIdMeta = const VerificationMeta(
    'guarantorPartyId',
  );
  @override
  late final GeneratedColumn<String> guarantorPartyId = GeneratedColumn<String>(
    'guarantor_party_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interestConfigSnapshotMeta =
      const VerificationMeta('interestConfigSnapshot');
  @override
  late final GeneratedColumn<String> interestConfigSnapshot =
      GeneratedColumn<String>(
        'interest_config_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedOnMeta = const VerificationMeta(
    'closedOn',
  );
  @override
  late final GeneratedColumn<String> closedOn = GeneratedColumn<String>(
    'closed_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closeReasonMeta = const VerificationMeta(
    'closeReason',
  );
  @override
  late final GeneratedColumn<String> closeReason = GeneratedColumn<String>(
    'close_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    loanNo,
    partyId,
    issueDate,
    principalPaise,
    purpose,
    dueDate,
    guarantorPartyId,
    interestConfigSnapshot,
    status,
    closedOn,
    closeReason,
    notes,
    deviceId,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Loan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('loan_no')) {
      context.handle(
        _loanNoMeta,
        loanNo.isAcceptableOrUnknown(data['loan_no']!, _loanNoMeta),
      );
    } else if (isInserting) {
      context.missing(_loanNoMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    if (data.containsKey('principal_paise')) {
      context.handle(
        _principalPaiseMeta,
        principalPaise.isAcceptableOrUnknown(
          data['principal_paise']!,
          _principalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalPaiseMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('guarantor_party_id')) {
      context.handle(
        _guarantorPartyIdMeta,
        guarantorPartyId.isAcceptableOrUnknown(
          data['guarantor_party_id']!,
          _guarantorPartyIdMeta,
        ),
      );
    }
    if (data.containsKey('interest_config_snapshot')) {
      context.handle(
        _interestConfigSnapshotMeta,
        interestConfigSnapshot.isAcceptableOrUnknown(
          data['interest_config_snapshot']!,
          _interestConfigSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestConfigSnapshotMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('closed_on')) {
      context.handle(
        _closedOnMeta,
        closedOn.isAcceptableOrUnknown(data['closed_on']!, _closedOnMeta),
      );
    }
    if (data.containsKey('close_reason')) {
      context.handle(
        _closeReasonMeta,
        closeReason.isAcceptableOrUnknown(
          data['close_reason']!,
          _closeReasonMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      loanNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_no'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_date'],
      )!,
      principalPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}principal_paise'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
      guarantorPartyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guarantor_party_id'],
      ),
      interestConfigSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_config_snapshot'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      closedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_on'],
      ),
      closeReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}close_reason'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  final String id;
  final String tenantId;
  final String loanNo;
  final String partyId;
  final String issueDate;
  final int principalPaise;
  final String? purpose;
  final String? dueDate;
  final String? guarantorPartyId;
  final String interestConfigSnapshot;
  final String status;
  final String? closedOn;
  final String? closeReason;
  final String? notes;
  final String? deviceId;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const Loan({
    required this.id,
    required this.tenantId,
    required this.loanNo,
    required this.partyId,
    required this.issueDate,
    required this.principalPaise,
    this.purpose,
    this.dueDate,
    this.guarantorPartyId,
    required this.interestConfigSnapshot,
    required this.status,
    this.closedOn,
    this.closeReason,
    this.notes,
    this.deviceId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['loan_no'] = Variable<String>(loanNo);
    map['party_id'] = Variable<String>(partyId);
    map['issue_date'] = Variable<String>(issueDate);
    map['principal_paise'] = Variable<int>(principalPaise);
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || guarantorPartyId != null) {
      map['guarantor_party_id'] = Variable<String>(guarantorPartyId);
    }
    map['interest_config_snapshot'] = Variable<String>(interestConfigSnapshot);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || closedOn != null) {
      map['closed_on'] = Variable<String>(closedOn);
    }
    if (!nullToAbsent || closeReason != null) {
      map['close_reason'] = Variable<String>(closeReason);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      loanNo: Value(loanNo),
      partyId: Value(partyId),
      issueDate: Value(issueDate),
      principalPaise: Value(principalPaise),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      guarantorPartyId: guarantorPartyId == null && nullToAbsent
          ? const Value.absent()
          : Value(guarantorPartyId),
      interestConfigSnapshot: Value(interestConfigSnapshot),
      status: Value(status),
      closedOn: closedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(closedOn),
      closeReason: closeReason == null && nullToAbsent
          ? const Value.absent()
          : Value(closeReason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Loan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      loanNo: serializer.fromJson<String>(json['loanNo']),
      partyId: serializer.fromJson<String>(json['partyId']),
      issueDate: serializer.fromJson<String>(json['issueDate']),
      principalPaise: serializer.fromJson<int>(json['principalPaise']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      guarantorPartyId: serializer.fromJson<String?>(json['guarantorPartyId']),
      interestConfigSnapshot: serializer.fromJson<String>(
        json['interestConfigSnapshot'],
      ),
      status: serializer.fromJson<String>(json['status']),
      closedOn: serializer.fromJson<String?>(json['closedOn']),
      closeReason: serializer.fromJson<String?>(json['closeReason']),
      notes: serializer.fromJson<String?>(json['notes']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'loanNo': serializer.toJson<String>(loanNo),
      'partyId': serializer.toJson<String>(partyId),
      'issueDate': serializer.toJson<String>(issueDate),
      'principalPaise': serializer.toJson<int>(principalPaise),
      'purpose': serializer.toJson<String?>(purpose),
      'dueDate': serializer.toJson<String?>(dueDate),
      'guarantorPartyId': serializer.toJson<String?>(guarantorPartyId),
      'interestConfigSnapshot': serializer.toJson<String>(
        interestConfigSnapshot,
      ),
      'status': serializer.toJson<String>(status),
      'closedOn': serializer.toJson<String?>(closedOn),
      'closeReason': serializer.toJson<String?>(closeReason),
      'notes': serializer.toJson<String?>(notes),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Loan copyWith({
    String? id,
    String? tenantId,
    String? loanNo,
    String? partyId,
    String? issueDate,
    int? principalPaise,
    Value<String?> purpose = const Value.absent(),
    Value<String?> dueDate = const Value.absent(),
    Value<String?> guarantorPartyId = const Value.absent(),
    String? interestConfigSnapshot,
    String? status,
    Value<String?> closedOn = const Value.absent(),
    Value<String?> closeReason = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Loan(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    loanNo: loanNo ?? this.loanNo,
    partyId: partyId ?? this.partyId,
    issueDate: issueDate ?? this.issueDate,
    principalPaise: principalPaise ?? this.principalPaise,
    purpose: purpose.present ? purpose.value : this.purpose,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    guarantorPartyId: guarantorPartyId.present
        ? guarantorPartyId.value
        : this.guarantorPartyId,
    interestConfigSnapshot:
        interestConfigSnapshot ?? this.interestConfigSnapshot,
    status: status ?? this.status,
    closedOn: closedOn.present ? closedOn.value : this.closedOn,
    closeReason: closeReason.present ? closeReason.value : this.closeReason,
    notes: notes.present ? notes.value : this.notes,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      loanNo: data.loanNo.present ? data.loanNo.value : this.loanNo,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      principalPaise: data.principalPaise.present
          ? data.principalPaise.value
          : this.principalPaise,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      guarantorPartyId: data.guarantorPartyId.present
          ? data.guarantorPartyId.value
          : this.guarantorPartyId,
      interestConfigSnapshot: data.interestConfigSnapshot.present
          ? data.interestConfigSnapshot.value
          : this.interestConfigSnapshot,
      status: data.status.present ? data.status.value : this.status,
      closedOn: data.closedOn.present ? data.closedOn.value : this.closedOn,
      closeReason: data.closeReason.present
          ? data.closeReason.value
          : this.closeReason,
      notes: data.notes.present ? data.notes.value : this.notes,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('loanNo: $loanNo, ')
          ..write('partyId: $partyId, ')
          ..write('issueDate: $issueDate, ')
          ..write('principalPaise: $principalPaise, ')
          ..write('purpose: $purpose, ')
          ..write('dueDate: $dueDate, ')
          ..write('guarantorPartyId: $guarantorPartyId, ')
          ..write('interestConfigSnapshot: $interestConfigSnapshot, ')
          ..write('status: $status, ')
          ..write('closedOn: $closedOn, ')
          ..write('closeReason: $closeReason, ')
          ..write('notes: $notes, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    loanNo,
    partyId,
    issueDate,
    principalPaise,
    purpose,
    dueDate,
    guarantorPartyId,
    interestConfigSnapshot,
    status,
    closedOn,
    closeReason,
    notes,
    deviceId,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.loanNo == this.loanNo &&
          other.partyId == this.partyId &&
          other.issueDate == this.issueDate &&
          other.principalPaise == this.principalPaise &&
          other.purpose == this.purpose &&
          other.dueDate == this.dueDate &&
          other.guarantorPartyId == this.guarantorPartyId &&
          other.interestConfigSnapshot == this.interestConfigSnapshot &&
          other.status == this.status &&
          other.closedOn == this.closedOn &&
          other.closeReason == this.closeReason &&
          other.notes == this.notes &&
          other.deviceId == this.deviceId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> loanNo;
  final Value<String> partyId;
  final Value<String> issueDate;
  final Value<int> principalPaise;
  final Value<String?> purpose;
  final Value<String?> dueDate;
  final Value<String?> guarantorPartyId;
  final Value<String> interestConfigSnapshot;
  final Value<String> status;
  final Value<String?> closedOn;
  final Value<String?> closeReason;
  final Value<String?> notes;
  final Value<String?> deviceId;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.loanNo = const Value.absent(),
    this.partyId = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.principalPaise = const Value.absent(),
    this.purpose = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.guarantorPartyId = const Value.absent(),
    this.interestConfigSnapshot = const Value.absent(),
    this.status = const Value.absent(),
    this.closedOn = const Value.absent(),
    this.closeReason = const Value.absent(),
    this.notes = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCompanion.insert({
    required String id,
    required String tenantId,
    required String loanNo,
    required String partyId,
    required String issueDate,
    required int principalPaise,
    this.purpose = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.guarantorPartyId = const Value.absent(),
    required String interestConfigSnapshot,
    required String status,
    this.closedOn = const Value.absent(),
    this.closeReason = const Value.absent(),
    this.notes = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       loanNo = Value(loanNo),
       partyId = Value(partyId),
       issueDate = Value(issueDate),
       principalPaise = Value(principalPaise),
       interestConfigSnapshot = Value(interestConfigSnapshot),
       status = Value(status);
  static Insertable<Loan> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? loanNo,
    Expression<String>? partyId,
    Expression<String>? issueDate,
    Expression<int>? principalPaise,
    Expression<String>? purpose,
    Expression<String>? dueDate,
    Expression<String>? guarantorPartyId,
    Expression<String>? interestConfigSnapshot,
    Expression<String>? status,
    Expression<String>? closedOn,
    Expression<String>? closeReason,
    Expression<String>? notes,
    Expression<String>? deviceId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (loanNo != null) 'loan_no': loanNo,
      if (partyId != null) 'party_id': partyId,
      if (issueDate != null) 'issue_date': issueDate,
      if (principalPaise != null) 'principal_paise': principalPaise,
      if (purpose != null) 'purpose': purpose,
      if (dueDate != null) 'due_date': dueDate,
      if (guarantorPartyId != null) 'guarantor_party_id': guarantorPartyId,
      if (interestConfigSnapshot != null)
        'interest_config_snapshot': interestConfigSnapshot,
      if (status != null) 'status': status,
      if (closedOn != null) 'closed_on': closedOn,
      if (closeReason != null) 'close_reason': closeReason,
      if (notes != null) 'notes': notes,
      if (deviceId != null) 'device_id': deviceId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? loanNo,
    Value<String>? partyId,
    Value<String>? issueDate,
    Value<int>? principalPaise,
    Value<String?>? purpose,
    Value<String?>? dueDate,
    Value<String?>? guarantorPartyId,
    Value<String>? interestConfigSnapshot,
    Value<String>? status,
    Value<String?>? closedOn,
    Value<String?>? closeReason,
    Value<String?>? notes,
    Value<String?>? deviceId,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LoansCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      loanNo: loanNo ?? this.loanNo,
      partyId: partyId ?? this.partyId,
      issueDate: issueDate ?? this.issueDate,
      principalPaise: principalPaise ?? this.principalPaise,
      purpose: purpose ?? this.purpose,
      dueDate: dueDate ?? this.dueDate,
      guarantorPartyId: guarantorPartyId ?? this.guarantorPartyId,
      interestConfigSnapshot:
          interestConfigSnapshot ?? this.interestConfigSnapshot,
      status: status ?? this.status,
      closedOn: closedOn ?? this.closedOn,
      closeReason: closeReason ?? this.closeReason,
      notes: notes ?? this.notes,
      deviceId: deviceId ?? this.deviceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (loanNo.present) {
      map['loan_no'] = Variable<String>(loanNo.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<String>(issueDate.value);
    }
    if (principalPaise.present) {
      map['principal_paise'] = Variable<int>(principalPaise.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (guarantorPartyId.present) {
      map['guarantor_party_id'] = Variable<String>(guarantorPartyId.value);
    }
    if (interestConfigSnapshot.present) {
      map['interest_config_snapshot'] = Variable<String>(
        interestConfigSnapshot.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (closedOn.present) {
      map['closed_on'] = Variable<String>(closedOn.value);
    }
    if (closeReason.present) {
      map['close_reason'] = Variable<String>(closeReason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('loanNo: $loanNo, ')
          ..write('partyId: $partyId, ')
          ..write('issueDate: $issueDate, ')
          ..write('principalPaise: $principalPaise, ')
          ..write('purpose: $purpose, ')
          ..write('dueDate: $dueDate, ')
          ..write('guarantorPartyId: $guarantorPartyId, ')
          ..write('interestConfigSnapshot: $interestConfigSnapshot, ')
          ..write('status: $status, ')
          ..write('closedOn: $closedOn, ')
          ..write('closeReason: $closeReason, ')
          ..write('notes: $notes, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoanRateChangesTable extends LoanRateChanges
    with TableInfo<$LoanRateChangesTable, LoanRateChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoanRateChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
    'loan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveDateMeta = const VerificationMeta(
    'effectiveDate',
  );
  @override
  late final GeneratedColumn<String> effectiveDate = GeneratedColumn<String>(
    'effective_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePaMeta = const VerificationMeta('ratePa');
  @override
  late final GeneratedColumn<String> ratePa = GeneratedColumn<String>(
    'rate_pa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    loanId,
    effectiveDate,
    ratePa,
    reason,
    deviceId,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loan_rate_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoanRateChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('loan_id')) {
      context.handle(
        _loanIdMeta,
        loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loanIdMeta);
    }
    if (data.containsKey('effective_date')) {
      context.handle(
        _effectiveDateMeta,
        effectiveDate.isAcceptableOrUnknown(
          data['effective_date']!,
          _effectiveDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveDateMeta);
    }
    if (data.containsKey('rate_pa')) {
      context.handle(
        _ratePaMeta,
        ratePa.isAcceptableOrUnknown(data['rate_pa']!, _ratePaMeta),
      );
    } else if (isInserting) {
      context.missing(_ratePaMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoanRateChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanRateChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      loanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_id'],
      )!,
      effectiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_date'],
      )!,
      ratePa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_pa'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $LoanRateChangesTable createAlias(String alias) {
    return $LoanRateChangesTable(attachedDatabase, alias);
  }
}

class LoanRateChange extends DataClass implements Insertable<LoanRateChange> {
  final String id;
  final String tenantId;
  final String loanId;
  final String effectiveDate;
  final String ratePa;
  final String? reason;
  final String? deviceId;
  final String? createdBy;
  final String? createdAt;
  const LoanRateChange({
    required this.id,
    required this.tenantId,
    required this.loanId,
    required this.effectiveDate,
    required this.ratePa,
    this.reason,
    this.deviceId,
    this.createdBy,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['loan_id'] = Variable<String>(loanId);
    map['effective_date'] = Variable<String>(effectiveDate);
    map['rate_pa'] = Variable<String>(ratePa);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    return map;
  }

  LoanRateChangesCompanion toCompanion(bool nullToAbsent) {
    return LoanRateChangesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      loanId: Value(loanId),
      effectiveDate: Value(effectiveDate),
      ratePa: Value(ratePa),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory LoanRateChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanRateChange(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      loanId: serializer.fromJson<String>(json['loanId']),
      effectiveDate: serializer.fromJson<String>(json['effectiveDate']),
      ratePa: serializer.fromJson<String>(json['ratePa']),
      reason: serializer.fromJson<String?>(json['reason']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'loanId': serializer.toJson<String>(loanId),
      'effectiveDate': serializer.toJson<String>(effectiveDate),
      'ratePa': serializer.toJson<String>(ratePa),
      'reason': serializer.toJson<String?>(reason),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
    };
  }

  LoanRateChange copyWith({
    String? id,
    String? tenantId,
    String? loanId,
    String? effectiveDate,
    String? ratePa,
    Value<String?> reason = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
  }) => LoanRateChange(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    loanId: loanId ?? this.loanId,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    ratePa: ratePa ?? this.ratePa,
    reason: reason.present ? reason.value : this.reason,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  LoanRateChange copyWithCompanion(LoanRateChangesCompanion data) {
    return LoanRateChange(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      ratePa: data.ratePa.present ? data.ratePa.value : this.ratePa,
      reason: data.reason.present ? data.reason.value : this.reason,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanRateChange(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('loanId: $loanId, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ratePa: $ratePa, ')
          ..write('reason: $reason, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    loanId,
    effectiveDate,
    ratePa,
    reason,
    deviceId,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanRateChange &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.loanId == this.loanId &&
          other.effectiveDate == this.effectiveDate &&
          other.ratePa == this.ratePa &&
          other.reason == this.reason &&
          other.deviceId == this.deviceId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class LoanRateChangesCompanion extends UpdateCompanion<LoanRateChange> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> loanId;
  final Value<String> effectiveDate;
  final Value<String> ratePa;
  final Value<String?> reason;
  final Value<String?> deviceId;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<int> rowid;
  const LoanRateChangesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.ratePa = const Value.absent(),
    this.reason = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoanRateChangesCompanion.insert({
    required String id,
    required String tenantId,
    required String loanId,
    required String effectiveDate,
    required String ratePa,
    this.reason = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       loanId = Value(loanId),
       effectiveDate = Value(effectiveDate),
       ratePa = Value(ratePa);
  static Insertable<LoanRateChange> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? loanId,
    Expression<String>? effectiveDate,
    Expression<String>? ratePa,
    Expression<String>? reason,
    Expression<String>? deviceId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (loanId != null) 'loan_id': loanId,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (ratePa != null) 'rate_pa': ratePa,
      if (reason != null) 'reason': reason,
      if (deviceId != null) 'device_id': deviceId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoanRateChangesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? loanId,
    Value<String>? effectiveDate,
    Value<String>? ratePa,
    Value<String?>? reason,
    Value<String?>? deviceId,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<int>? rowid,
  }) {
    return LoanRateChangesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      loanId: loanId ?? this.loanId,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      ratePa: ratePa ?? this.ratePa,
      reason: reason ?? this.reason,
      deviceId: deviceId ?? this.deviceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<String>(effectiveDate.value);
    }
    if (ratePa.present) {
      map['rate_pa'] = Variable<String>(ratePa.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoanRateChangesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('loanId: $loanId, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ratePa: $ratePa, ')
          ..write('reason: $reason, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterestPostingsTable extends InterestPostings
    with TableInfo<$InterestPostingsTable, InterestPosting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterestPostingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
    'loan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodFromMeta = const VerificationMeta(
    'periodFrom',
  );
  @override
  late final GeneratedColumn<String> periodFrom = GeneratedColumn<String>(
    'period_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodToMeta = const VerificationMeta(
    'periodTo',
  );
  @override
  late final GeneratedColumn<String> periodTo = GeneratedColumn<String>(
    'period_to',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePaMeta = const VerificationMeta('ratePa');
  @override
  late final GeneratedColumn<String> ratePa = GeneratedColumn<String>(
    'rate_pa',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    partyId,
    loanId,
    kind,
    periodFrom,
    periodTo,
    amountPaise,
    ratePa,
    method,
    reason,
    periodKey,
    batchId,
    deviceId,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interest_postings';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterestPosting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('loan_id')) {
      context.handle(
        _loanIdMeta,
        loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('period_from')) {
      context.handle(
        _periodFromMeta,
        periodFrom.isAcceptableOrUnknown(data['period_from']!, _periodFromMeta),
      );
    } else if (isInserting) {
      context.missing(_periodFromMeta);
    }
    if (data.containsKey('period_to')) {
      context.handle(
        _periodToMeta,
        periodTo.isAcceptableOrUnknown(data['period_to']!, _periodToMeta),
      );
    } else if (isInserting) {
      context.missing(_periodToMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('rate_pa')) {
      context.handle(
        _ratePaMeta,
        ratePa.isAcceptableOrUnknown(data['rate_pa']!, _ratePaMeta),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterestPosting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterestPosting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      loanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      periodFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_from'],
      )!,
      periodTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_to'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      ratePa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_pa'],
      ),
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $InterestPostingsTable createAlias(String alias) {
    return $InterestPostingsTable(attachedDatabase, alias);
  }
}

class InterestPosting extends DataClass implements Insertable<InterestPosting> {
  final String id;
  final String tenantId;
  final String partyId;
  final String? loanId;
  final String kind;
  final String periodFrom;
  final String periodTo;
  final int amountPaise;
  final String? ratePa;
  final String? method;
  final String? reason;
  final String periodKey;
  final String? batchId;
  final String? deviceId;
  final String? createdBy;
  final String? createdAt;
  const InterestPosting({
    required this.id,
    required this.tenantId,
    required this.partyId,
    this.loanId,
    required this.kind,
    required this.periodFrom,
    required this.periodTo,
    required this.amountPaise,
    this.ratePa,
    this.method,
    this.reason,
    required this.periodKey,
    this.batchId,
    this.deviceId,
    this.createdBy,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['party_id'] = Variable<String>(partyId);
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<String>(loanId);
    }
    map['kind'] = Variable<String>(kind);
    map['period_from'] = Variable<String>(periodFrom);
    map['period_to'] = Variable<String>(periodTo);
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || ratePa != null) {
      map['rate_pa'] = Variable<String>(ratePa);
    }
    if (!nullToAbsent || method != null) {
      map['method'] = Variable<String>(method);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['period_key'] = Variable<String>(periodKey);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    return map;
  }

  InterestPostingsCompanion toCompanion(bool nullToAbsent) {
    return InterestPostingsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      partyId: Value(partyId),
      loanId: loanId == null && nullToAbsent
          ? const Value.absent()
          : Value(loanId),
      kind: Value(kind),
      periodFrom: Value(periodFrom),
      periodTo: Value(periodTo),
      amountPaise: Value(amountPaise),
      ratePa: ratePa == null && nullToAbsent
          ? const Value.absent()
          : Value(ratePa),
      method: method == null && nullToAbsent
          ? const Value.absent()
          : Value(method),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      periodKey: Value(periodKey),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory InterestPosting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterestPosting(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      partyId: serializer.fromJson<String>(json['partyId']),
      loanId: serializer.fromJson<String?>(json['loanId']),
      kind: serializer.fromJson<String>(json['kind']),
      periodFrom: serializer.fromJson<String>(json['periodFrom']),
      periodTo: serializer.fromJson<String>(json['periodTo']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      ratePa: serializer.fromJson<String?>(json['ratePa']),
      method: serializer.fromJson<String?>(json['method']),
      reason: serializer.fromJson<String?>(json['reason']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'partyId': serializer.toJson<String>(partyId),
      'loanId': serializer.toJson<String?>(loanId),
      'kind': serializer.toJson<String>(kind),
      'periodFrom': serializer.toJson<String>(periodFrom),
      'periodTo': serializer.toJson<String>(periodTo),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'ratePa': serializer.toJson<String?>(ratePa),
      'method': serializer.toJson<String?>(method),
      'reason': serializer.toJson<String?>(reason),
      'periodKey': serializer.toJson<String>(periodKey),
      'batchId': serializer.toJson<String?>(batchId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
    };
  }

  InterestPosting copyWith({
    String? id,
    String? tenantId,
    String? partyId,
    Value<String?> loanId = const Value.absent(),
    String? kind,
    String? periodFrom,
    String? periodTo,
    int? amountPaise,
    Value<String?> ratePa = const Value.absent(),
    Value<String?> method = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    String? periodKey,
    Value<String?> batchId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
  }) => InterestPosting(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    partyId: partyId ?? this.partyId,
    loanId: loanId.present ? loanId.value : this.loanId,
    kind: kind ?? this.kind,
    periodFrom: periodFrom ?? this.periodFrom,
    periodTo: periodTo ?? this.periodTo,
    amountPaise: amountPaise ?? this.amountPaise,
    ratePa: ratePa.present ? ratePa.value : this.ratePa,
    method: method.present ? method.value : this.method,
    reason: reason.present ? reason.value : this.reason,
    periodKey: periodKey ?? this.periodKey,
    batchId: batchId.present ? batchId.value : this.batchId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  InterestPosting copyWithCompanion(InterestPostingsCompanion data) {
    return InterestPosting(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      kind: data.kind.present ? data.kind.value : this.kind,
      periodFrom: data.periodFrom.present
          ? data.periodFrom.value
          : this.periodFrom,
      periodTo: data.periodTo.present ? data.periodTo.value : this.periodTo,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      ratePa: data.ratePa.present ? data.ratePa.value : this.ratePa,
      method: data.method.present ? data.method.value : this.method,
      reason: data.reason.present ? data.reason.value : this.reason,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterestPosting(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('partyId: $partyId, ')
          ..write('loanId: $loanId, ')
          ..write('kind: $kind, ')
          ..write('periodFrom: $periodFrom, ')
          ..write('periodTo: $periodTo, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('ratePa: $ratePa, ')
          ..write('method: $method, ')
          ..write('reason: $reason, ')
          ..write('periodKey: $periodKey, ')
          ..write('batchId: $batchId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    partyId,
    loanId,
    kind,
    periodFrom,
    periodTo,
    amountPaise,
    ratePa,
    method,
    reason,
    periodKey,
    batchId,
    deviceId,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterestPosting &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.partyId == this.partyId &&
          other.loanId == this.loanId &&
          other.kind == this.kind &&
          other.periodFrom == this.periodFrom &&
          other.periodTo == this.periodTo &&
          other.amountPaise == this.amountPaise &&
          other.ratePa == this.ratePa &&
          other.method == this.method &&
          other.reason == this.reason &&
          other.periodKey == this.periodKey &&
          other.batchId == this.batchId &&
          other.deviceId == this.deviceId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class InterestPostingsCompanion extends UpdateCompanion<InterestPosting> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> partyId;
  final Value<String?> loanId;
  final Value<String> kind;
  final Value<String> periodFrom;
  final Value<String> periodTo;
  final Value<int> amountPaise;
  final Value<String?> ratePa;
  final Value<String?> method;
  final Value<String?> reason;
  final Value<String> periodKey;
  final Value<String?> batchId;
  final Value<String?> deviceId;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<int> rowid;
  const InterestPostingsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.kind = const Value.absent(),
    this.periodFrom = const Value.absent(),
    this.periodTo = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.ratePa = const Value.absent(),
    this.method = const Value.absent(),
    this.reason = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.batchId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterestPostingsCompanion.insert({
    required String id,
    required String tenantId,
    required String partyId,
    this.loanId = const Value.absent(),
    required String kind,
    required String periodFrom,
    required String periodTo,
    required int amountPaise,
    this.ratePa = const Value.absent(),
    this.method = const Value.absent(),
    this.reason = const Value.absent(),
    required String periodKey,
    this.batchId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       partyId = Value(partyId),
       kind = Value(kind),
       periodFrom = Value(periodFrom),
       periodTo = Value(periodTo),
       amountPaise = Value(amountPaise),
       periodKey = Value(periodKey);
  static Insertable<InterestPosting> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? partyId,
    Expression<String>? loanId,
    Expression<String>? kind,
    Expression<String>? periodFrom,
    Expression<String>? periodTo,
    Expression<int>? amountPaise,
    Expression<String>? ratePa,
    Expression<String>? method,
    Expression<String>? reason,
    Expression<String>? periodKey,
    Expression<String>? batchId,
    Expression<String>? deviceId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (partyId != null) 'party_id': partyId,
      if (loanId != null) 'loan_id': loanId,
      if (kind != null) 'kind': kind,
      if (periodFrom != null) 'period_from': periodFrom,
      if (periodTo != null) 'period_to': periodTo,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (ratePa != null) 'rate_pa': ratePa,
      if (method != null) 'method': method,
      if (reason != null) 'reason': reason,
      if (periodKey != null) 'period_key': periodKey,
      if (batchId != null) 'batch_id': batchId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterestPostingsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? partyId,
    Value<String?>? loanId,
    Value<String>? kind,
    Value<String>? periodFrom,
    Value<String>? periodTo,
    Value<int>? amountPaise,
    Value<String?>? ratePa,
    Value<String?>? method,
    Value<String?>? reason,
    Value<String>? periodKey,
    Value<String?>? batchId,
    Value<String?>? deviceId,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<int>? rowid,
  }) {
    return InterestPostingsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      partyId: partyId ?? this.partyId,
      loanId: loanId ?? this.loanId,
      kind: kind ?? this.kind,
      periodFrom: periodFrom ?? this.periodFrom,
      periodTo: periodTo ?? this.periodTo,
      amountPaise: amountPaise ?? this.amountPaise,
      ratePa: ratePa ?? this.ratePa,
      method: method ?? this.method,
      reason: reason ?? this.reason,
      periodKey: periodKey ?? this.periodKey,
      batchId: batchId ?? this.batchId,
      deviceId: deviceId ?? this.deviceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (periodFrom.present) {
      map['period_from'] = Variable<String>(periodFrom.value);
    }
    if (periodTo.present) {
      map['period_to'] = Variable<String>(periodTo.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (ratePa.present) {
      map['rate_pa'] = Variable<String>(ratePa.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterestPostingsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('partyId: $partyId, ')
          ..write('loanId: $loanId, ')
          ..write('kind: $kind, ')
          ..write('periodFrom: $periodFrom, ')
          ..write('periodTo: $periodTo, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('ratePa: $ratePa, ')
          ..write('method: $method, ')
          ..write('reason: $reason, ')
          ..write('periodKey: $periodKey, ')
          ..write('batchId: $batchId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountGroupsTable extends AccountGroups
    with TableInfo<$AccountGroupsTable, AccountGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _natureMeta = const VerificationMeta('nature');
  @override
  late final GeneratedColumn<String> nature = GeneratedColumn<String>(
    'nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    code,
    name,
    parentId,
    nature,
    isSystem,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('nature')) {
      context.handle(
        _natureMeta,
        nature.isAcceptableOrUnknown(data['nature']!, _natureMeta),
      );
    } else if (isInserting) {
      context.missing(_natureMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    } else if (isInserting) {
      context.missing(_isSystemMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      nature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nature'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $AccountGroupsTable createAlias(String alias) {
    return $AccountGroupsTable(attachedDatabase, alias);
  }
}

class AccountGroup extends DataClass implements Insertable<AccountGroup> {
  final String id;
  final String tenantId;
  final String code;
  final String name;
  final String? parentId;
  final String nature;
  final bool isSystem;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const AccountGroup({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    this.parentId,
    required this.nature,
    required this.isSystem,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['nature'] = Variable<String>(nature);
    map['is_system'] = Variable<bool>(isSystem);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  AccountGroupsCompanion toCompanion(bool nullToAbsent) {
    return AccountGroupsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      code: Value(code),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      nature: Value(nature),
      isSystem: Value(isSystem),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AccountGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountGroup(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      nature: serializer.fromJson<String>(json['nature']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'nature': serializer.toJson<String>(nature),
      'isSystem': serializer.toJson<bool>(isSystem),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  AccountGroup copyWith({
    String? id,
    String? tenantId,
    String? code,
    String? name,
    Value<String?> parentId = const Value.absent(),
    String? nature,
    bool? isSystem,
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => AccountGroup(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    code: code ?? this.code,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    nature: nature ?? this.nature,
    isSystem: isSystem ?? this.isSystem,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  AccountGroup copyWithCompanion(AccountGroupsCompanion data) {
    return AccountGroup(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      nature: data.nature.present ? data.nature.value : this.nature,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountGroup(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('nature: $nature, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    code,
    name,
    parentId,
    nature,
    isSystem,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountGroup &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.code == this.code &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.nature == this.nature &&
          other.isSystem == this.isSystem &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountGroupsCompanion extends UpdateCompanion<AccountGroup> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<String> nature;
  final Value<bool> isSystem;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const AccountGroupsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.nature = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountGroupsCompanion.insert({
    required String id,
    required String tenantId,
    required String code,
    required String name,
    this.parentId = const Value.absent(),
    required String nature,
    required bool isSystem,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       code = Value(code),
       name = Value(name),
       nature = Value(nature),
       isSystem = Value(isSystem);
  static Insertable<AccountGroup> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<String>? nature,
    Expression<bool>? isSystem,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (nature != null) 'nature': nature,
      if (isSystem != null) 'is_system': isSystem,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? parentId,
    Value<String>? nature,
    Value<bool>? isSystem,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return AccountGroupsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      code: code ?? this.code,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      nature: nature ?? this.nature,
      isSystem: isSystem ?? this.isSystem,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (nature.present) {
      map['nature'] = Variable<String>(nature.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountGroupsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('nature: $nature, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankAccountIdMeta = const VerificationMeta(
    'bankAccountId',
  );
  @override
  late final GeneratedColumn<String> bankAccountId = GeneratedColumn<String>(
    'bank_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemCodeMeta = const VerificationMeta(
    'systemCode',
  );
  @override
  late final GeneratedColumn<String> systemCode = GeneratedColumn<String>(
    'system_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    groupId,
    name,
    partyId,
    bankAccountId,
    systemCode,
    isSystem,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
        _bankAccountIdMeta,
        bankAccountId.isAcceptableOrUnknown(
          data['bank_account_id']!,
          _bankAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('system_code')) {
      context.handle(
        _systemCodeMeta,
        systemCode.isAcceptableOrUnknown(data['system_code']!, _systemCodeMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    } else if (isInserting) {
      context.missing(_isSystemMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      ),
      bankAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_account_id'],
      ),
      systemCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_code'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String tenantId;
  final String groupId;
  final String name;
  final String? partyId;
  final String? bankAccountId;
  final String? systemCode;
  final bool isSystem;
  final bool isActive;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  const Account({
    required this.id,
    required this.tenantId,
    required this.groupId,
    required this.name,
    this.partyId,
    this.bankAccountId,
    this.systemCode,
    required this.isSystem,
    required this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    if (!nullToAbsent || bankAccountId != null) {
      map['bank_account_id'] = Variable<String>(bankAccountId);
    }
    if (!nullToAbsent || systemCode != null) {
      map['system_code'] = Variable<String>(systemCode);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      groupId: Value(groupId),
      name: Value(name),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      bankAccountId: bankAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountId),
      systemCode: systemCode == null && nullToAbsent
          ? const Value.absent()
          : Value(systemCode),
      isSystem: Value(isSystem),
      isActive: Value(isActive),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      bankAccountId: serializer.fromJson<String?>(json['bankAccountId']),
      systemCode: serializer.fromJson<String?>(json['systemCode']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
      'partyId': serializer.toJson<String?>(partyId),
      'bankAccountId': serializer.toJson<String?>(bankAccountId),
      'systemCode': serializer.toJson<String?>(systemCode),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isActive': serializer.toJson<bool>(isActive),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Account copyWith({
    String? id,
    String? tenantId,
    String? groupId,
    String? name,
    Value<String?> partyId = const Value.absent(),
    Value<String?> bankAccountId = const Value.absent(),
    Value<String?> systemCode = const Value.absent(),
    bool? isSystem,
    bool? isActive,
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Account(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    groupId: groupId ?? this.groupId,
    name: name ?? this.name,
    partyId: partyId.present ? partyId.value : this.partyId,
    bankAccountId: bankAccountId.present
        ? bankAccountId.value
        : this.bankAccountId,
    systemCode: systemCode.present ? systemCode.value : this.systemCode,
    isSystem: isSystem ?? this.isSystem,
    isActive: isActive ?? this.isActive,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      systemCode: data.systemCode.present
          ? data.systemCode.value
          : this.systemCode,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('partyId: $partyId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('systemCode: $systemCode, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    groupId,
    name,
    partyId,
    bankAccountId,
    systemCode,
    isSystem,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.partyId == this.partyId &&
          other.bankAccountId == this.bankAccountId &&
          other.systemCode == this.systemCode &&
          other.isSystem == this.isSystem &&
          other.isActive == this.isActive &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> groupId;
  final Value<String> name;
  final Value<String?> partyId;
  final Value<String?> bankAccountId;
  final Value<String?> systemCode;
  final Value<bool> isSystem;
  final Value<bool> isActive;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.partyId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.systemCode = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String tenantId,
    required String groupId,
    required String name,
    this.partyId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.systemCode = const Value.absent(),
    required bool isSystem,
    required bool isActive,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       groupId = Value(groupId),
       name = Value(name),
       isSystem = Value(isSystem),
       isActive = Value(isActive);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<String>? partyId,
    Expression<String>? bankAccountId,
    Expression<String>? systemCode,
    Expression<bool>? isSystem,
    Expression<bool>? isActive,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (partyId != null) 'party_id': partyId,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (systemCode != null) 'system_code': systemCode,
      if (isSystem != null) 'is_system': isSystem,
      if (isActive != null) 'is_active': isActive,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? groupId,
    Value<String>? name,
    Value<String?>? partyId,
    Value<String?>? bankAccountId,
    Value<String?>? systemCode,
    Value<bool>? isSystem,
    Value<bool>? isActive,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      partyId: partyId ?? this.partyId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      systemCode: systemCode ?? this.systemCode,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<String>(bankAccountId.value);
    }
    if (systemCode.present) {
      map['system_code'] = Variable<String>(systemCode.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('partyId: $partyId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('systemCode: $systemCode, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voucherIdMeta = const VerificationMeta(
    'voucherId',
  );
  @override
  late final GeneratedColumn<String> voucherId = GeneratedColumn<String>(
    'voucher_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _narrationMeta = const VerificationMeta(
    'narration',
  );
  @override
  late final GeneratedColumn<String> narration = GeneratedColumn<String>(
    'narration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversesIdMeta = const VerificationMeta(
    'reversesId',
  );
  @override
  late final GeneratedColumn<String> reversesId = GeneratedColumn<String>(
    'reverses_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    sourceKey,
    sourceType,
    voucherId,
    entryDate,
    narration,
    reversesId,
    deviceId,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('voucher_id')) {
      context.handle(
        _voucherIdMeta,
        voucherId.isAcceptableOrUnknown(data['voucher_id']!, _voucherIdMeta),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('narration')) {
      context.handle(
        _narrationMeta,
        narration.isAcceptableOrUnknown(data['narration']!, _narrationMeta),
      );
    }
    if (data.containsKey('reverses_id')) {
      context.handle(
        _reversesIdMeta,
        reversesId.isAcceptableOrUnknown(data['reverses_id']!, _reversesIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      voucherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voucher_id'],
      ),
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      narration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narration'],
      ),
      reversesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final String id;
  final String tenantId;
  final String sourceKey;
  final String sourceType;
  final String? voucherId;
  final String entryDate;
  final String? narration;
  final String? reversesId;
  final String? deviceId;
  final String? createdBy;
  final String? createdAt;
  const JournalEntry({
    required this.id,
    required this.tenantId,
    required this.sourceKey,
    required this.sourceType,
    this.voucherId,
    required this.entryDate,
    this.narration,
    this.reversesId,
    this.deviceId,
    this.createdBy,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['source_key'] = Variable<String>(sourceKey);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || voucherId != null) {
      map['voucher_id'] = Variable<String>(voucherId);
    }
    map['entry_date'] = Variable<String>(entryDate);
    if (!nullToAbsent || narration != null) {
      map['narration'] = Variable<String>(narration);
    }
    if (!nullToAbsent || reversesId != null) {
      map['reverses_id'] = Variable<String>(reversesId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      sourceKey: Value(sourceKey),
      sourceType: Value(sourceType),
      voucherId: voucherId == null && nullToAbsent
          ? const Value.absent()
          : Value(voucherId),
      entryDate: Value(entryDate),
      narration: narration == null && nullToAbsent
          ? const Value.absent()
          : Value(narration),
      reversesId: reversesId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      voucherId: serializer.fromJson<String?>(json['voucherId']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      narration: serializer.fromJson<String?>(json['narration']),
      reversesId: serializer.fromJson<String?>(json['reversesId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'sourceType': serializer.toJson<String>(sourceType),
      'voucherId': serializer.toJson<String?>(voucherId),
      'entryDate': serializer.toJson<String>(entryDate),
      'narration': serializer.toJson<String?>(narration),
      'reversesId': serializer.toJson<String?>(reversesId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? tenantId,
    String? sourceKey,
    String? sourceType,
    Value<String?> voucherId = const Value.absent(),
    String? entryDate,
    Value<String?> narration = const Value.absent(),
    Value<String?> reversesId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
  }) => JournalEntry(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    sourceKey: sourceKey ?? this.sourceKey,
    sourceType: sourceType ?? this.sourceType,
    voucherId: voucherId.present ? voucherId.value : this.voucherId,
    entryDate: entryDate ?? this.entryDate,
    narration: narration.present ? narration.value : this.narration,
    reversesId: reversesId.present ? reversesId.value : this.reversesId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      voucherId: data.voucherId.present ? data.voucherId.value : this.voucherId,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      narration: data.narration.present ? data.narration.value : this.narration,
      reversesId: data.reversesId.present
          ? data.reversesId.value
          : this.reversesId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('sourceType: $sourceType, ')
          ..write('voucherId: $voucherId, ')
          ..write('entryDate: $entryDate, ')
          ..write('narration: $narration, ')
          ..write('reversesId: $reversesId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    sourceKey,
    sourceType,
    voucherId,
    entryDate,
    narration,
    reversesId,
    deviceId,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.sourceKey == this.sourceKey &&
          other.sourceType == this.sourceType &&
          other.voucherId == this.voucherId &&
          other.entryDate == this.entryDate &&
          other.narration == this.narration &&
          other.reversesId == this.reversesId &&
          other.deviceId == this.deviceId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> sourceKey;
  final Value<String> sourceType;
  final Value<String?> voucherId;
  final Value<String> entryDate;
  final Value<String?> narration;
  final Value<String?> reversesId;
  final Value<String?> deviceId;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.voucherId = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.narration = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required String tenantId,
    required String sourceKey,
    required String sourceType,
    this.voucherId = const Value.absent(),
    required String entryDate,
    this.narration = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       sourceKey = Value(sourceKey),
       sourceType = Value(sourceType),
       entryDate = Value(entryDate);
  static Insertable<JournalEntry> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? sourceKey,
    Expression<String>? sourceType,
    Expression<String>? voucherId,
    Expression<String>? entryDate,
    Expression<String>? narration,
    Expression<String>? reversesId,
    Expression<String>? deviceId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (sourceKey != null) 'source_key': sourceKey,
      if (sourceType != null) 'source_type': sourceType,
      if (voucherId != null) 'voucher_id': voucherId,
      if (entryDate != null) 'entry_date': entryDate,
      if (narration != null) 'narration': narration,
      if (reversesId != null) 'reverses_id': reversesId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? sourceKey,
    Value<String>? sourceType,
    Value<String?>? voucherId,
    Value<String>? entryDate,
    Value<String?>? narration,
    Value<String?>? reversesId,
    Value<String?>? deviceId,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      sourceKey: sourceKey ?? this.sourceKey,
      sourceType: sourceType ?? this.sourceType,
      voucherId: voucherId ?? this.voucherId,
      entryDate: entryDate ?? this.entryDate,
      narration: narration ?? this.narration,
      reversesId: reversesId ?? this.reversesId,
      deviceId: deviceId ?? this.deviceId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (voucherId.present) {
      map['voucher_id'] = Variable<String>(voucherId.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (narration.present) {
      map['narration'] = Variable<String>(narration.value);
    }
    if (reversesId.present) {
      map['reverses_id'] = Variable<String>(reversesId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('sourceType: $sourceType, ')
          ..write('voucherId: $voucherId, ')
          ..write('entryDate: $entryDate, ')
          ..write('narration: $narration, ')
          ..write('reversesId: $reversesId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalLinesTable extends JournalLines
    with TableInfo<$JournalLinesTable, JournalLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
    'line_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debitPaiseMeta = const VerificationMeta(
    'debitPaise',
  );
  @override
  late final GeneratedColumn<int> debitPaise = GeneratedColumn<int>(
    'debit_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditPaiseMeta = const VerificationMeta(
    'creditPaise',
  );
  @override
  late final GeneratedColumn<int> creditPaise = GeneratedColumn<int>(
    'credit_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    journalEntryId,
    lineNo,
    accountId,
    debitPaise,
    creditPaise,
    memo,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalEntryIdMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(
        _lineNoMeta,
        lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNoMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('debit_paise')) {
      context.handle(
        _debitPaiseMeta,
        debitPaise.isAcceptableOrUnknown(data['debit_paise']!, _debitPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_debitPaiseMeta);
    }
    if (data.containsKey('credit_paise')) {
      context.handle(
        _creditPaiseMeta,
        creditPaise.isAcceptableOrUnknown(
          data['credit_paise']!,
          _creditPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditPaiseMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      )!,
      lineNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_no'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      debitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}debit_paise'],
      )!,
      creditPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_paise'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $JournalLinesTable createAlias(String alias) {
    return $JournalLinesTable(attachedDatabase, alias);
  }
}

class JournalLine extends DataClass implements Insertable<JournalLine> {
  final String id;
  final String tenantId;
  final String journalEntryId;
  final int lineNo;
  final String accountId;
  final int debitPaise;
  final int creditPaise;
  final String? memo;
  final String? createdBy;
  final String? createdAt;
  const JournalLine({
    required this.id,
    required this.tenantId,
    required this.journalEntryId,
    required this.lineNo,
    required this.accountId,
    required this.debitPaise,
    required this.creditPaise,
    this.memo,
    this.createdBy,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['journal_entry_id'] = Variable<String>(journalEntryId);
    map['line_no'] = Variable<int>(lineNo);
    map['account_id'] = Variable<String>(accountId);
    map['debit_paise'] = Variable<int>(debitPaise);
    map['credit_paise'] = Variable<int>(creditPaise);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    return map;
  }

  JournalLinesCompanion toCompanion(bool nullToAbsent) {
    return JournalLinesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      journalEntryId: Value(journalEntryId),
      lineNo: Value(lineNo),
      accountId: Value(accountId),
      debitPaise: Value(debitPaise),
      creditPaise: Value(creditPaise),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory JournalLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalLine(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      journalEntryId: serializer.fromJson<String>(json['journalEntryId']),
      lineNo: serializer.fromJson<int>(json['lineNo']),
      accountId: serializer.fromJson<String>(json['accountId']),
      debitPaise: serializer.fromJson<int>(json['debitPaise']),
      creditPaise: serializer.fromJson<int>(json['creditPaise']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'journalEntryId': serializer.toJson<String>(journalEntryId),
      'lineNo': serializer.toJson<int>(lineNo),
      'accountId': serializer.toJson<String>(accountId),
      'debitPaise': serializer.toJson<int>(debitPaise),
      'creditPaise': serializer.toJson<int>(creditPaise),
      'memo': serializer.toJson<String?>(memo),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String?>(createdAt),
    };
  }

  JournalLine copyWith({
    String? id,
    String? tenantId,
    String? journalEntryId,
    int? lineNo,
    String? accountId,
    int? debitPaise,
    int? creditPaise,
    Value<String?> memo = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
  }) => JournalLine(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    journalEntryId: journalEntryId ?? this.journalEntryId,
    lineNo: lineNo ?? this.lineNo,
    accountId: accountId ?? this.accountId,
    debitPaise: debitPaise ?? this.debitPaise,
    creditPaise: creditPaise ?? this.creditPaise,
    memo: memo.present ? memo.value : this.memo,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  JournalLine copyWithCompanion(JournalLinesCompanion data) {
    return JournalLine(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      debitPaise: data.debitPaise.present
          ? data.debitPaise.value
          : this.debitPaise,
      creditPaise: data.creditPaise.present
          ? data.creditPaise.value
          : this.creditPaise,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalLine(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('lineNo: $lineNo, ')
          ..write('accountId: $accountId, ')
          ..write('debitPaise: $debitPaise, ')
          ..write('creditPaise: $creditPaise, ')
          ..write('memo: $memo, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    journalEntryId,
    lineNo,
    accountId,
    debitPaise,
    creditPaise,
    memo,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalLine &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.journalEntryId == this.journalEntryId &&
          other.lineNo == this.lineNo &&
          other.accountId == this.accountId &&
          other.debitPaise == this.debitPaise &&
          other.creditPaise == this.creditPaise &&
          other.memo == this.memo &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class JournalLinesCompanion extends UpdateCompanion<JournalLine> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> journalEntryId;
  final Value<int> lineNo;
  final Value<String> accountId;
  final Value<int> debitPaise;
  final Value<int> creditPaise;
  final Value<String?> memo;
  final Value<String?> createdBy;
  final Value<String?> createdAt;
  final Value<int> rowid;
  const JournalLinesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.accountId = const Value.absent(),
    this.debitPaise = const Value.absent(),
    this.creditPaise = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalLinesCompanion.insert({
    required String id,
    required String tenantId,
    required String journalEntryId,
    required int lineNo,
    required String accountId,
    required int debitPaise,
    required int creditPaise,
    this.memo = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       journalEntryId = Value(journalEntryId),
       lineNo = Value(lineNo),
       accountId = Value(accountId),
       debitPaise = Value(debitPaise),
       creditPaise = Value(creditPaise);
  static Insertable<JournalLine> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? journalEntryId,
    Expression<int>? lineNo,
    Expression<String>? accountId,
    Expression<int>? debitPaise,
    Expression<int>? creditPaise,
    Expression<String>? memo,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (lineNo != null) 'line_no': lineNo,
      if (accountId != null) 'account_id': accountId,
      if (debitPaise != null) 'debit_paise': debitPaise,
      if (creditPaise != null) 'credit_paise': creditPaise,
      if (memo != null) 'memo': memo,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? journalEntryId,
    Value<int>? lineNo,
    Value<String>? accountId,
    Value<int>? debitPaise,
    Value<int>? creditPaise,
    Value<String?>? memo,
    Value<String?>? createdBy,
    Value<String?>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalLinesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      lineNo: lineNo ?? this.lineNo,
      accountId: accountId ?? this.accountId,
      debitPaise: debitPaise ?? this.debitPaise,
      creditPaise: creditPaise ?? this.creditPaise,
      memo: memo ?? this.memo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (debitPaise.present) {
      map['debit_paise'] = Variable<int>(debitPaise.value);
    }
    if (creditPaise.present) {
      map['credit_paise'] = Variable<int>(creditPaise.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalLinesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('lineNo: $lineNo, ')
          ..write('accountId: $accountId, ')
          ..write('debitPaise: $debitPaise, ')
          ..write('creditPaise: $creditPaise, ')
          ..write('memo: $memo, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncErrorsTable extends SyncErrors
    with TableInfo<$SyncErrorsTable, SyncError> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncErrorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableNameValueMeta = const VerificationMeta(
    'tableNameValue',
  );
  @override
  late final GeneratedColumn<String> tableNameValue = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opDataMeta = const VerificationMeta('opData');
  @override
  late final GeneratedColumn<String> opData = GeneratedColumn<String>(
    'op_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchSeqMeta = const VerificationMeta(
    'batchSeq',
  );
  @override
  late final GeneratedColumn<int> batchSeq = GeneratedColumn<int>(
    'batch_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tableNameValue,
    rowId,
    op,
    opData,
    errorCode,
    message,
    createdAt,
    batchId,
    batchSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_errors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncError> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _tableNameValueMeta,
        tableNameValue.isAcceptableOrUnknown(
          data['table_name']!,
          _tableNameValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tableNameValueMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('op_data')) {
      context.handle(
        _opDataMeta,
        opData.isAcceptableOrUnknown(data['op_data']!, _opDataMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('batch_seq')) {
      context.handle(
        _batchSeqMeta,
        batchSeq.isAcceptableOrUnknown(data['batch_seq']!, _batchSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncError map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncError(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tableNameValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      opData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_data'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      batchSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_seq'],
      ),
    );
  }

  @override
  $SyncErrorsTable createAlias(String alias) {
    return $SyncErrorsTable(attachedDatabase, alias);
  }
}

class SyncError extends DataClass implements Insertable<SyncError> {
  final String id;
  final String tableNameValue;
  final String rowId;
  final String op;
  final String? opData;
  final String? errorCode;
  final String message;
  final String createdAt;
  final String? batchId;
  final int? batchSeq;
  const SyncError({
    required this.id,
    required this.tableNameValue,
    required this.rowId,
    required this.op,
    this.opData,
    this.errorCode,
    required this.message,
    required this.createdAt,
    this.batchId,
    this.batchSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(tableNameValue);
    map['row_id'] = Variable<String>(rowId);
    map['op'] = Variable<String>(op);
    if (!nullToAbsent || opData != null) {
      map['op_data'] = Variable<String>(opData);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || batchSeq != null) {
      map['batch_seq'] = Variable<int>(batchSeq);
    }
    return map;
  }

  SyncErrorsCompanion toCompanion(bool nullToAbsent) {
    return SyncErrorsCompanion(
      id: Value(id),
      tableNameValue: Value(tableNameValue),
      rowId: Value(rowId),
      op: Value(op),
      opData: opData == null && nullToAbsent
          ? const Value.absent()
          : Value(opData),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      message: Value(message),
      createdAt: Value(createdAt),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      batchSeq: batchSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(batchSeq),
    );
  }

  factory SyncError.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncError(
      id: serializer.fromJson<String>(json['id']),
      tableNameValue: serializer.fromJson<String>(json['tableNameValue']),
      rowId: serializer.fromJson<String>(json['rowId']),
      op: serializer.fromJson<String>(json['op']),
      opData: serializer.fromJson<String?>(json['opData']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      batchSeq: serializer.fromJson<int?>(json['batchSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tableNameValue': serializer.toJson<String>(tableNameValue),
      'rowId': serializer.toJson<String>(rowId),
      'op': serializer.toJson<String>(op),
      'opData': serializer.toJson<String?>(opData),
      'errorCode': serializer.toJson<String?>(errorCode),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<String>(createdAt),
      'batchId': serializer.toJson<String?>(batchId),
      'batchSeq': serializer.toJson<int?>(batchSeq),
    };
  }

  SyncError copyWith({
    String? id,
    String? tableNameValue,
    String? rowId,
    String? op,
    Value<String?> opData = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
    String? message,
    String? createdAt,
    Value<String?> batchId = const Value.absent(),
    Value<int?> batchSeq = const Value.absent(),
  }) => SyncError(
    id: id ?? this.id,
    tableNameValue: tableNameValue ?? this.tableNameValue,
    rowId: rowId ?? this.rowId,
    op: op ?? this.op,
    opData: opData.present ? opData.value : this.opData,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
    batchId: batchId.present ? batchId.value : this.batchId,
    batchSeq: batchSeq.present ? batchSeq.value : this.batchSeq,
  );
  SyncError copyWithCompanion(SyncErrorsCompanion data) {
    return SyncError(
      id: data.id.present ? data.id.value : this.id,
      tableNameValue: data.tableNameValue.present
          ? data.tableNameValue.value
          : this.tableNameValue,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      op: data.op.present ? data.op.value : this.op,
      opData: data.opData.present ? data.opData.value : this.opData,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      batchSeq: data.batchSeq.present ? data.batchSeq.value : this.batchSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncError(')
          ..write('id: $id, ')
          ..write('tableNameValue: $tableNameValue, ')
          ..write('rowId: $rowId, ')
          ..write('op: $op, ')
          ..write('opData: $opData, ')
          ..write('errorCode: $errorCode, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt, ')
          ..write('batchId: $batchId, ')
          ..write('batchSeq: $batchSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tableNameValue,
    rowId,
    op,
    opData,
    errorCode,
    message,
    createdAt,
    batchId,
    batchSeq,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncError &&
          other.id == this.id &&
          other.tableNameValue == this.tableNameValue &&
          other.rowId == this.rowId &&
          other.op == this.op &&
          other.opData == this.opData &&
          other.errorCode == this.errorCode &&
          other.message == this.message &&
          other.createdAt == this.createdAt &&
          other.batchId == this.batchId &&
          other.batchSeq == this.batchSeq);
}

class SyncErrorsCompanion extends UpdateCompanion<SyncError> {
  final Value<String> id;
  final Value<String> tableNameValue;
  final Value<String> rowId;
  final Value<String> op;
  final Value<String?> opData;
  final Value<String?> errorCode;
  final Value<String> message;
  final Value<String> createdAt;
  final Value<String?> batchId;
  final Value<int?> batchSeq;
  final Value<int> rowid;
  const SyncErrorsCompanion({
    this.id = const Value.absent(),
    this.tableNameValue = const Value.absent(),
    this.rowId = const Value.absent(),
    this.op = const Value.absent(),
    this.opData = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.batchId = const Value.absent(),
    this.batchSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncErrorsCompanion.insert({
    required String id,
    required String tableNameValue,
    required String rowId,
    required String op,
    this.opData = const Value.absent(),
    this.errorCode = const Value.absent(),
    required String message,
    required String createdAt,
    this.batchId = const Value.absent(),
    this.batchSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tableNameValue = Value(tableNameValue),
       rowId = Value(rowId),
       op = Value(op),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<SyncError> custom({
    Expression<String>? id,
    Expression<String>? tableNameValue,
    Expression<String>? rowId,
    Expression<String>? op,
    Expression<String>? opData,
    Expression<String>? errorCode,
    Expression<String>? message,
    Expression<String>? createdAt,
    Expression<String>? batchId,
    Expression<int>? batchSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableNameValue != null) 'table_name': tableNameValue,
      if (rowId != null) 'row_id': rowId,
      if (op != null) 'op': op,
      if (opData != null) 'op_data': opData,
      if (errorCode != null) 'error_code': errorCode,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
      if (batchId != null) 'batch_id': batchId,
      if (batchSeq != null) 'batch_seq': batchSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncErrorsCompanion copyWith({
    Value<String>? id,
    Value<String>? tableNameValue,
    Value<String>? rowId,
    Value<String>? op,
    Value<String?>? opData,
    Value<String?>? errorCode,
    Value<String>? message,
    Value<String>? createdAt,
    Value<String?>? batchId,
    Value<int?>? batchSeq,
    Value<int>? rowid,
  }) {
    return SyncErrorsCompanion(
      id: id ?? this.id,
      tableNameValue: tableNameValue ?? this.tableNameValue,
      rowId: rowId ?? this.rowId,
      op: op ?? this.op,
      opData: opData ?? this.opData,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      batchId: batchId ?? this.batchId,
      batchSeq: batchSeq ?? this.batchSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tableNameValue.present) {
      map['table_name'] = Variable<String>(tableNameValue.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (opData.present) {
      map['op_data'] = Variable<String>(opData.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (batchSeq.present) {
      map['batch_seq'] = Variable<int>(batchSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncErrorsCompanion(')
          ..write('id: $id, ')
          ..write('tableNameValue: $tableNameValue, ')
          ..write('rowId: $rowId, ')
          ..write('op: $op, ')
          ..write('opData: $opData, ')
          ..write('errorCode: $errorCode, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt, ')
          ..write('batchId: $batchId, ')
          ..write('batchSeq: $batchSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TenantsTable tenants = $TenantsTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $TenantMembersTable tenantMembers = $TenantMembersTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $MemberInvitesTable memberInvites = $MemberInvitesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $PartyRolesTable partyRoles = $PartyRolesTable(this);
  late final $NumberSeriesTable numberSeries = $NumberSeriesTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $CropsTable crops = $CropsTable(this);
  late final $LotsTable lots = $LotsTable(this);
  late final $BankAccountsTable bankAccounts = $BankAccountsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $CashBankEntriesTable cashBankEntries = $CashBankEntriesTable(
    this,
  );
  late final $LoansTable loans = $LoansTable(this);
  late final $LoanRateChangesTable loanRateChanges = $LoanRateChangesTable(
    this,
  );
  late final $InterestPostingsTable interestPostings = $InterestPostingsTable(
    this,
  );
  late final $AccountGroupsTable accountGroups = $AccountGroupsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $JournalLinesTable journalLines = $JournalLinesTable(this);
  late final $SyncErrorsTable syncErrors = $SyncErrorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tenants,
    appUsers,
    tenantMembers,
    devices,
    memberInvites,
    settings,
    auditLog,
    parties,
    partyRoles,
    numberSeries,
    ledgerEntries,
    crops,
    lots,
    bankAccounts,
    payments,
    cashBankEntries,
    loans,
    loanRateChanges,
    interestPostings,
    accountGroups,
    accounts,
    journalEntries,
    journalLines,
    syncErrors,
  ];
}

typedef $$TenantsTableCreateCompanionBuilder =
    TenantsCompanion Function({
      required String id,
      required String name,
      Value<String?> legalName,
      Value<String?> gstin,
      Value<String?> address,
      Value<String?> stateCode,
      Value<String?> mandiName,
      Value<String?> phone,
      Value<String?> planCode,
      Value<String?> status,
      Value<String?> trialEndsAt,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$TenantsTableUpdateCompanionBuilder =
    TenantsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> legalName,
      Value<String?> gstin,
      Value<String?> address,
      Value<String?> stateCode,
      Value<String?> mandiName,
      Value<String?> phone,
      Value<String?> planCode,
      Value<String?> status,
      Value<String?> trialEndsAt,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$TenantsTableFilterComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mandiName => $composableBuilder(
    column: $table.mandiName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planCode => $composableBuilder(
    column: $table.planCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trialEndsAt => $composableBuilder(
    column: $table.trialEndsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TenantsTableOrderingComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mandiName => $composableBuilder(
    column: $table.mandiName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planCode => $composableBuilder(
    column: $table.planCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trialEndsAt => $composableBuilder(
    column: $table.trialEndsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TenantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get legalName =>
      $composableBuilder(column: $table.legalName, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get mandiName =>
      $composableBuilder(column: $table.mandiName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get planCode =>
      $composableBuilder(column: $table.planCode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get trialEndsAt => $composableBuilder(
    column: $table.trialEndsAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TenantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TenantsTable,
          Tenant,
          $$TenantsTableFilterComposer,
          $$TenantsTableOrderingComposer,
          $$TenantsTableAnnotationComposer,
          $$TenantsTableCreateCompanionBuilder,
          $$TenantsTableUpdateCompanionBuilder,
          (Tenant, BaseReferences<_$AppDatabase, $TenantsTable, Tenant>),
          Tenant,
          PrefetchHooks Function()
        > {
  $$TenantsTableTableManager(_$AppDatabase db, $TenantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TenantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TenantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TenantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> legalName = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String?> mandiName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> planCode = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> trialEndsAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TenantsCompanion(
                id: id,
                name: name,
                legalName: legalName,
                gstin: gstin,
                address: address,
                stateCode: stateCode,
                mandiName: mandiName,
                phone: phone,
                planCode: planCode,
                status: status,
                trialEndsAt: trialEndsAt,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> legalName = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String?> mandiName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> planCode = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> trialEndsAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TenantsCompanion.insert(
                id: id,
                name: name,
                legalName: legalName,
                gstin: gstin,
                address: address,
                stateCode: stateCode,
                mandiName: mandiName,
                phone: phone,
                planCode: planCode,
                status: status,
                trialEndsAt: trialEndsAt,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TenantsTable, Tenant>(table),
                  BaseReferences<_$AppDatabase, $TenantsTable, Tenant>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TenantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TenantsTable,
      Tenant,
      $$TenantsTableFilterComposer,
      $$TenantsTableOrderingComposer,
      $$TenantsTableAnnotationComposer,
      $$TenantsTableCreateCompanionBuilder,
      $$TenantsTableUpdateCompanionBuilder,
      (Tenant, BaseReferences<_$AppDatabase, $TenantsTable, Tenant>),
      Tenant,
      PrefetchHooks Function()
    >;
typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      required String id,
      Value<String?> phone,
      Value<String?> fullName,
      Value<String?> preferredLanguage,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<String> id,
      Value<String?> phone,
      Value<String?> fullName,
      Value<String?> preferredLanguage,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUser,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
          AppUser,
          PrefetchHooks Function()
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> preferredLanguage = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion(
                id: id,
                phone: phone,
                fullName: fullName,
                preferredLanguage: preferredLanguage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> phone = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> preferredLanguage = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion.insert(
                id: id,
                phone: phone,
                fullName: fullName,
                preferredLanguage: preferredLanguage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppUsersTable, AppUser>(table),
                  BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUser,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
      AppUser,
      PrefetchHooks Function()
    >;
typedef $$TenantMembersTableCreateCompanionBuilder =
    TenantMembersCompanion Function({
      required String id,
      required String tenantId,
      required String userId,
      required String role,
      Value<String?> customPermissions,
      Value<bool?> isActive,
      Value<int?> deviceLimit,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$TenantMembersTableUpdateCompanionBuilder =
    TenantMembersCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> userId,
      Value<String> role,
      Value<String?> customPermissions,
      Value<bool?> isActive,
      Value<int?> deviceLimit,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$TenantMembersTableFilterComposer
    extends Composer<_$AppDatabase, $TenantMembersTable> {
  $$TenantMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TenantMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $TenantMembersTable> {
  $$TenantMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TenantMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TenantMembersTable> {
  $$TenantMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TenantMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TenantMembersTable,
          TenantMember,
          $$TenantMembersTableFilterComposer,
          $$TenantMembersTableOrderingComposer,
          $$TenantMembersTableAnnotationComposer,
          $$TenantMembersTableCreateCompanionBuilder,
          $$TenantMembersTableUpdateCompanionBuilder,
          (
            TenantMember,
            BaseReferences<_$AppDatabase, $TenantMembersTable, TenantMember>,
          ),
          TenantMember,
          PrefetchHooks Function()
        > {
  $$TenantMembersTableTableManager(_$AppDatabase db, $TenantMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TenantMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TenantMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TenantMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> customPermissions = const Value.absent(),
                Value<bool?> isActive = const Value.absent(),
                Value<int?> deviceLimit = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TenantMembersCompanion(
                id: id,
                tenantId: tenantId,
                userId: userId,
                role: role,
                customPermissions: customPermissions,
                isActive: isActive,
                deviceLimit: deviceLimit,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String userId,
                required String role,
                Value<String?> customPermissions = const Value.absent(),
                Value<bool?> isActive = const Value.absent(),
                Value<int?> deviceLimit = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TenantMembersCompanion.insert(
                id: id,
                tenantId: tenantId,
                userId: userId,
                role: role,
                customPermissions: customPermissions,
                isActive: isActive,
                deviceLimit: deviceLimit,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TenantMembersTable, TenantMember>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TenantMembersTable,
                    TenantMember
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TenantMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TenantMembersTable,
      TenantMember,
      $$TenantMembersTableFilterComposer,
      $$TenantMembersTableOrderingComposer,
      $$TenantMembersTableAnnotationComposer,
      $$TenantMembersTableCreateCompanionBuilder,
      $$TenantMembersTableUpdateCompanionBuilder,
      (
        TenantMember,
        BaseReferences<_$AppDatabase, $TenantMembersTable, TenantMember>,
      ),
      TenantMember,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      required String tenantId,
      required String userId,
      required String deviceCode,
      required String platform,
      Value<String?> name,
      Value<String?> lastSeenAt,
      Value<String?> revokedAt,
      Value<String?> revokedBy,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> userId,
      Value<String> deviceCode,
      Value<String> platform,
      Value<String?> name,
      Value<String?> lastSeenAt,
      Value<String?> revokedAt,
      Value<String?> revokedBy,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revokedBy => $composableBuilder(
    column: $table.revokedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revokedBy => $composableBuilder(
    column: $table.revokedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  GeneratedColumn<String> get revokedBy =>
      $composableBuilder(column: $table.revokedBy, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> deviceCode = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> lastSeenAt = const Value.absent(),
                Value<String?> revokedAt = const Value.absent(),
                Value<String?> revokedBy = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                tenantId: tenantId,
                userId: userId,
                deviceCode: deviceCode,
                platform: platform,
                name: name,
                lastSeenAt: lastSeenAt,
                revokedAt: revokedAt,
                revokedBy: revokedBy,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String userId,
                required String deviceCode,
                required String platform,
                Value<String?> name = const Value.absent(),
                Value<String?> lastSeenAt = const Value.absent(),
                Value<String?> revokedAt = const Value.absent(),
                Value<String?> revokedBy = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                tenantId: tenantId,
                userId: userId,
                deviceCode: deviceCode,
                platform: platform,
                name: name,
                lastSeenAt: lastSeenAt,
                revokedAt: revokedAt,
                revokedBy: revokedBy,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicesTable, Device>(table),
                  BaseReferences<_$AppDatabase, $DevicesTable, Device>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$MemberInvitesTableCreateCompanionBuilder =
    MemberInvitesCompanion Function({
      required String id,
      required String tenantId,
      required String phone,
      Value<String?> fullName,
      required String role,
      Value<String?> customPermissions,
      required String status,
      Value<String?> expiresAt,
      Value<String?> acceptedBy,
      Value<String?> acceptedAt,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$MemberInvitesTableUpdateCompanionBuilder =
    MemberInvitesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> phone,
      Value<String?> fullName,
      Value<String> role,
      Value<String?> customPermissions,
      Value<String> status,
      Value<String?> expiresAt,
      Value<String?> acceptedBy,
      Value<String?> acceptedAt,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$MemberInvitesTableFilterComposer
    extends Composer<_$AppDatabase, $MemberInvitesTable> {
  $$MemberInvitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acceptedBy => $composableBuilder(
    column: $table.acceptedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemberInvitesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemberInvitesTable> {
  $$MemberInvitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acceptedBy => $composableBuilder(
    column: $table.acceptedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemberInvitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemberInvitesTable> {
  $$MemberInvitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get acceptedBy => $composableBuilder(
    column: $table.acceptedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MemberInvitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemberInvitesTable,
          MemberInvite,
          $$MemberInvitesTableFilterComposer,
          $$MemberInvitesTableOrderingComposer,
          $$MemberInvitesTableAnnotationComposer,
          $$MemberInvitesTableCreateCompanionBuilder,
          $$MemberInvitesTableUpdateCompanionBuilder,
          (
            MemberInvite,
            BaseReferences<_$AppDatabase, $MemberInvitesTable, MemberInvite>,
          ),
          MemberInvite,
          PrefetchHooks Function()
        > {
  $$MemberInvitesTableTableManager(_$AppDatabase db, $MemberInvitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemberInvitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemberInvitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemberInvitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> customPermissions = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> expiresAt = const Value.absent(),
                Value<String?> acceptedBy = const Value.absent(),
                Value<String?> acceptedAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberInvitesCompanion(
                id: id,
                tenantId: tenantId,
                phone: phone,
                fullName: fullName,
                role: role,
                customPermissions: customPermissions,
                status: status,
                expiresAt: expiresAt,
                acceptedBy: acceptedBy,
                acceptedAt: acceptedAt,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String phone,
                Value<String?> fullName = const Value.absent(),
                required String role,
                Value<String?> customPermissions = const Value.absent(),
                required String status,
                Value<String?> expiresAt = const Value.absent(),
                Value<String?> acceptedBy = const Value.absent(),
                Value<String?> acceptedAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberInvitesCompanion.insert(
                id: id,
                tenantId: tenantId,
                phone: phone,
                fullName: fullName,
                role: role,
                customPermissions: customPermissions,
                status: status,
                expiresAt: expiresAt,
                acceptedBy: acceptedBy,
                acceptedAt: acceptedAt,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemberInvitesTable, MemberInvite>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MemberInvitesTable,
                    MemberInvite
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemberInvitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemberInvitesTable,
      MemberInvite,
      $$MemberInvitesTableFilterComposer,
      $$MemberInvitesTableOrderingComposer,
      $$MemberInvitesTableAnnotationComposer,
      $$MemberInvitesTableCreateCompanionBuilder,
      $$MemberInvitesTableUpdateCompanionBuilder,
      (
        MemberInvite,
        BaseReferences<_$AppDatabase, $MemberInvitesTable, MemberInvite>,
      ),
      MemberInvite,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String id,
      required String tenantId,
      required String scope,
      Value<String?> scopeId,
      required String key,
      Value<String?> value,
      Value<String?> updatedBy,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> scope,
      Value<String?> scopeId,
      Value<String> key,
      Value<String?> value,
      Value<String?> updatedBy,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String?> scopeId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                tenantId: tenantId,
                scope: scope,
                scopeId: scopeId,
                key: key,
                value: value,
                updatedBy: updatedBy,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String scope,
                Value<String?> scopeId = const Value.absent(),
                required String key,
                Value<String?> value = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                tenantId: tenantId,
                scope: scope,
                scopeId: scopeId,
                key: key,
                value: value,
                updatedBy: updatedBy,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$AuditLogTableCreateCompanionBuilder =
    AuditLogCompanion Function({
      required String id,
      required String tenantId,
      required String tableNameValue,
      required String rowId,
      required String action,
      Value<String?> before,
      Value<String?> after,
      required String userId,
      Value<String?> deviceId,
      Value<String?> role,
      Value<String?> createdAt,
      Value<int> rowid,
    });
typedef $$AuditLogTableUpdateCompanionBuilder =
    AuditLogCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> tableNameValue,
      Value<String> rowId,
      Value<String> action,
      Value<String?> before,
      Value<String?> after,
      Value<String> userId,
      Value<String?> deviceId,
      Value<String?> role,
      Value<String?> createdAt,
      Value<int> rowid,
    });

class $$AuditLogTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableNameValue => $composableBuilder(
    column: $table.tableNameValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get before => $composableBuilder(
    column: $table.before,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get after => $composableBuilder(
    column: $table.after,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableNameValue => $composableBuilder(
    column: $table.tableNameValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get before => $composableBuilder(
    column: $table.before,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get after => $composableBuilder(
    column: $table.after,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get tableNameValue => $composableBuilder(
    column: $table.tableNameValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get before =>
      $composableBuilder(column: $table.before, builder: (column) => column);

  GeneratedColumn<String> get after =>
      $composableBuilder(column: $table.after, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogTable,
          AuditEntry,
          $$AuditLogTableFilterComposer,
          $$AuditLogTableOrderingComposer,
          $$AuditLogTableAnnotationComposer,
          $$AuditLogTableCreateCompanionBuilder,
          $$AuditLogTableUpdateCompanionBuilder,
          (
            AuditEntry,
            BaseReferences<_$AppDatabase, $AuditLogTable, AuditEntry>,
          ),
          AuditEntry,
          PrefetchHooks Function()
        > {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> tableNameValue = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> before = const Value.absent(),
                Value<String?> after = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                tenantId: tenantId,
                tableNameValue: tableNameValue,
                rowId: rowId,
                action: action,
                before: before,
                after: after,
                userId: userId,
                deviceId: deviceId,
                role: role,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String tableNameValue,
                required String rowId,
                required String action,
                Value<String?> before = const Value.absent(),
                Value<String?> after = const Value.absent(),
                required String userId,
                Value<String?> deviceId = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                tenantId: tenantId,
                tableNameValue: tableNameValue,
                rowId: rowId,
                action: action,
                before: before,
                after: after,
                userId: userId,
                deviceId: deviceId,
                role: role,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogTable, AuditEntry>(table),
                  BaseReferences<_$AppDatabase, $AuditLogTable, AuditEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogTable,
      AuditEntry,
      $$AuditLogTableFilterComposer,
      $$AuditLogTableOrderingComposer,
      $$AuditLogTableAnnotationComposer,
      $$AuditLogTableCreateCompanionBuilder,
      $$AuditLogTableUpdateCompanionBuilder,
      (AuditEntry, BaseReferences<_$AppDatabase, $AuditLogTable, AuditEntry>),
      AuditEntry,
      PrefetchHooks Function()
    >;
typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      required String id,
      required String tenantId,
      required String code,
      required String name,
      Value<String?> fatherOrHusbandName,
      Value<String?> relation,
      Value<String?> village,
      Value<String?> district,
      Value<String?> state,
      Value<String?> mobile,
      Value<String?> altMobile,
      Value<String?> aadhaarLast4,
      Value<String?> bankName,
      Value<String?> bankAccountMasked,
      Value<String?> ifsc,
      Value<String?> gstin,
      Value<String?> notes,
      Value<String?> partyGroupId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<String?> deletedAt,
      Value<int> rowid,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> code,
      Value<String> name,
      Value<String?> fatherOrHusbandName,
      Value<String?> relation,
      Value<String?> village,
      Value<String?> district,
      Value<String?> state,
      Value<String?> mobile,
      Value<String?> altMobile,
      Value<String?> aadhaarLast4,
      Value<String?> bankName,
      Value<String?> bankAccountMasked,
      Value<String?> ifsc,
      Value<String?> gstin,
      Value<String?> notes,
      Value<String?> partyGroupId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<String?> deletedAt,
      Value<int> rowid,
    });

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherOrHusbandName => $composableBuilder(
    column: $table.fatherOrHusbandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altMobile => $composableBuilder(
    column: $table.altMobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aadhaarLast4 => $composableBuilder(
    column: $table.aadhaarLast4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankAccountMasked => $composableBuilder(
    column: $table.bankAccountMasked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ifsc => $composableBuilder(
    column: $table.ifsc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyGroupId => $composableBuilder(
    column: $table.partyGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherOrHusbandName => $composableBuilder(
    column: $table.fatherOrHusbandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altMobile => $composableBuilder(
    column: $table.altMobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aadhaarLast4 => $composableBuilder(
    column: $table.aadhaarLast4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankAccountMasked => $composableBuilder(
    column: $table.bankAccountMasked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ifsc => $composableBuilder(
    column: $table.ifsc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyGroupId => $composableBuilder(
    column: $table.partyGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fatherOrHusbandName => $composableBuilder(
    column: $table.fatherOrHusbandName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<String> get altMobile =>
      $composableBuilder(column: $table.altMobile, builder: (column) => column);

  GeneratedColumn<String> get aadhaarLast4 => $composableBuilder(
    column: $table.aadhaarLast4,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get bankAccountMasked => $composableBuilder(
    column: $table.bankAccountMasked,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ifsc =>
      $composableBuilder(column: $table.ifsc, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get partyGroupId => $composableBuilder(
    column: $table.partyGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, BaseReferences<_$AppDatabase, $PartiesTable, Party>),
          Party,
          PrefetchHooks Function()
        > {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> fatherOrHusbandName = const Value.absent(),
                Value<String?> relation = const Value.absent(),
                Value<String?> village = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> altMobile = const Value.absent(),
                Value<String?> aadhaarLast4 = const Value.absent(),
                Value<String?> bankName = const Value.absent(),
                Value<String?> bankAccountMasked = const Value.absent(),
                Value<String?> ifsc = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> partyGroupId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                tenantId: tenantId,
                code: code,
                name: name,
                fatherOrHusbandName: fatherOrHusbandName,
                relation: relation,
                village: village,
                district: district,
                state: state,
                mobile: mobile,
                altMobile: altMobile,
                aadhaarLast4: aadhaarLast4,
                bankName: bankName,
                bankAccountMasked: bankAccountMasked,
                ifsc: ifsc,
                gstin: gstin,
                notes: notes,
                partyGroupId: partyGroupId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String code,
                required String name,
                Value<String?> fatherOrHusbandName = const Value.absent(),
                Value<String?> relation = const Value.absent(),
                Value<String?> village = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> altMobile = const Value.absent(),
                Value<String?> aadhaarLast4 = const Value.absent(),
                Value<String?> bankName = const Value.absent(),
                Value<String?> bankAccountMasked = const Value.absent(),
                Value<String?> ifsc = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> partyGroupId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                tenantId: tenantId,
                code: code,
                name: name,
                fatherOrHusbandName: fatherOrHusbandName,
                relation: relation,
                village: village,
                district: district,
                state: state,
                mobile: mobile,
                altMobile: altMobile,
                aadhaarLast4: aadhaarLast4,
                bankName: bankName,
                bankAccountMasked: bankAccountMasked,
                ifsc: ifsc,
                gstin: gstin,
                notes: notes,
                partyGroupId: partyGroupId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PartiesTable, Party>(table),
                  BaseReferences<_$AppDatabase, $PartiesTable, Party>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, BaseReferences<_$AppDatabase, $PartiesTable, Party>),
      Party,
      PrefetchHooks Function()
    >;
typedef $$PartyRolesTableCreateCompanionBuilder =
    PartyRolesCompanion Function({
      required String id,
      required String tenantId,
      required String partyId,
      required String role,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<String?> deletedAt,
      Value<int> rowid,
    });
typedef $$PartyRolesTableUpdateCompanionBuilder =
    PartyRolesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> partyId,
      Value<String> role,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<String?> deletedAt,
      Value<int> rowid,
    });

class $$PartyRolesTableFilterComposer
    extends Composer<_$AppDatabase, $PartyRolesTable> {
  $$PartyRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartyRolesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartyRolesTable> {
  $$PartyRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartyRolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartyRolesTable> {
  $$PartyRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PartyRolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartyRolesTable,
          PartyRole,
          $$PartyRolesTableFilterComposer,
          $$PartyRolesTableOrderingComposer,
          $$PartyRolesTableAnnotationComposer,
          $$PartyRolesTableCreateCompanionBuilder,
          $$PartyRolesTableUpdateCompanionBuilder,
          (
            PartyRole,
            BaseReferences<_$AppDatabase, $PartyRolesTable, PartyRole>,
          ),
          PartyRole,
          PrefetchHooks Function()
        > {
  $$PartyRolesTableTableManager(_$AppDatabase db, $PartyRolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartyRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartyRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartyRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartyRolesCompanion(
                id: id,
                tenantId: tenantId,
                partyId: partyId,
                role: role,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String partyId,
                required String role,
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartyRolesCompanion.insert(
                id: id,
                tenantId: tenantId,
                partyId: partyId,
                role: role,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PartyRolesTable, PartyRole>(table),
                  BaseReferences<_$AppDatabase, $PartyRolesTable, PartyRole>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartyRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartyRolesTable,
      PartyRole,
      $$PartyRolesTableFilterComposer,
      $$PartyRolesTableOrderingComposer,
      $$PartyRolesTableAnnotationComposer,
      $$PartyRolesTableCreateCompanionBuilder,
      $$PartyRolesTableUpdateCompanionBuilder,
      (PartyRole, BaseReferences<_$AppDatabase, $PartyRolesTable, PartyRole>),
      PartyRole,
      PrefetchHooks Function()
    >;
typedef $$NumberSeriesTableCreateCompanionBuilder =
    NumberSeriesCompanion Function({
      required String id,
      required String tenantId,
      required String series,
      required String deviceCode,
      required int nextValue,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$NumberSeriesTableUpdateCompanionBuilder =
    NumberSeriesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> series,
      Value<String> deviceCode,
      Value<int> nextValue,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$NumberSeriesTableFilterComposer
    extends Composer<_$AppDatabase, $NumberSeriesTable> {
  $$NumberSeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextValue => $composableBuilder(
    column: $table.nextValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NumberSeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $NumberSeriesTable> {
  $$NumberSeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextValue => $composableBuilder(
    column: $table.nextValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NumberSeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NumberSeriesTable> {
  $$NumberSeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get series =>
      $composableBuilder(column: $table.series, builder: (column) => column);

  GeneratedColumn<String> get deviceCode => $composableBuilder(
    column: $table.deviceCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextValue =>
      $composableBuilder(column: $table.nextValue, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NumberSeriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NumberSeriesTable,
          NumberSeriesRow,
          $$NumberSeriesTableFilterComposer,
          $$NumberSeriesTableOrderingComposer,
          $$NumberSeriesTableAnnotationComposer,
          $$NumberSeriesTableCreateCompanionBuilder,
          $$NumberSeriesTableUpdateCompanionBuilder,
          (
            NumberSeriesRow,
            BaseReferences<_$AppDatabase, $NumberSeriesTable, NumberSeriesRow>,
          ),
          NumberSeriesRow,
          PrefetchHooks Function()
        > {
  $$NumberSeriesTableTableManager(_$AppDatabase db, $NumberSeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NumberSeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NumberSeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NumberSeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> series = const Value.absent(),
                Value<String> deviceCode = const Value.absent(),
                Value<int> nextValue = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NumberSeriesCompanion(
                id: id,
                tenantId: tenantId,
                series: series,
                deviceCode: deviceCode,
                nextValue: nextValue,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String series,
                required String deviceCode,
                required int nextValue,
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NumberSeriesCompanion.insert(
                id: id,
                tenantId: tenantId,
                series: series,
                deviceCode: deviceCode,
                nextValue: nextValue,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NumberSeriesTable, NumberSeriesRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NumberSeriesTable,
                    NumberSeriesRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NumberSeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NumberSeriesTable,
      NumberSeriesRow,
      $$NumberSeriesTableFilterComposer,
      $$NumberSeriesTableOrderingComposer,
      $$NumberSeriesTableAnnotationComposer,
      $$NumberSeriesTableCreateCompanionBuilder,
      $$NumberSeriesTableUpdateCompanionBuilder,
      (
        NumberSeriesRow,
        BaseReferences<_$AppDatabase, $NumberSeriesTable, NumberSeriesRow>,
      ),
      NumberSeriesRow,
      PrefetchHooks Function()
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder =
    LedgerEntriesCompanion Function({
      required String id,
      required String tenantId,
      required String partyId,
      required String entryDate,
      required String side,
      required int amountPaise,
      required String refType,
      Value<String?> refId,
      Value<String?> narration,
      Value<String?> reversesId,
      Value<String?> replacesId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      required String createdAt,
      Value<String?> receivedAt,
      Value<int> rowid,
    });
typedef $$LedgerEntriesTableUpdateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> partyId,
      Value<String> entryDate,
      Value<String> side,
      Value<int> amountPaise,
      Value<String> refType,
      Value<String?> refId,
      Value<String?> narration,
      Value<String?> reversesId,
      Value<String?> replacesId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String> createdAt,
      Value<String?> receivedAt,
      Value<int> rowid,
    });

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refType => $composableBuilder(
    column: $table.refType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narration => $composableBuilder(
    column: $table.narration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replacesId => $composableBuilder(
    column: $table.replacesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refType => $composableBuilder(
    column: $table.refType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narration => $composableBuilder(
    column: $table.narration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replacesId => $composableBuilder(
    column: $table.replacesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refType =>
      $composableBuilder(column: $table.refType, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get narration =>
      $composableBuilder(column: $table.narration, builder: (column) => column);

  GeneratedColumn<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replacesId => $composableBuilder(
    column: $table.replacesId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerEntriesTable,
          LedgerEntryRow,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (
            LedgerEntryRow,
            BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntryRow>,
          ),
          LedgerEntryRow,
          PrefetchHooks Function()
        > {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> refType = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<String?> narration = const Value.absent(),
                Value<String?> reversesId = const Value.absent(),
                Value<String?> replacesId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion(
                id: id,
                tenantId: tenantId,
                partyId: partyId,
                entryDate: entryDate,
                side: side,
                amountPaise: amountPaise,
                refType: refType,
                refId: refId,
                narration: narration,
                reversesId: reversesId,
                replacesId: replacesId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String partyId,
                required String entryDate,
                required String side,
                required int amountPaise,
                required String refType,
                Value<String?> refId = const Value.absent(),
                Value<String?> narration = const Value.absent(),
                Value<String?> reversesId = const Value.absent(),
                Value<String?> replacesId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String createdAt,
                Value<String?> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                id: id,
                tenantId: tenantId,
                partyId: partyId,
                entryDate: entryDate,
                side: side,
                amountPaise: amountPaise,
                refType: refType,
                refId: refId,
                narration: narration,
                reversesId: reversesId,
                replacesId: replacesId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LedgerEntriesTable, LedgerEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LedgerEntriesTable,
                    LedgerEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerEntriesTable,
      LedgerEntryRow,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (
        LedgerEntryRow,
        BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntryRow>,
      ),
      LedgerEntryRow,
      PrefetchHooks Function()
    >;
typedef $$CropsTableCreateCompanionBuilder =
    CropsCompanion Function({
      required String id,
      required String tenantId,
      required String code,
      required String nameEn,
      Value<String?> nameHi,
      Value<String?> namePa,
      required String unit,
      Value<int?> mspOrStdRate,
      required int sortOrder,
      required bool isActive,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CropsTableUpdateCompanionBuilder =
    CropsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> code,
      Value<String> nameEn,
      Value<String?> nameHi,
      Value<String?> namePa,
      Value<String> unit,
      Value<int?> mspOrStdRate,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CropsTableFilterComposer extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameHi => $composableBuilder(
    column: $table.nameHi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namePa => $composableBuilder(
    column: $table.namePa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mspOrStdRate => $composableBuilder(
    column: $table.mspOrStdRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CropsTableOrderingComposer
    extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameHi => $composableBuilder(
    column: $table.nameHi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namePa => $composableBuilder(
    column: $table.namePa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mspOrStdRate => $composableBuilder(
    column: $table.mspOrStdRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CropsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameHi =>
      $composableBuilder(column: $table.nameHi, builder: (column) => column);

  GeneratedColumn<String> get namePa =>
      $composableBuilder(column: $table.namePa, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get mspOrStdRate => $composableBuilder(
    column: $table.mspOrStdRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CropsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CropsTable,
          Crop,
          $$CropsTableFilterComposer,
          $$CropsTableOrderingComposer,
          $$CropsTableAnnotationComposer,
          $$CropsTableCreateCompanionBuilder,
          $$CropsTableUpdateCompanionBuilder,
          (Crop, BaseReferences<_$AppDatabase, $CropsTable, Crop>),
          Crop,
          PrefetchHooks Function()
        > {
  $$CropsTableTableManager(_$AppDatabase db, $CropsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String?> nameHi = const Value.absent(),
                Value<String?> namePa = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> mspOrStdRate = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CropsCompanion(
                id: id,
                tenantId: tenantId,
                code: code,
                nameEn: nameEn,
                nameHi: nameHi,
                namePa: namePa,
                unit: unit,
                mspOrStdRate: mspOrStdRate,
                sortOrder: sortOrder,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String code,
                required String nameEn,
                Value<String?> nameHi = const Value.absent(),
                Value<String?> namePa = const Value.absent(),
                required String unit,
                Value<int?> mspOrStdRate = const Value.absent(),
                required int sortOrder,
                required bool isActive,
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CropsCompanion.insert(
                id: id,
                tenantId: tenantId,
                code: code,
                nameEn: nameEn,
                nameHi: nameHi,
                namePa: namePa,
                unit: unit,
                mspOrStdRate: mspOrStdRate,
                sortOrder: sortOrder,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CropsTable, Crop>(table),
                  BaseReferences<_$AppDatabase, $CropsTable, Crop>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CropsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CropsTable,
      Crop,
      $$CropsTableFilterComposer,
      $$CropsTableOrderingComposer,
      $$CropsTableAnnotationComposer,
      $$CropsTableCreateCompanionBuilder,
      $$CropsTableUpdateCompanionBuilder,
      (Crop, BaseReferences<_$AppDatabase, $CropsTable, Crop>),
      Crop,
      PrefetchHooks Function()
    >;
typedef $$LotsTableCreateCompanionBuilder =
    LotsCompanion Function({
      required String id,
      required String tenantId,
      required String lotNo,
      required String entryDate,
      required String farmerId,
      required String cropId,
      required int bags,
      Value<int?> qtlMilli,
      required bool qtlFromBags,
      Value<int?> ratePaisePerQtl,
      Value<String?> buyerPartyId,
      Value<String?> jFormNo,
      Value<String?> vehicleNo,
      Value<String?> notes,
      required String status,
      Value<String?> chargesSnapshot,
      Value<int?> gross,
      Value<int?> commission,
      Value<int?> netToFarmer,
      Value<int?> buyerTotal,
      Value<String?> postedAt,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$LotsTableUpdateCompanionBuilder =
    LotsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> lotNo,
      Value<String> entryDate,
      Value<String> farmerId,
      Value<String> cropId,
      Value<int> bags,
      Value<int?> qtlMilli,
      Value<bool> qtlFromBags,
      Value<int?> ratePaisePerQtl,
      Value<String?> buyerPartyId,
      Value<String?> jFormNo,
      Value<String?> vehicleNo,
      Value<String?> notes,
      Value<String> status,
      Value<String?> chargesSnapshot,
      Value<int?> gross,
      Value<int?> commission,
      Value<int?> netToFarmer,
      Value<int?> buyerTotal,
      Value<String?> postedAt,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$LotsTableFilterComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotNo => $composableBuilder(
    column: $table.lotNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmerId => $composableBuilder(
    column: $table.farmerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cropId => $composableBuilder(
    column: $table.cropId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bags => $composableBuilder(
    column: $table.bags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtlMilli => $composableBuilder(
    column: $table.qtlMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get qtlFromBags => $composableBuilder(
    column: $table.qtlFromBags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePaisePerQtl => $composableBuilder(
    column: $table.ratePaisePerQtl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buyerPartyId => $composableBuilder(
    column: $table.buyerPartyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jFormNo => $composableBuilder(
    column: $table.jFormNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleNo => $composableBuilder(
    column: $table.vehicleNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chargesSnapshot => $composableBuilder(
    column: $table.chargesSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gross => $composableBuilder(
    column: $table.gross,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netToFarmer => $composableBuilder(
    column: $table.netToFarmer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get buyerTotal => $composableBuilder(
    column: $table.buyerTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postedAt => $composableBuilder(
    column: $table.postedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LotsTableOrderingComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotNo => $composableBuilder(
    column: $table.lotNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmerId => $composableBuilder(
    column: $table.farmerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cropId => $composableBuilder(
    column: $table.cropId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bags => $composableBuilder(
    column: $table.bags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtlMilli => $composableBuilder(
    column: $table.qtlMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get qtlFromBags => $composableBuilder(
    column: $table.qtlFromBags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePaisePerQtl => $composableBuilder(
    column: $table.ratePaisePerQtl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buyerPartyId => $composableBuilder(
    column: $table.buyerPartyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jFormNo => $composableBuilder(
    column: $table.jFormNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleNo => $composableBuilder(
    column: $table.vehicleNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chargesSnapshot => $composableBuilder(
    column: $table.chargesSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gross => $composableBuilder(
    column: $table.gross,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netToFarmer => $composableBuilder(
    column: $table.netToFarmer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get buyerTotal => $composableBuilder(
    column: $table.buyerTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postedAt => $composableBuilder(
    column: $table.postedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get lotNo =>
      $composableBuilder(column: $table.lotNo, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get cropId =>
      $composableBuilder(column: $table.cropId, builder: (column) => column);

  GeneratedColumn<int> get bags =>
      $composableBuilder(column: $table.bags, builder: (column) => column);

  GeneratedColumn<int> get qtlMilli =>
      $composableBuilder(column: $table.qtlMilli, builder: (column) => column);

  GeneratedColumn<bool> get qtlFromBags => $composableBuilder(
    column: $table.qtlFromBags,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ratePaisePerQtl => $composableBuilder(
    column: $table.ratePaisePerQtl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buyerPartyId => $composableBuilder(
    column: $table.buyerPartyId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jFormNo =>
      $composableBuilder(column: $table.jFormNo, builder: (column) => column);

  GeneratedColumn<String> get vehicleNo =>
      $composableBuilder(column: $table.vehicleNo, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get chargesSnapshot => $composableBuilder(
    column: $table.chargesSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gross =>
      $composableBuilder(column: $table.gross, builder: (column) => column);

  GeneratedColumn<int> get commission => $composableBuilder(
    column: $table.commission,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netToFarmer => $composableBuilder(
    column: $table.netToFarmer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get buyerTotal => $composableBuilder(
    column: $table.buyerTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postedAt =>
      $composableBuilder(column: $table.postedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotsTable,
          Lot,
          $$LotsTableFilterComposer,
          $$LotsTableOrderingComposer,
          $$LotsTableAnnotationComposer,
          $$LotsTableCreateCompanionBuilder,
          $$LotsTableUpdateCompanionBuilder,
          (Lot, BaseReferences<_$AppDatabase, $LotsTable, Lot>),
          Lot,
          PrefetchHooks Function()
        > {
  $$LotsTableTableManager(_$AppDatabase db, $LotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> lotNo = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String> cropId = const Value.absent(),
                Value<int> bags = const Value.absent(),
                Value<int?> qtlMilli = const Value.absent(),
                Value<bool> qtlFromBags = const Value.absent(),
                Value<int?> ratePaisePerQtl = const Value.absent(),
                Value<String?> buyerPartyId = const Value.absent(),
                Value<String?> jFormNo = const Value.absent(),
                Value<String?> vehicleNo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> chargesSnapshot = const Value.absent(),
                Value<int?> gross = const Value.absent(),
                Value<int?> commission = const Value.absent(),
                Value<int?> netToFarmer = const Value.absent(),
                Value<int?> buyerTotal = const Value.absent(),
                Value<String?> postedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotsCompanion(
                id: id,
                tenantId: tenantId,
                lotNo: lotNo,
                entryDate: entryDate,
                farmerId: farmerId,
                cropId: cropId,
                bags: bags,
                qtlMilli: qtlMilli,
                qtlFromBags: qtlFromBags,
                ratePaisePerQtl: ratePaisePerQtl,
                buyerPartyId: buyerPartyId,
                jFormNo: jFormNo,
                vehicleNo: vehicleNo,
                notes: notes,
                status: status,
                chargesSnapshot: chargesSnapshot,
                gross: gross,
                commission: commission,
                netToFarmer: netToFarmer,
                buyerTotal: buyerTotal,
                postedAt: postedAt,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String lotNo,
                required String entryDate,
                required String farmerId,
                required String cropId,
                required int bags,
                Value<int?> qtlMilli = const Value.absent(),
                required bool qtlFromBags,
                Value<int?> ratePaisePerQtl = const Value.absent(),
                Value<String?> buyerPartyId = const Value.absent(),
                Value<String?> jFormNo = const Value.absent(),
                Value<String?> vehicleNo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String status,
                Value<String?> chargesSnapshot = const Value.absent(),
                Value<int?> gross = const Value.absent(),
                Value<int?> commission = const Value.absent(),
                Value<int?> netToFarmer = const Value.absent(),
                Value<int?> buyerTotal = const Value.absent(),
                Value<String?> postedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotsCompanion.insert(
                id: id,
                tenantId: tenantId,
                lotNo: lotNo,
                entryDate: entryDate,
                farmerId: farmerId,
                cropId: cropId,
                bags: bags,
                qtlMilli: qtlMilli,
                qtlFromBags: qtlFromBags,
                ratePaisePerQtl: ratePaisePerQtl,
                buyerPartyId: buyerPartyId,
                jFormNo: jFormNo,
                vehicleNo: vehicleNo,
                notes: notes,
                status: status,
                chargesSnapshot: chargesSnapshot,
                gross: gross,
                commission: commission,
                netToFarmer: netToFarmer,
                buyerTotal: buyerTotal,
                postedAt: postedAt,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LotsTable, Lot>(table),
                  BaseReferences<_$AppDatabase, $LotsTable, Lot>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotsTable,
      Lot,
      $$LotsTableFilterComposer,
      $$LotsTableOrderingComposer,
      $$LotsTableAnnotationComposer,
      $$LotsTableCreateCompanionBuilder,
      $$LotsTableUpdateCompanionBuilder,
      (Lot, BaseReferences<_$AppDatabase, $LotsTable, Lot>),
      Lot,
      PrefetchHooks Function()
    >;
typedef $$BankAccountsTableCreateCompanionBuilder =
    BankAccountsCompanion Function({
      required String id,
      required String tenantId,
      required String kind,
      required String name,
      Value<String?> bankName,
      Value<String?> accountLast4,
      Value<String?> ifsc,
      required int sortOrder,
      required bool isActive,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$BankAccountsTableUpdateCompanionBuilder =
    BankAccountsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> kind,
      Value<String> name,
      Value<String?> bankName,
      Value<String?> accountLast4,
      Value<String?> ifsc,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$BankAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountLast4 => $composableBuilder(
    column: $table.accountLast4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ifsc => $composableBuilder(
    column: $table.ifsc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountLast4 => $composableBuilder(
    column: $table.accountLast4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ifsc => $composableBuilder(
    column: $table.ifsc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get accountLast4 => $composableBuilder(
    column: $table.accountLast4,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ifsc =>
      $composableBuilder(column: $table.ifsc, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BankAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankAccountsTable,
          BankAccount,
          $$BankAccountsTableFilterComposer,
          $$BankAccountsTableOrderingComposer,
          $$BankAccountsTableAnnotationComposer,
          $$BankAccountsTableCreateCompanionBuilder,
          $$BankAccountsTableUpdateCompanionBuilder,
          (
            BankAccount,
            BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount>,
          ),
          BankAccount,
          PrefetchHooks Function()
        > {
  $$BankAccountsTableTableManager(_$AppDatabase db, $BankAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> bankName = const Value.absent(),
                Value<String?> accountLast4 = const Value.absent(),
                Value<String?> ifsc = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BankAccountsCompanion(
                id: id,
                tenantId: tenantId,
                kind: kind,
                name: name,
                bankName: bankName,
                accountLast4: accountLast4,
                ifsc: ifsc,
                sortOrder: sortOrder,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String kind,
                required String name,
                Value<String?> bankName = const Value.absent(),
                Value<String?> accountLast4 = const Value.absent(),
                Value<String?> ifsc = const Value.absent(),
                required int sortOrder,
                required bool isActive,
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BankAccountsCompanion.insert(
                id: id,
                tenantId: tenantId,
                kind: kind,
                name: name,
                bankName: bankName,
                accountLast4: accountLast4,
                ifsc: ifsc,
                sortOrder: sortOrder,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BankAccountsTable, BankAccount>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BankAccountsTable,
                    BankAccount
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BankAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankAccountsTable,
      BankAccount,
      $$BankAccountsTableFilterComposer,
      $$BankAccountsTableOrderingComposer,
      $$BankAccountsTableAnnotationComposer,
      $$BankAccountsTableCreateCompanionBuilder,
      $$BankAccountsTableUpdateCompanionBuilder,
      (
        BankAccount,
        BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount>,
      ),
      BankAccount,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String tenantId,
      required String receiptNo,
      required String entryDate,
      required String partyId,
      required String direction,
      required String mode,
      required int amountPaise,
      required String bankAccountId,
      Value<String?> reference,
      Value<String?> chequeNo,
      Value<String?> chequeDate,
      Value<String?> chequeStatus,
      Value<String?> narration,
      required String status,
      Value<String?> reversedAt,
      Value<String?> loanId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> receiptNo,
      Value<String> entryDate,
      Value<String> partyId,
      Value<String> direction,
      Value<String> mode,
      Value<int> amountPaise,
      Value<String> bankAccountId,
      Value<String?> reference,
      Value<String?> chequeNo,
      Value<String?> chequeDate,
      Value<String?> chequeStatus,
      Value<String?> narration,
      Value<String> status,
      Value<String?> reversedAt,
      Value<String?> loanId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chequeNo => $composableBuilder(
    column: $table.chequeNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chequeDate => $composableBuilder(
    column: $table.chequeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chequeStatus => $composableBuilder(
    column: $table.chequeStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narration => $composableBuilder(
    column: $table.narration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chequeNo => $composableBuilder(
    column: $table.chequeNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chequeDate => $composableBuilder(
    column: $table.chequeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chequeStatus => $composableBuilder(
    column: $table.chequeStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narration => $composableBuilder(
    column: $table.narration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get receiptNo =>
      $composableBuilder(column: $table.receiptNo, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get chequeNo =>
      $composableBuilder(column: $table.chequeNo, builder: (column) => column);

  GeneratedColumn<String> get chequeDate => $composableBuilder(
    column: $table.chequeDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chequeStatus => $composableBuilder(
    column: $table.chequeStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get narration =>
      $composableBuilder(column: $table.narration, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reversedAt => $composableBuilder(
    column: $table.reversedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loanId =>
      $composableBuilder(column: $table.loanId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
          Payment,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> receiptNo = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> bankAccountId = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> chequeNo = const Value.absent(),
                Value<String?> chequeDate = const Value.absent(),
                Value<String?> chequeStatus = const Value.absent(),
                Value<String?> narration = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reversedAt = const Value.absent(),
                Value<String?> loanId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                tenantId: tenantId,
                receiptNo: receiptNo,
                entryDate: entryDate,
                partyId: partyId,
                direction: direction,
                mode: mode,
                amountPaise: amountPaise,
                bankAccountId: bankAccountId,
                reference: reference,
                chequeNo: chequeNo,
                chequeDate: chequeDate,
                chequeStatus: chequeStatus,
                narration: narration,
                status: status,
                reversedAt: reversedAt,
                loanId: loanId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String receiptNo,
                required String entryDate,
                required String partyId,
                required String direction,
                required String mode,
                required int amountPaise,
                required String bankAccountId,
                Value<String?> reference = const Value.absent(),
                Value<String?> chequeNo = const Value.absent(),
                Value<String?> chequeDate = const Value.absent(),
                Value<String?> chequeStatus = const Value.absent(),
                Value<String?> narration = const Value.absent(),
                required String status,
                Value<String?> reversedAt = const Value.absent(),
                Value<String?> loanId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                tenantId: tenantId,
                receiptNo: receiptNo,
                entryDate: entryDate,
                partyId: partyId,
                direction: direction,
                mode: mode,
                amountPaise: amountPaise,
                bankAccountId: bankAccountId,
                reference: reference,
                chequeNo: chequeNo,
                chequeDate: chequeDate,
                chequeStatus: chequeStatus,
                narration: narration,
                status: status,
                reversedAt: reversedAt,
                loanId: loanId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, Payment>(table),
                  BaseReferences<_$AppDatabase, $PaymentsTable, Payment>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
      Payment,
      PrefetchHooks Function()
    >;
typedef $$CashBankEntriesTableCreateCompanionBuilder =
    CashBankEntriesCompanion Function({
      required String id,
      required String tenantId,
      required String accountId,
      required String accountKind,
      required String entryDate,
      required String direction,
      required int amountPaise,
      required String paymentId,
      Value<String?> narration,
      Value<String?> reversesId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });
typedef $$CashBankEntriesTableUpdateCompanionBuilder =
    CashBankEntriesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> accountId,
      Value<String> accountKind,
      Value<String> entryDate,
      Value<String> direction,
      Value<int> amountPaise,
      Value<String> paymentId,
      Value<String?> narration,
      Value<String?> reversesId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });

class $$CashBankEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CashBankEntriesTable> {
  $$CashBankEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narration => $composableBuilder(
    column: $table.narration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashBankEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CashBankEntriesTable> {
  $$CashBankEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narration => $composableBuilder(
    column: $table.narration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashBankEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashBankEntriesTable> {
  $$CashBankEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get accountKind => $composableBuilder(
    column: $table.accountKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get narration =>
      $composableBuilder(column: $table.narration, builder: (column) => column);

  GeneratedColumn<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CashBankEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashBankEntriesTable,
          CashBankEntry,
          $$CashBankEntriesTableFilterComposer,
          $$CashBankEntriesTableOrderingComposer,
          $$CashBankEntriesTableAnnotationComposer,
          $$CashBankEntriesTableCreateCompanionBuilder,
          $$CashBankEntriesTableUpdateCompanionBuilder,
          (
            CashBankEntry,
            BaseReferences<_$AppDatabase, $CashBankEntriesTable, CashBankEntry>,
          ),
          CashBankEntry,
          PrefetchHooks Function()
        > {
  $$CashBankEntriesTableTableManager(
    _$AppDatabase db,
    $CashBankEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashBankEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashBankEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashBankEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> accountKind = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> paymentId = const Value.absent(),
                Value<String?> narration = const Value.absent(),
                Value<String?> reversesId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashBankEntriesCompanion(
                id: id,
                tenantId: tenantId,
                accountId: accountId,
                accountKind: accountKind,
                entryDate: entryDate,
                direction: direction,
                amountPaise: amountPaise,
                paymentId: paymentId,
                narration: narration,
                reversesId: reversesId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String accountId,
                required String accountKind,
                required String entryDate,
                required String direction,
                required int amountPaise,
                required String paymentId,
                Value<String?> narration = const Value.absent(),
                Value<String?> reversesId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashBankEntriesCompanion.insert(
                id: id,
                tenantId: tenantId,
                accountId: accountId,
                accountKind: accountKind,
                entryDate: entryDate,
                direction: direction,
                amountPaise: amountPaise,
                paymentId: paymentId,
                narration: narration,
                reversesId: reversesId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashBankEntriesTable, CashBankEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashBankEntriesTable,
                    CashBankEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashBankEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashBankEntriesTable,
      CashBankEntry,
      $$CashBankEntriesTableFilterComposer,
      $$CashBankEntriesTableOrderingComposer,
      $$CashBankEntriesTableAnnotationComposer,
      $$CashBankEntriesTableCreateCompanionBuilder,
      $$CashBankEntriesTableUpdateCompanionBuilder,
      (
        CashBankEntry,
        BaseReferences<_$AppDatabase, $CashBankEntriesTable, CashBankEntry>,
      ),
      CashBankEntry,
      PrefetchHooks Function()
    >;
typedef $$LoansTableCreateCompanionBuilder =
    LoansCompanion Function({
      required String id,
      required String tenantId,
      required String loanNo,
      required String partyId,
      required String issueDate,
      required int principalPaise,
      Value<String?> purpose,
      Value<String?> dueDate,
      Value<String?> guarantorPartyId,
      required String interestConfigSnapshot,
      required String status,
      Value<String?> closedOn,
      Value<String?> closeReason,
      Value<String?> notes,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$LoansTableUpdateCompanionBuilder =
    LoansCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> loanNo,
      Value<String> partyId,
      Value<String> issueDate,
      Value<int> principalPaise,
      Value<String?> purpose,
      Value<String?> dueDate,
      Value<String?> guarantorPartyId,
      Value<String> interestConfigSnapshot,
      Value<String> status,
      Value<String?> closedOn,
      Value<String?> closeReason,
      Value<String?> notes,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loanNo => $composableBuilder(
    column: $table.loanNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guarantorPartyId => $composableBuilder(
    column: $table.guarantorPartyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestConfigSnapshot => $composableBuilder(
    column: $table.interestConfigSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedOn => $composableBuilder(
    column: $table.closedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loanNo => $composableBuilder(
    column: $table.loanNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guarantorPartyId => $composableBuilder(
    column: $table.guarantorPartyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestConfigSnapshot => $composableBuilder(
    column: $table.interestConfigSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedOn => $composableBuilder(
    column: $table.closedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get loanNo =>
      $composableBuilder(column: $table.loanNo, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<int> get principalPaise => $composableBuilder(
    column: $table.principalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get guarantorPartyId => $composableBuilder(
    column: $table.guarantorPartyId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestConfigSnapshot => $composableBuilder(
    column: $table.interestConfigSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get closedOn =>
      $composableBuilder(column: $table.closedOn, builder: (column) => column);

  GeneratedColumn<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoansTable,
          Loan,
          $$LoansTableFilterComposer,
          $$LoansTableOrderingComposer,
          $$LoansTableAnnotationComposer,
          $$LoansTableCreateCompanionBuilder,
          $$LoansTableUpdateCompanionBuilder,
          (Loan, BaseReferences<_$AppDatabase, $LoansTable, Loan>),
          Loan,
          PrefetchHooks Function()
        > {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> loanNo = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> issueDate = const Value.absent(),
                Value<int> principalPaise = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> guarantorPartyId = const Value.absent(),
                Value<String> interestConfigSnapshot = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> closedOn = const Value.absent(),
                Value<String?> closeReason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoansCompanion(
                id: id,
                tenantId: tenantId,
                loanNo: loanNo,
                partyId: partyId,
                issueDate: issueDate,
                principalPaise: principalPaise,
                purpose: purpose,
                dueDate: dueDate,
                guarantorPartyId: guarantorPartyId,
                interestConfigSnapshot: interestConfigSnapshot,
                status: status,
                closedOn: closedOn,
                closeReason: closeReason,
                notes: notes,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String loanNo,
                required String partyId,
                required String issueDate,
                required int principalPaise,
                Value<String?> purpose = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> guarantorPartyId = const Value.absent(),
                required String interestConfigSnapshot,
                required String status,
                Value<String?> closedOn = const Value.absent(),
                Value<String?> closeReason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoansCompanion.insert(
                id: id,
                tenantId: tenantId,
                loanNo: loanNo,
                partyId: partyId,
                issueDate: issueDate,
                principalPaise: principalPaise,
                purpose: purpose,
                dueDate: dueDate,
                guarantorPartyId: guarantorPartyId,
                interestConfigSnapshot: interestConfigSnapshot,
                status: status,
                closedOn: closedOn,
                closeReason: closeReason,
                notes: notes,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LoansTable, Loan>(table),
                  BaseReferences<_$AppDatabase, $LoansTable, Loan>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoansTable,
      Loan,
      $$LoansTableFilterComposer,
      $$LoansTableOrderingComposer,
      $$LoansTableAnnotationComposer,
      $$LoansTableCreateCompanionBuilder,
      $$LoansTableUpdateCompanionBuilder,
      (Loan, BaseReferences<_$AppDatabase, $LoansTable, Loan>),
      Loan,
      PrefetchHooks Function()
    >;
typedef $$LoanRateChangesTableCreateCompanionBuilder =
    LoanRateChangesCompanion Function({
      required String id,
      required String tenantId,
      required String loanId,
      required String effectiveDate,
      required String ratePa,
      Value<String?> reason,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });
typedef $$LoanRateChangesTableUpdateCompanionBuilder =
    LoanRateChangesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> loanId,
      Value<String> effectiveDate,
      Value<String> ratePa,
      Value<String?> reason,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });

class $$LoanRateChangesTableFilterComposer
    extends Composer<_$AppDatabase, $LoanRateChangesTable> {
  $$LoanRateChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratePa => $composableBuilder(
    column: $table.ratePa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoanRateChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $LoanRateChangesTable> {
  $$LoanRateChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratePa => $composableBuilder(
    column: $table.ratePa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoanRateChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoanRateChangesTable> {
  $$LoanRateChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get loanId =>
      $composableBuilder(column: $table.loanId, builder: (column) => column);

  GeneratedColumn<String> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratePa =>
      $composableBuilder(column: $table.ratePa, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LoanRateChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoanRateChangesTable,
          LoanRateChange,
          $$LoanRateChangesTableFilterComposer,
          $$LoanRateChangesTableOrderingComposer,
          $$LoanRateChangesTableAnnotationComposer,
          $$LoanRateChangesTableCreateCompanionBuilder,
          $$LoanRateChangesTableUpdateCompanionBuilder,
          (
            LoanRateChange,
            BaseReferences<
              _$AppDatabase,
              $LoanRateChangesTable,
              LoanRateChange
            >,
          ),
          LoanRateChange,
          PrefetchHooks Function()
        > {
  $$LoanRateChangesTableTableManager(
    _$AppDatabase db,
    $LoanRateChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoanRateChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoanRateChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoanRateChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> loanId = const Value.absent(),
                Value<String> effectiveDate = const Value.absent(),
                Value<String> ratePa = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoanRateChangesCompanion(
                id: id,
                tenantId: tenantId,
                loanId: loanId,
                effectiveDate: effectiveDate,
                ratePa: ratePa,
                reason: reason,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String loanId,
                required String effectiveDate,
                required String ratePa,
                Value<String?> reason = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoanRateChangesCompanion.insert(
                id: id,
                tenantId: tenantId,
                loanId: loanId,
                effectiveDate: effectiveDate,
                ratePa: ratePa,
                reason: reason,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LoanRateChangesTable, LoanRateChange>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LoanRateChangesTable,
                    LoanRateChange
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoanRateChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoanRateChangesTable,
      LoanRateChange,
      $$LoanRateChangesTableFilterComposer,
      $$LoanRateChangesTableOrderingComposer,
      $$LoanRateChangesTableAnnotationComposer,
      $$LoanRateChangesTableCreateCompanionBuilder,
      $$LoanRateChangesTableUpdateCompanionBuilder,
      (
        LoanRateChange,
        BaseReferences<_$AppDatabase, $LoanRateChangesTable, LoanRateChange>,
      ),
      LoanRateChange,
      PrefetchHooks Function()
    >;
typedef $$InterestPostingsTableCreateCompanionBuilder =
    InterestPostingsCompanion Function({
      required String id,
      required String tenantId,
      required String partyId,
      Value<String?> loanId,
      required String kind,
      required String periodFrom,
      required String periodTo,
      required int amountPaise,
      Value<String?> ratePa,
      Value<String?> method,
      Value<String?> reason,
      required String periodKey,
      Value<String?> batchId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });
typedef $$InterestPostingsTableUpdateCompanionBuilder =
    InterestPostingsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> partyId,
      Value<String?> loanId,
      Value<String> kind,
      Value<String> periodFrom,
      Value<String> periodTo,
      Value<int> amountPaise,
      Value<String?> ratePa,
      Value<String?> method,
      Value<String?> reason,
      Value<String> periodKey,
      Value<String?> batchId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });

class $$InterestPostingsTableFilterComposer
    extends Composer<_$AppDatabase, $InterestPostingsTable> {
  $$InterestPostingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodFrom => $composableBuilder(
    column: $table.periodFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodTo => $composableBuilder(
    column: $table.periodTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratePa => $composableBuilder(
    column: $table.ratePa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InterestPostingsTableOrderingComposer
    extends Composer<_$AppDatabase, $InterestPostingsTable> {
  $$InterestPostingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loanId => $composableBuilder(
    column: $table.loanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodFrom => $composableBuilder(
    column: $table.periodFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodTo => $composableBuilder(
    column: $table.periodTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratePa => $composableBuilder(
    column: $table.ratePa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InterestPostingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterestPostingsTable> {
  $$InterestPostingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get loanId =>
      $composableBuilder(column: $table.loanId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get periodFrom => $composableBuilder(
    column: $table.periodFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get periodTo =>
      $composableBuilder(column: $table.periodTo, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratePa =>
      $composableBuilder(column: $table.ratePa, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InterestPostingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InterestPostingsTable,
          InterestPosting,
          $$InterestPostingsTableFilterComposer,
          $$InterestPostingsTableOrderingComposer,
          $$InterestPostingsTableAnnotationComposer,
          $$InterestPostingsTableCreateCompanionBuilder,
          $$InterestPostingsTableUpdateCompanionBuilder,
          (
            InterestPosting,
            BaseReferences<
              _$AppDatabase,
              $InterestPostingsTable,
              InterestPosting
            >,
          ),
          InterestPosting,
          PrefetchHooks Function()
        > {
  $$InterestPostingsTableTableManager(
    _$AppDatabase db,
    $InterestPostingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterestPostingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InterestPostingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterestPostingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String?> loanId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> periodFrom = const Value.absent(),
                Value<String> periodTo = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> ratePa = const Value.absent(),
                Value<String?> method = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterestPostingsCompanion(
                id: id,
                tenantId: tenantId,
                partyId: partyId,
                loanId: loanId,
                kind: kind,
                periodFrom: periodFrom,
                periodTo: periodTo,
                amountPaise: amountPaise,
                ratePa: ratePa,
                method: method,
                reason: reason,
                periodKey: periodKey,
                batchId: batchId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String partyId,
                Value<String?> loanId = const Value.absent(),
                required String kind,
                required String periodFrom,
                required String periodTo,
                required int amountPaise,
                Value<String?> ratePa = const Value.absent(),
                Value<String?> method = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required String periodKey,
                Value<String?> batchId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterestPostingsCompanion.insert(
                id: id,
                tenantId: tenantId,
                partyId: partyId,
                loanId: loanId,
                kind: kind,
                periodFrom: periodFrom,
                periodTo: periodTo,
                amountPaise: amountPaise,
                ratePa: ratePa,
                method: method,
                reason: reason,
                periodKey: periodKey,
                batchId: batchId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InterestPostingsTable, InterestPosting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InterestPostingsTable,
                    InterestPosting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InterestPostingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InterestPostingsTable,
      InterestPosting,
      $$InterestPostingsTableFilterComposer,
      $$InterestPostingsTableOrderingComposer,
      $$InterestPostingsTableAnnotationComposer,
      $$InterestPostingsTableCreateCompanionBuilder,
      $$InterestPostingsTableUpdateCompanionBuilder,
      (
        InterestPosting,
        BaseReferences<_$AppDatabase, $InterestPostingsTable, InterestPosting>,
      ),
      InterestPosting,
      PrefetchHooks Function()
    >;
typedef $$AccountGroupsTableCreateCompanionBuilder =
    AccountGroupsCompanion Function({
      required String id,
      required String tenantId,
      required String code,
      required String name,
      Value<String?> parentId,
      required String nature,
      required bool isSystem,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$AccountGroupsTableUpdateCompanionBuilder =
    AccountGroupsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> code,
      Value<String> name,
      Value<String?> parentId,
      Value<String> nature,
      Value<bool> isSystem,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$AccountGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nature => $composableBuilder(
    column: $table.nature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nature => $composableBuilder(
    column: $table.nature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get nature =>
      $composableBuilder(column: $table.nature, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AccountGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountGroupsTable,
          AccountGroup,
          $$AccountGroupsTableFilterComposer,
          $$AccountGroupsTableOrderingComposer,
          $$AccountGroupsTableAnnotationComposer,
          $$AccountGroupsTableCreateCompanionBuilder,
          $$AccountGroupsTableUpdateCompanionBuilder,
          (
            AccountGroup,
            BaseReferences<_$AppDatabase, $AccountGroupsTable, AccountGroup>,
          ),
          AccountGroup,
          PrefetchHooks Function()
        > {
  $$AccountGroupsTableTableManager(_$AppDatabase db, $AccountGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> nature = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountGroupsCompanion(
                id: id,
                tenantId: tenantId,
                code: code,
                name: name,
                parentId: parentId,
                nature: nature,
                isSystem: isSystem,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String code,
                required String name,
                Value<String?> parentId = const Value.absent(),
                required String nature,
                required bool isSystem,
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountGroupsCompanion.insert(
                id: id,
                tenantId: tenantId,
                code: code,
                name: name,
                parentId: parentId,
                nature: nature,
                isSystem: isSystem,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountGroupsTable, AccountGroup>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AccountGroupsTable,
                    AccountGroup
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountGroupsTable,
      AccountGroup,
      $$AccountGroupsTableFilterComposer,
      $$AccountGroupsTableOrderingComposer,
      $$AccountGroupsTableAnnotationComposer,
      $$AccountGroupsTableCreateCompanionBuilder,
      $$AccountGroupsTableUpdateCompanionBuilder,
      (
        AccountGroup,
        BaseReferences<_$AppDatabase, $AccountGroupsTable, AccountGroup>,
      ),
      AccountGroup,
      PrefetchHooks Function()
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      required String tenantId,
      required String groupId,
      required String name,
      Value<String?> partyId,
      Value<String?> bankAccountId,
      Value<String?> systemCode,
      required bool isSystem,
      required bool isActive,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> groupId,
      Value<String> name,
      Value<String?> partyId,
      Value<String?> bankAccountId,
      Value<String?> systemCode,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemCode => $composableBuilder(
    column: $table.systemCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyId => $composableBuilder(
    column: $table.partyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemCode => $composableBuilder(
    column: $table.systemCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get bankAccountId => $composableBuilder(
    column: $table.bankAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemCode => $composableBuilder(
    column: $table.systemCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> partyId = const Value.absent(),
                Value<String?> bankAccountId = const Value.absent(),
                Value<String?> systemCode = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                tenantId: tenantId,
                groupId: groupId,
                name: name,
                partyId: partyId,
                bankAccountId: bankAccountId,
                systemCode: systemCode,
                isSystem: isSystem,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String groupId,
                required String name,
                Value<String?> partyId = const Value.absent(),
                Value<String?> bankAccountId = const Value.absent(),
                Value<String?> systemCode = const Value.absent(),
                required bool isSystem,
                required bool isActive,
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                tenantId: tenantId,
                groupId: groupId,
                name: name,
                partyId: partyId,
                bankAccountId: bankAccountId,
                systemCode: systemCode,
                isSystem: isSystem,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  BaseReferences<_$AppDatabase, $AccountsTable, Account>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required String tenantId,
      required String sourceKey,
      required String sourceType,
      Value<String?> voucherId,
      required String entryDate,
      Value<String?> narration,
      Value<String?> reversesId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> sourceKey,
      Value<String> sourceType,
      Value<String?> voucherId,
      Value<String> entryDate,
      Value<String?> narration,
      Value<String?> reversesId,
      Value<String?> deviceId,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voucherId => $composableBuilder(
    column: $table.voucherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narration => $composableBuilder(
    column: $table.narration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voucherId => $composableBuilder(
    column: $table.voucherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narration => $composableBuilder(
    column: $table.narration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voucherId =>
      $composableBuilder(column: $table.voucherId, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get narration =>
      $composableBuilder(column: $table.narration, builder: (column) => column);

  GeneratedColumn<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String?> voucherId = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String?> narration = const Value.absent(),
                Value<String?> reversesId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                tenantId: tenantId,
                sourceKey: sourceKey,
                sourceType: sourceType,
                voucherId: voucherId,
                entryDate: entryDate,
                narration: narration,
                reversesId: reversesId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String sourceKey,
                required String sourceType,
                Value<String?> voucherId = const Value.absent(),
                required String entryDate,
                Value<String?> narration = const Value.absent(),
                Value<String?> reversesId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                tenantId: tenantId,
                sourceKey: sourceKey,
                sourceType: sourceType,
                voucherId: voucherId,
                entryDate: entryDate,
                narration: narration,
                reversesId: reversesId,
                deviceId: deviceId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalEntriesTable, JournalEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JournalEntriesTable,
                    JournalEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$JournalLinesTableCreateCompanionBuilder =
    JournalLinesCompanion Function({
      required String id,
      required String tenantId,
      required String journalEntryId,
      required int lineNo,
      required String accountId,
      required int debitPaise,
      required int creditPaise,
      Value<String?> memo,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });
typedef $$JournalLinesTableUpdateCompanionBuilder =
    JournalLinesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> journalEntryId,
      Value<int> lineNo,
      Value<String> accountId,
      Value<int> debitPaise,
      Value<int> creditPaise,
      Value<String?> memo,
      Value<String?> createdBy,
      Value<String?> createdAt,
      Value<int> rowid,
    });

class $$JournalLinesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get debitPaise => $composableBuilder(
    column: $table.debitPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditPaise => $composableBuilder(
    column: $table.creditPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get debitPaise => $composableBuilder(
    column: $table.debitPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditPaise => $composableBuilder(
    column: $table.creditPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get debitPaise => $composableBuilder(
    column: $table.debitPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditPaise => $composableBuilder(
    column: $table.creditPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalLinesTable,
          JournalLine,
          $$JournalLinesTableFilterComposer,
          $$JournalLinesTableOrderingComposer,
          $$JournalLinesTableAnnotationComposer,
          $$JournalLinesTableCreateCompanionBuilder,
          $$JournalLinesTableUpdateCompanionBuilder,
          (
            JournalLine,
            BaseReferences<_$AppDatabase, $JournalLinesTable, JournalLine>,
          ),
          JournalLine,
          PrefetchHooks Function()
        > {
  $$JournalLinesTableTableManager(_$AppDatabase db, $JournalLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> journalEntryId = const Value.absent(),
                Value<int> lineNo = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> debitPaise = const Value.absent(),
                Value<int> creditPaise = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalLinesCompanion(
                id: id,
                tenantId: tenantId,
                journalEntryId: journalEntryId,
                lineNo: lineNo,
                accountId: accountId,
                debitPaise: debitPaise,
                creditPaise: creditPaise,
                memo: memo,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String journalEntryId,
                required int lineNo,
                required String accountId,
                required int debitPaise,
                required int creditPaise,
                Value<String?> memo = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalLinesCompanion.insert(
                id: id,
                tenantId: tenantId,
                journalEntryId: journalEntryId,
                lineNo: lineNo,
                accountId: accountId,
                debitPaise: debitPaise,
                creditPaise: creditPaise,
                memo: memo,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalLinesTable, JournalLine>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JournalLinesTable,
                    JournalLine
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalLinesTable,
      JournalLine,
      $$JournalLinesTableFilterComposer,
      $$JournalLinesTableOrderingComposer,
      $$JournalLinesTableAnnotationComposer,
      $$JournalLinesTableCreateCompanionBuilder,
      $$JournalLinesTableUpdateCompanionBuilder,
      (
        JournalLine,
        BaseReferences<_$AppDatabase, $JournalLinesTable, JournalLine>,
      ),
      JournalLine,
      PrefetchHooks Function()
    >;
typedef $$SyncErrorsTableCreateCompanionBuilder =
    SyncErrorsCompanion Function({
      required String id,
      required String tableNameValue,
      required String rowId,
      required String op,
      Value<String?> opData,
      Value<String?> errorCode,
      required String message,
      required String createdAt,
      Value<String?> batchId,
      Value<int?> batchSeq,
      Value<int> rowid,
    });
typedef $$SyncErrorsTableUpdateCompanionBuilder =
    SyncErrorsCompanion Function({
      Value<String> id,
      Value<String> tableNameValue,
      Value<String> rowId,
      Value<String> op,
      Value<String?> opData,
      Value<String?> errorCode,
      Value<String> message,
      Value<String> createdAt,
      Value<String?> batchId,
      Value<int?> batchSeq,
      Value<int> rowid,
    });

class $$SyncErrorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncErrorsTable> {
  $$SyncErrorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableNameValue => $composableBuilder(
    column: $table.tableNameValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opData => $composableBuilder(
    column: $table.opData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchSeq => $composableBuilder(
    column: $table.batchSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncErrorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncErrorsTable> {
  $$SyncErrorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableNameValue => $composableBuilder(
    column: $table.tableNameValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opData => $composableBuilder(
    column: $table.opData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchSeq => $composableBuilder(
    column: $table.batchSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncErrorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncErrorsTable> {
  $$SyncErrorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tableNameValue => $composableBuilder(
    column: $table.tableNameValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get opData =>
      $composableBuilder(column: $table.opData, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get batchSeq =>
      $composableBuilder(column: $table.batchSeq, builder: (column) => column);
}

class $$SyncErrorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncErrorsTable,
          SyncError,
          $$SyncErrorsTableFilterComposer,
          $$SyncErrorsTableOrderingComposer,
          $$SyncErrorsTableAnnotationComposer,
          $$SyncErrorsTableCreateCompanionBuilder,
          $$SyncErrorsTableUpdateCompanionBuilder,
          (
            SyncError,
            BaseReferences<_$AppDatabase, $SyncErrorsTable, SyncError>,
          ),
          SyncError,
          PrefetchHooks Function()
        > {
  $$SyncErrorsTableTableManager(_$AppDatabase db, $SyncErrorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncErrorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncErrorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncErrorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tableNameValue = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String?> opData = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<int?> batchSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncErrorsCompanion(
                id: id,
                tableNameValue: tableNameValue,
                rowId: rowId,
                op: op,
                opData: opData,
                errorCode: errorCode,
                message: message,
                createdAt: createdAt,
                batchId: batchId,
                batchSeq: batchSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tableNameValue,
                required String rowId,
                required String op,
                Value<String?> opData = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                required String message,
                required String createdAt,
                Value<String?> batchId = const Value.absent(),
                Value<int?> batchSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncErrorsCompanion.insert(
                id: id,
                tableNameValue: tableNameValue,
                rowId: rowId,
                op: op,
                opData: opData,
                errorCode: errorCode,
                message: message,
                createdAt: createdAt,
                batchId: batchId,
                batchSeq: batchSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncErrorsTable, SyncError>(table),
                  BaseReferences<_$AppDatabase, $SyncErrorsTable, SyncError>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncErrorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncErrorsTable,
      SyncError,
      $$SyncErrorsTableFilterComposer,
      $$SyncErrorsTableOrderingComposer,
      $$SyncErrorsTableAnnotationComposer,
      $$SyncErrorsTableCreateCompanionBuilder,
      $$SyncErrorsTableUpdateCompanionBuilder,
      (SyncError, BaseReferences<_$AppDatabase, $SyncErrorsTable, SyncError>),
      SyncError,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db, _db.tenants);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$TenantMembersTableTableManager get tenantMembers =>
      $$TenantMembersTableTableManager(_db, _db.tenantMembers);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$MemberInvitesTableTableManager get memberInvites =>
      $$MemberInvitesTableTableManager(_db, _db.memberInvites);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$PartyRolesTableTableManager get partyRoles =>
      $$PartyRolesTableTableManager(_db, _db.partyRoles);
  $$NumberSeriesTableTableManager get numberSeries =>
      $$NumberSeriesTableTableManager(_db, _db.numberSeries);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$CropsTableTableManager get crops =>
      $$CropsTableTableManager(_db, _db.crops);
  $$LotsTableTableManager get lots => $$LotsTableTableManager(_db, _db.lots);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db, _db.bankAccounts);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$CashBankEntriesTableTableManager get cashBankEntries =>
      $$CashBankEntriesTableTableManager(_db, _db.cashBankEntries);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$LoanRateChangesTableTableManager get loanRateChanges =>
      $$LoanRateChangesTableTableManager(_db, _db.loanRateChanges);
  $$InterestPostingsTableTableManager get interestPostings =>
      $$InterestPostingsTableTableManager(_db, _db.interestPostings);
  $$AccountGroupsTableTableManager get accountGroups =>
      $$AccountGroupsTableTableManager(_db, _db.accountGroups);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$JournalLinesTableTableManager get journalLines =>
      $$JournalLinesTableTableManager(_db, _db.journalLines);
  $$SyncErrorsTableTableManager get syncErrors =>
      $$SyncErrorsTableTableManager(_db, _db.syncErrors);
}
