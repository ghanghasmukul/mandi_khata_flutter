import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;
import 'package:uuid/uuid.dart';

/// Why an own account cannot be saved.
enum AccountProblem { nameEmpty, nameTaken, groupNotAllowed, notOwn }

/// The chart of accounts of one business in the local database, and the
/// account balances from the journal.
///
/// Party, cash / bank and system accounts are made by the server (step 3.1);
/// until their rows sync, the chart is completed from the parties, the
/// bank accounts and the built-in list, with the same ids. The business's
/// own accounts are added here (`entries.reverse`, audited).
class ChartRepository {
  ChartRepository(this._db);

  final PowerSyncDatabase _db;

  static const tables = {
    'account_groups',
    'accounts',
    'parties',
    'party_roles',
    'bank_accounts',
    'expense_categories',
  };

  /// Groups an own account may not be put in: cash / bank accounts come
  /// from the bank accounts screen, parties from the parties screen.
  static const Set<AccountGroup> lockedGroups = {
    AccountGroup.cashInHand,
    AccountGroup.bankAccounts,
    AccountGroup.sundryDebtors,
    AccountGroup.sundryCreditors,
  };

  /// The chart of [tenantId], live.
  Stream<Chart> watch(String tenantId) => _db
      .watch('SELECT 1', triggerOnTables: tables)
      .asyncMap((_) => _db.readTransaction((tx) => load(tx, tenantId)));

