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
  late final $SettingsTable settings = $SettingsTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $PartyRolesTable partyRoles = $PartyRolesTable(this);
  late final $NumberSeriesTable numberSeries = $NumberSeriesTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $CropsTable crops = $CropsTable(this);
  late final $LotsTable lots = $LotsTable(this);
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
    settings,
    auditLog,
    parties,
    partyRoles,
    numberSeries,
    ledgerEntries,
    crops,
    lots,
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
  $$SyncErrorsTableTableManager get syncErrors =>
      $$SyncErrorsTableTableManager(_db, _db.syncErrors);
}
