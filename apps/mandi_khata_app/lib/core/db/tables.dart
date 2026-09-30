import 'package:drift/drift.dart';

// Typed Drift views over the tables PowerSync creates. Drift never creates or
// migrates these (see AppDatabase.migration): PowerSync owns the schema, from
// powersync_schema.dart. Column names are the snake_case of the getters.
//
// Timestamps stay ISO-8601 text (CLAUDE.md rule 11); booleans are 0/1;
// JSON columns are text.

class Tenants extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get legalName => text().nullable()();
  TextColumn get gstin => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get stateCode => text().nullable()();
  TextColumn get mandiName => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get planCode => text().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get trialEndsAt => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppUsers extends Table {
  TextColumn get id => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get fullName => text().nullable()();
  TextColumn get preferredLanguage => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TenantMembers extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text()();
  TextColumn get customPermissions => text().nullable()();
  BoolColumn get isActive => boolean().nullable()();
  IntColumn get deviceLimit => integer().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get userId => text()();
  TextColumn get deviceCode => text()();
  TextColumn get platform => text()();
  TextColumn get name => text().nullable()();
  TextColumn get lastSeenAt => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get scope => text()();
  TextColumn get scopeId => text().nullable()();
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AuditEntry')
class AuditLog extends Table {
  @override
  String get tableName => 'audit_log';

  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get tableNameValue => text().named('table_name')();
  TextColumn get rowId => text()();
  TextColumn get action => text()();
  TextColumn get before => text().nullable()();
  TextColumn get after => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get createdAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Parties extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get fatherOrHusbandName => text().nullable()();
  TextColumn get relation => text().nullable()();
  TextColumn get village => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get mobile => text().nullable()();
  TextColumn get altMobile => text().nullable()();
  TextColumn get aadhaarLast4 => text().named('aadhaar_last4').nullable()();
  TextColumn get bankName => text().nullable()();
  TextColumn get bankAccountMasked => text().nullable()();
  TextColumn get ifsc => text().nullable()();
  TextColumn get gstin => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get partyGroupId => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PartyRoles extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get partyId => text()();
  TextColumn get role => text()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('NumberSeriesRow')
class NumberSeries extends Table {
  @override
  String get tableName => 'number_series';

  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get series => text()();
  TextColumn get deviceCode => text()();
  IntColumn get nextValue => integer()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LedgerEntryRow')
class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get partyId => text()();
  TextColumn get entryDate => text()();
  TextColumn get side => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get refType => text()();
  TextColumn get refId => text().nullable()();
  TextColumn get narration => text().nullable()();
  TextColumn get reversesId => text().nullable()();
  TextColumn get replacesId => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get receivedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Crops extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get code => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameHi => text().nullable()();
  TextColumn get namePa => text().nullable()();
  TextColumn get unit => text()();
  IntColumn get mspOrStdRate => integer().nullable()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isActive => boolean()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local-only: uploads the server rejected permanently.
class SyncErrors extends Table {
  TextColumn get id => text()();
  TextColumn get tableNameValue => text().named('table_name')();
  TextColumn get rowId => text()();
  TextColumn get op => text()();
  TextColumn get opData => text().nullable()();
  TextColumn get errorCode => text().nullable()();
  TextColumn get message => text()();
  TextColumn get createdAt => text()();
  TextColumn get batchId => text().nullable()();
  IntColumn get batchSeq => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