  /// The chart of [tenantId] as it is in [tx].
  static Future<Chart> load(SqliteReadContext tx, String tenantId) async {
    final groupRows = await tx.getAll(
      'SELECT id, code, name, parent_id, nature, is_system '
      'FROM account_groups WHERE tenant_id = ?',
      [tenantId],
    );
    final groups = <String, ChartGroup>{
      for (final g in AccountGroup.values)
        JournalWriter.groupId(tenantId, g): ChartGroup(
          id: JournalWriter.groupId(tenantId, g),
          code: g.code,
          name: g.name,
          nature: g.nature,
          parentId: g.parent == null
              ? null
              : JournalWriter.groupId(tenantId, g.parent!),
        ),
      for (final r in groupRows)
        r['id']! as String: ChartGroup(
          id: r['id']! as String,
          code: r['code']! as String,
          name: r['name']! as String,
          parentId: r['parent_id'] as String?,
          nature: AccountNature.values.byName(r['nature']! as String),
          isSystem: r['is_system'] == 1,
        ),
    };
    final chart = Chart(groups: groups.values.toList(), accounts: const []);

    final rows = await tx.getAll(
      'SELECT a.id, a.name, a.group_id, a.party_id, a.bank_account_id, '
      'a.system_code, a.is_system, a.is_active, a.expense_category_id, '
      'p.code AS party_code, '
      'b.kind AS book_kind, b.is_active AS book_active '
      'FROM accounts a '
      'LEFT JOIN parties p ON p.id = a.party_id AND p.tenant_id = a.tenant_id '
      'LEFT JOIN bank_accounts b ON b.id = a.bank_account_id '
      'AND b.tenant_id = a.tenant_id '
      'WHERE a.tenant_id = ?',
      [tenantId],
    );
    final entries = <String, ChartEntry>{};
    for (final r in rows) {
      final id = r['id']! as String;
      final partyId = r['party_id'] as String?;
      final bankId = r['bank_account_id'] as String?;
      final systemCode = r['system_code'] as String?;
      final system = systemCode == null
          ? null
          : SystemAccount.fromCode(systemCode);
      final groupId = r['group_id']! as String;
      final JournalAccount account;
      final VoucherAccountKind kind;
      if (partyId != null) {
        account = PartyAccount(partyId);
        kind = VoucherAccountKind.party;
      } else if (bankId != null) {
        account = BookAccount(bankId);
        kind = r['book_kind'] == 'bank'
            ? VoucherAccountKind.bank
            : VoucherAccountKind.cash;
      } else if (system != null) {
        account = SystemJournalAccount(system);
        kind = chart.kindForGroup(groupId);
      } else {
        account = ChartAccount(id);
        kind = chart.kindForGroup(groupId);
      }
      entries[id] = ChartEntry(
        id: id,
        name: r['name']! as String,
        groupId: groupId,
        account: account,
        kind: kind,
        isActive: r['is_active'] == 1 && r['book_active'] != 0,
        isSystem: r['is_system'] == 1,
        code: r['party_code'] as String?,
        expenseCategoryId: r['expense_category_id'] as String?,
      );
    }

    // Rows the server has not sent yet: same ids, built-in groups.
    for (final a in SystemAccount.values) {
      final account = SystemJournalAccount(a);
      final id = JournalWriter.accountId(tenantId, account);
      final groupId = JournalWriter.groupId(tenantId, a.group);
      entries.putIfAbsent(
        id,
        () => ChartEntry(
          id: id,
          name: a.name,
          groupId: groupId,
          account: account,
          kind: chart.kindForGroup(groupId),
          isSystem: true,
          synced: false,
        ),
      );
    }
    final parties = await tx.getAll(
      'SELECT p.id, p.name, p.code, p.deleted_at, EXISTS (SELECT 1 FROM '
      'party_roles r WHERE r.tenant_id = p.tenant_id AND r.party_id = p.id '
      "AND r.deleted_at IS NULL AND r.role IN ('customer', 'buyer')) AS debtor "
      'FROM parties p WHERE p.tenant_id = ?',
      [tenantId],
    );
    for (final p in parties) {
      final account = PartyAccount(p['id']! as String);
      final id = JournalWriter.accountId(tenantId, account);
      entries.putIfAbsent(
        id,
        () => ChartEntry(
          id: id,
          name: p['name']! as String,
          code: p['code'] as String?,
          groupId: JournalWriter.groupId(
            tenantId,
            p['debtor'] == 1
                ? AccountGroup.sundryDebtors
                : AccountGroup.sundryCreditors,
          ),
          account: account,
          kind: VoucherAccountKind.party,
          isActive: p['deleted_at'] == null,
          synced: false,
        ),
      );
    }
    final books = await tx.getAll(
      'SELECT id, name, kind, is_active FROM bank_accounts WHERE tenant_id = ?',
      [tenantId],
    );
    for (final b in books) {
      final account = BookAccount(b['id']! as String);
      final id = JournalWriter.accountId(tenantId, account);
      final isCash = b['kind'] == 'cash';
      entries.putIfAbsent(
        id,
        () => ChartEntry(
          id: id,
          name: b['name']! as String,
          groupId: JournalWriter.groupId(
            tenantId,
            isCash ? AccountGroup.cashInHand : AccountGroup.bankAccounts,
          ),
          account: account,
          kind: isCash ? VoucherAccountKind.cash : VoucherAccountKind.bank,
          isActive: b['is_active'] == 1,
          synced: false,
        ),
      );
    }
    final categories = await tx.getAll(
      'SELECT id, name, group_code, is_active FROM expense_categories '
      'WHERE tenant_id = ?',
      [tenantId],
    );
    for (final c in categories) {
      final categoryId = c['id']! as String;
      final id = JournalWriter.expenseAccountId(tenantId, categoryId);
      final group = AccountGroup.fromCode(c['group_code']! as String);
      entries.putIfAbsent(
        id,
        () => ChartEntry(
          id: id,
          name: c['name']! as String,
          groupId: JournalWriter.groupId(
            tenantId,
            group ?? AccountGroup.indirectExpenses,
          ),
          account: ChartAccount(id),
          kind: VoucherAccountKind.other,
          isActive: c['is_active'] == 1,
          synced: false,
          expenseCategoryId: categoryId,
        ),
      );
    }
    final sorted = entries.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Chart(groups: groups.values.toList(), accounts: sorted);
  }

