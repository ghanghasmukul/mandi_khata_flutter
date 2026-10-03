import 'package:powersync/powersync.dart';

/// How a Postgres column is stored in the local SQLite database.
///
/// PowerSync keeps everything as SQLite text / integer / real. The two
/// special kinds below need converting back when a change is uploaded:
/// [json] columns hold JSON text locally but are `jsonb` on the server, and
/// [boolean] columns hold 0/1 locally but are `boolean` on the server.
enum ColumnKind { text, integer, real, json, boolean }

/// A synced table: its columns (besides `id`) and local indexes.
class SyncedTable {
  const SyncedTable(
    this.name,
    this.columns, {
    this.indexes = const {},
    this.appendOnly = false,
  });

  final String name;
  final Map<String, ColumnKind> columns;

  /// Rows are only ever inserted. The server grants no UPDATE on these
  /// tables, so uploads must be a plain INSERT, never an upsert.
  final bool appendOnly;

  /// Index name → indexed columns.
  final Map<String, List<String>> indexes;

  Table toPowerSync() => Table(
    name,
    [
      for (final MapEntry(key: column, value: kind) in columns.entries)
        switch (kind) {
          ColumnKind.integer || ColumnKind.boolean => Column.integer(column),
          ColumnKind.real => Column.real(column),
          ColumnKind.text || ColumnKind.json => Column.text(column),
        },
    ],
    indexes: [
      for (final MapEntry(key: name, value: columns) in indexes.entries)
        Index(name, [for (final c in columns) IndexedColumn(c)]),
    ],
  );
}

const ColumnKind _t = ColumnKind.text;
const ColumnKind _i = ColumnKind.integer;
const ColumnKind _json = ColumnKind.json;
const ColumnKind _bool = ColumnKind.boolean;

