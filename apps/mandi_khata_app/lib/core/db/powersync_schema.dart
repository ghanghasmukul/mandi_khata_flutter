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
      'revoked_at': _t,
      'revoked_by': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant': ['tenant_id'],
    },
  ),
  SyncedTable(
    'member_invites',
    {
      'tenant_id': _t,
      'phone': _t,
      'full_name': _t,
      'role': _t,
      'custom_permissions': _json,
      'status': _t,
      'expires_at': _t,
      'accepted_by': _t,
      'accepted_at': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant': ['tenant_id', 'status'],
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
      'statement_mapping': _json,
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
      'loan_id': _t,
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
      'voucher_id': _t,
      'expense_id': _t,
    },
    indexes: {
      'account_date': ['tenant_id', 'account_id', 'entry_date'],
      'payment': ['payment_id'],
      'voucher': ['voucher_id'],
      'expense': ['expense_id'],
    },
    appendOnly: true,
  ),
  SyncedTable(
    'loans',
    {
      'tenant_id': _t,
      'loan_no': _t,
      'party_id': _t,
      'issue_date': _t,
      'principal_paise': _i,
      'purpose': _t,
      'due_date': _t,
      'guarantor_party_id': _t,
      'interest_config_snapshot': _json,
      'status': _t,
      'closed_on': _t,
      'close_reason': _t,
      'notes': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'party': ['tenant_id', 'party_id'],
      'status': ['tenant_id', 'status'],
      'loan_no': ['tenant_id', 'loan_no'],
    },
  ),
  SyncedTable(
    'loan_rate_changes',
    {
      'tenant_id': _t,
      'loan_id': _t,
      'effective_date': _t,
      'rate_pa': _t,
      'reason': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
    },
    indexes: {
      'loan': ['tenant_id', 'loan_id'],
    },
    appendOnly: true,
  ),
  SyncedTable(
    'interest_postings',
    {
      'tenant_id': _t,
      'party_id': _t,
      'loan_id': _t,
      'kind': _t,
      'period_from': _t,
      'period_to': _t,
      'amount_paise': _i,
      'rate_pa': _t,
      'method': _t,
      'reason': _t,
      'period_key': _t,
      'batch_id': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
    },
    indexes: {
      'party': ['tenant_id', 'party_id'],
      'loan': ['tenant_id', 'loan_id'],
      'key': ['tenant_id', 'period_key'],
    },
    appendOnly: true,
  ),
  SyncedTable(
    'account_groups',
    {
      'tenant_id': _t,
      'code': _t,
      'name': _t,
      'parent_id': _t,
      'nature': _t,
      'is_system': _bool,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant': ['tenant_id', 'code'],
    },
  ),
  SyncedTable(
    'accounts',
    {
      'tenant_id': _t,
      'group_id': _t,
      'name': _t,
      'party_id': _t,
      'bank_account_id': _t,
      'system_code': _t,
      'is_system': _bool,
      'is_active': _bool,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
      'expense_category_id': _t,
    },
    indexes: {
      'tenant': ['tenant_id', 'group_id'],
      'party': ['tenant_id', 'party_id'],
    },
  ),
  SyncedTable(
    'journal_entries',
    {
      'tenant_id': _t,
      'source_key': _t,
      'source_type': _t,
      'voucher_id': _t,
      'entry_date': _t,
      'narration': _t,
      'reverses_id': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'lock_reason': _t,
    },
    indexes: {
      'date': ['tenant_id', 'entry_date'],
      'key': ['tenant_id', 'source_key'],
    },
    appendOnly: true,
  ),
  SyncedTable(
    'journal_lines',
    {
      'tenant_id': _t,
      'journal_entry_id': _t,
      'line_no': _i,
      'account_id': _t,
      'debit_paise': _i,
      'credit_paise': _i,
      'memo': _t,
      'created_by': _t,
      'created_at': _t,
    },
    indexes: {
      'account': ['tenant_id', 'account_id'],
      'entry': ['journal_entry_id'],
    },
    appendOnly: true,
  ),
  SyncedTable(
    'vouchers',
    {
      'tenant_id': _t,
      'voucher_type': _t,
      'voucher_no': _t,
      'entry_date': _t,
      'narration': _t,
      'total_paise': _i,
      'status': _t,
      'reversed_at': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'date': ['tenant_id', 'entry_date'],
    },
  ),
  SyncedTable(
    'bank_statement_lines',
    {
      'tenant_id': _t,
      'bank_account_id': _t,
      'txn_date': _t,
      'direction': _t,
      'amount_paise': _i,
      'reference': _t,
      'description': _t,
      'balance_paise': _i,
      'import_batch': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
    },
    indexes: {
      'account': ['tenant_id', 'bank_account_id', 'txn_date'],
    },
    appendOnly: true,
  ),
  SyncedTable(
    'bank_reconciliations',
    {
      'tenant_id': _t,
      'bank_account_id': _t,
      'book_line_id': _t,
      'statement_line_id': _t,
      'reconciled_on': _t,
      'deleted_at': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'account': ['tenant_id', 'bank_account_id'],
      'book': ['book_line_id'],
    },
  ),
  SyncedTable(
    'cash_counts',
    {
      'tenant_id': _t,
      'count_date': _t,
      'bank_account_id': _t,
      'denominations': _json,
      'counted_paise': _i,
      'book_paise': _i,
      'difference_paise': _i,
      'voucher_id': _t,
      'note': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'date': ['tenant_id', 'count_date'],
    },
  ),
  SyncedTable(
    'expense_categories',
    {
      'tenant_id': _t,
      'code': _t,
      'name': _t,
      'group_code': _t,
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
    'recurring_expenses',
    {
      'tenant_id': _t,
      'category_id': _t,
      'amount_paise': _i,
      'mode': _t,
      'bank_account_id': _t,
      'paid_to': _t,
      'narration': _t,
      'day_of_month': _i,
      'start_date': _t,
      'end_date': _t,
      'is_active': _bool,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant': ['tenant_id'],
    },
  ),
  SyncedTable(
    'expenses',
    {
      'tenant_id': _t,
      'expense_no': _t,
      'entry_date': _t,
      'category_id': _t,
      'amount_paise': _i,
      'mode': _t,
      'bank_account_id': _t,
      'paid_to': _t,
      'narration': _t,
      'bill_path': _t,
      'recurring_id': _t,
      'period': _t,
      'status': _t,
      'reversed_at': _t,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'date': ['tenant_id', 'entry_date'],
      'recurring': ['recurring_id', 'period'],
    },
  ),
  SyncedTable(
    'financial_years',
    {
      'tenant_id': _t,
      'start_date': _t,
      'end_date': _t,
      'status': _t,
      'closed_at': _t,
      'closed_by': _t,
      'closing_entry_id': _t,
      'profit_paise': _i,
      'device_id': _t,
      'created_by': _t,
      'created_at': _t,
      'updated_at': _t,
    },
    indexes: {
      'tenant': ['tenant_id', 'start_date'],
    },
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

/// Bill photos waiting to go to Supabase Storage (step 3.4). Kept on this
/// device only; the expense row already carries the path.
const billUploadsTable = Table.localOnly('bill_uploads', [
  Column.text('tenant_id'),
  Column.text('expense_id'),
  Column.text('path'),
  Column.text('content_type'),
  // The photo, base64 (also what the app shows until it can download it).
  Column.text('data'),
  Column.text('created_at'),
  Column.text('uploaded_at'),
  Column.integer('attempts'),
  Column.text('last_error'),
]);

final powerSyncSchema = Schema([
  for (final table in syncedTables) table.toPowerSync(),
  syncErrorsTable,
  billUploadsTable,
]);

/// Looks up a synced table by name, or null for local-only / unknown tables.
SyncedTable? syncedTable(String name) {
  for (final table in syncedTables) {
    if (table.name == name) return table;
  }
  return null;
}