  /// Σ debit / Σ credit per account id over journal entries dated
  /// [from]..[to] (either open). [excludeSourceTypes] leaves out e.g. the
  /// year-close entries for a profit and loss.
  static Future<Map<String, AccountTotals>> totals(
    SqliteReadContext tx,
    String tenantId, {
    LedgerDate? from,
    LedgerDate? to,
    Set<String> excludeSourceTypes = const {},
  }) async {
    final exclude = excludeSourceTypes.toList();
    final rows = await tx.getAll(
      'SELECT l.account_id, SUM(l.debit_paise) AS d, SUM(l.credit_paise) AS c '
      'FROM journal_lines l JOIN journal_entries e '
      'ON e.id = l.journal_entry_id AND e.tenant_id = l.tenant_id '
      'WHERE l.tenant_id = ? '
      'AND (? IS NULL OR e.entry_date >= ?) '
      'AND (? IS NULL OR e.entry_date <= ?) '
      '${exclude.isEmpty ? '' : 'AND e.source_type NOT IN '
                '(${List.filled(exclude.length, '?').join(', ')}) '}'
      'GROUP BY l.account_id',
      [
        tenantId,
        from?.toString(),
        from?.toString(),
        to?.toString(),
        to?.toString(),
        ...exclude,
      ],
    );
    return {
      for (final r in rows)
        r['account_id']! as String: AccountTotals(
          Money(r['d']! as int),
          Money(r['c']! as int),
        ),
    };
  }

  /// Adds an own account (needs `entries.reverse`); returns its id or why
  /// not.
  Future<({String? id, AccountProblem? problem})> addAccount(
    WriteContext ctx, {
    required String name,
    required String groupId,
    DateTime? now,
  }) async {
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final chart = await load(tx, ctx.tenantId);
      final problem = _check(chart, name, groupId);
      if (problem != null) return (id: null, problem: problem);
      final id = const Uuid().v4();
      final at = when.toIso8601String();
      await tx.execute(
        'INSERT INTO accounts (id, tenant_id, group_id, name, is_system, '
        'is_active, created_by, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, 0, 1, ?, ?, ?)',
        [id, ctx.tenantId, groupId, name.trim(), ctx.userId, at, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'accounts',
        rowId: id,
        action: AuditAction.insert,
        after: {'name': name.trim(), 'group_id': groupId},
        at: when,
      );
      return (id: id, problem: null);
    });
  }

  /// Renames, moves or switches off an own account; renames a system one.
  Future<AccountProblem?> updateAccount(
    WriteContext ctx,
    String id, {
    String? name,
    String? groupId,
    bool? isActive,
    DateTime? now,
  }) async {
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final chart = await load(tx, ctx.tenantId);
      final a = chart.byId(id);
      if (a == null || !a.synced) return AccountProblem.notOwn;
      if (!a.isOwn && (groupId != null || isActive != null)) {
        return AccountProblem.notOwn;
      }
      if (a.account is PartyAccount ||
          a.account is BookAccount ||
          a.expenseCategoryId != null) {
        return AccountProblem.notOwn;
      }
      final newName = name?.trim() ?? a.name;
      final newGroup = groupId ?? a.groupId;
      final problem = _check(chart, newName, newGroup, except: id);
      if (problem != null && (groupId != null || name != null)) return problem;
      final before = {
        'name': a.name,
        'group_id': a.groupId,
        'is_active': a.isActive,
      };
      final after = {
        'name': newName,
        'group_id': newGroup,
        'is_active': isActive ?? a.isActive,
      };
      await tx.execute(
        'UPDATE accounts SET name = ?, group_id = ?, is_active = ?, '
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [
          newName,
          newGroup,
          if (isActive ?? a.isActive) 1 else 0,
          when.toIso8601String(),
          ctx.tenantId,
          id,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'accounts',
        rowId: id,
        action: AuditAction.update,
        before: before,
        after: after,
        at: when,
      );
      return null;
    });
  }

  static AccountProblem? _check(
    Chart chart,
    String name,
    String groupId, {
    String? except,
  }) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return AccountProblem.nameEmpty;
    final group = chart.groups[groupId];
    if (group == null) return AccountProblem.groupNotAllowed;
    for (final locked in lockedGroups) {
      if (chart.groupWithin(groupId, locked)) {
        return AccountProblem.groupNotAllowed;
      }
    }
    if (chart.accounts.any(
      (a) => a.id != except && a.name.trim().toLowerCase() == n,
    )) {
      return AccountProblem.nameTaken;
    }
    return null;
  }
}