/// Every table synced from Supabase. Must match the SQL in
/// `supabase/migrations/`, the `powersync` publication and
/// `powersync/sync-streams.yaml` (a test checks the Drift side).
const syncedTables = <SyncedTable>[
  SyncedTable('tenants', {
    'name': _t,
    'legal_name': _t,
    'gstin': _t,
    'address': _t,
    'state_code': _t,
    'mandi_name': _t,
    'phone': _t,
    'plan_code': _t,
    'status': _t,
    'trial_ends_at': _t,
    'created_by': _t,
    'created_at': _t,
    'updated_at': _t,
  }),
  SyncedTable('app_users', {
    'phone': _t,
    'full_name': _t,
    'preferred_language': _t,
    'created_at': _t,
    'updated_at': _t,
  }),
  SyncedTable(
    'tenant_members',
    {
      'tenant_id': _t,
      'user_id': _t,
      'role': _t,
      'custom_permissions': _json,
      'is_active': _bool,
      'device_limit': _i,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'user': ['user_id', 'tenant_id'],
    },
  ),
  SyncedTable(
    'devices',
    {
      'tenant_id': _t,
      'user_id': _t,
      'device_code': _t,
      'platform': _t,
      'name': _t,
      'last_seen_at': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant': ['tenant_id'],
    },
  ),
  SyncedTable(
    'settings',
    {
      'tenant_id': _t,
      'scope': _t,
      'scope_id': _t,
      'key': _t,
      'value': _json,
      'updated_by': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'lookup': ['tenant_id', 'scope', 'scope_id', 'key'],
    },
  ),
  SyncedTable(
    'audit_log',
    {
      'tenant_id': _t,
      'table_name': _t,
      'row_id': _t,
      'action': _t,
      'before': _json,
      'after': _json,
      'user_id': _t,
      'device_id': _t,
      'role': _t,
      'created_at': _t,
    },
    indexes: {
      'tenant_time': ['tenant_id', 'created_at'],
      'row': ['tenant_id', 'table_name', 'row_id'],
    },
    appendOnly: true,
  ),
  SyncedTable(
    'parties',
    {
      'tenant_id': _t,
      'code': _t,
      'name': _t,
      'father_or_husband_name': _t,
      'relation': _t,
      'village': _t,
      'district': _t,
      'state': _t,
      'mobile': _t,
      'alt_mobile': _t,
      'aadhaar_last4': _t,
      'bank_name': _t,
      'bank_account_masked': _t,
      'ifsc': _t,
      'gstin': _t,
      'notes': _t,
      'party_group_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
      'deleted_at': _t,
    },
    indexes: {
      'tenant_name': ['tenant_id', 'name'],
      'tenant_code': ['tenant_id', 'code'],
    },
  ),
  SyncedTable(
    'party_roles',
    {
      'tenant_id': _t,
      'party_id': _t,
      'role': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
      'deleted_at': _t,
    },
    indexes: {
      'party': ['party_id'],
      'tenant_role': ['tenant_id', 'role'],
    },
  ),
  SyncedTable(
    'number_series',
    {
      'tenant_id': _t,
      'series': _t,
      'device_code': _t,
      'next_value': _i,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'device': ['tenant_id', 'series', 'device_code'],
    },
  ),
  SyncedTable(
    'ledger_entries',
    {
      'tenant_id': _t,
      'party_id': _t,
      'entry_date': _t,
      'side': _t,
      'amount_paise': _i,
      'ref_type': _t,
      'ref_id': _t,
      'narration': _t,
      'reverses_id': _t,
      'replaces_id': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'received_at': _t,
    },
    indexes: {
      'party_date': ['tenant_id', 'party_id', 'entry_date'],
      'tenant_date': ['tenant_id', 'entry_date'],
      'reverses': ['reverses_id'],
      'ref': ['ref_id'],
    },
    appendOnly: true,
  ),
  SyncedTable(
    'crops',
    {
      'tenant_id': _t,
      'code': _t,
      'name_en': _t,
      'name_hi': _t,
      'name_pa': _t,
      'unit': _t,
      'msp_or_std_rate': _i,
      'sort_order': _i,
      'is_active': _bool,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant_code': ['tenant_id', 'code'],
    },
  ),
  SyncedTable(
    'lots',
    {
      'tenant_id': _t,
      'lot_no': _t,
      'entry_date': _t,
      'farmer_id': _t,
      'crop_id': _t,
      'bags': _i,
      'qtl_milli': _i,
      'qtl_from_bags': _bool,
      'rate_paise_per_qtl': _i,
      'buyer_party_id': _t,
      'j_form_no': _t,
      'vehicle_no': _t,
      'notes': _t,
      'status': _t,
      'charges_snapshot': _json,
      'gross': _i,
      'commission': _i,
      'net_to_farmer': _i,
      'buyer_total': _i,
      'posted_at': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant_date': ['tenant_id', 'entry_date'],
      'farmer': ['tenant_id', 'farmer_id'],
      'lot_no': ['tenant_id', 'lot_no'],
    },
  ),
  SyncedTable(
    'bank_accounts',
    {
      'tenant_id': _t,
      'kind': _t,
      'name': _t,
      'bank_name': _t,
      'account_last4': _t,
      'ifsc': _t,
      'sort_order': _i,
      'is_active': _bool,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant': ['tenant_id', 'sort_order'],
    },
  ),
  SyncedTable(
    'payments',
    {
      'tenant_id': _t,
      'receipt_no': _t,
      'entry_date': _t,
      'party_id': _t,
      'direction': _t,
      'mode': _t,
      'amount_paise': _i,
      'bank_account_id': _t,
      'reference': _t,
      'cheque_no': _t,
      'cheque_date': _t,
      'cheque_status': _t,
      'narration': _t,
      'status': _t,
      'reversed_at': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant_date': ['tenant_id', 'entry_date'],
      'party': ['tenant_id', 'party_id'],
      'receipt_no': ['tenant_id', 'receipt_no'],
    },
  ),
  SyncedTable(
    'cash_bank_entries',
    {
      'tenant_id': _t,
      'account_id': _t,
      'account_kind': _t,
      'entry_date': _t,
      'direction': _t,
      'amount_paise': _i,
      'payment_id': _t,
      'narration': _t,
      'reverses_id': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
    },
    indexes: {
      'account_date': ['tenant_id', 'account_id', 'entry_date'],
      'payment': ['payment_id'],
    },
    appendOnly: true,
  ),
];

/// Changes the server rejected for good (RLS, constraint, bad data). Kept on
/// this device only, so the upload queue never gets stuck behind them.
const syncErrorsTable = Table.localOnly('sync_errors', [
  Column.text('table_name'),
  Column.text('row_id'),
  Column.text('op'),
  Column.text('op_data'),
  Column.text('error_code'),
  Column.text('message'),
  Column.text('created_at'),
  // Rejected changes from one local transaction share a batch: the server
  // applies a transaction all-or-nothing, so it is retried or discarded whole.
  Column.text('batch_id'),
  Column.integer('batch_seq'),
]);

final powerSyncSchema = Schema([
  for (final table in syncedTables) table.toPowerSync(),
  syncErrorsTable,
]);

/// Looks up a synced table by name, or null for local-only / unknown tables.
SyncedTable? syncedTable(String name) {
  for (final table in syncedTables) {
    if (table.name == name) return table;
  }
  return null;
}
