import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// One account group of the business (`account_groups`, or the built-in
/// group when its row has not synced yet).
@immutable
class ChartGroup {
  const ChartGroup({
    required this.id,
    required this.code,
    required this.name,
    required this.nature,
    this.parentId,
    this.isSystem = true,
  });

  final String id;
  final String code;
  final String name;
  final String? parentId;
  final AccountNature nature;
  final bool isSystem;

  /// The built-in group this is, or null for a group the business added.
  AccountGroup? get system => AccountGroup.fromCode(code);
}

/// One account of the chart, whatever made it: a party, a cash / bank
/// book, a system account or one the business added.
@immutable
class ChartEntry {
  const ChartEntry({
    required this.id,
    required this.name,
    required this.groupId,
    required this.account,
    required this.kind,
    this.isActive = true,
    this.isSystem = false,
    this.code,
    this.synced = true,
    this.expenseCategoryId,
  });

  /// `accounts.id` (deterministic for party, book and system accounts).
  final String id;
  final String name;
  final String groupId;

  /// What a journal line on this account is (party, book, system, other).
  final JournalAccount account;
  final VoucherAccountKind kind;
  final bool isActive;
  final bool isSystem;

  /// A party's code, shown next to the name.
  final String? code;

  /// False when the server has not sent the account row yet (a new party
  /// or bank account); its id is already known.
  final bool synced;

  /// Set on an expense category's account: edited through the category.
  final String? expenseCategoryId;

  String? get partyId => switch (account) {
    PartyAccount(:final partyId) => partyId,
    _ => null,
  };

  String? get bankAccountId => switch (account) {
    BookAccount(:final bankAccountId) => bankAccountId,
    _ => null,
  };

  /// A business's own account (not a party, book or system one): may be
  /// renamed, moved or switched off from the chart screen.
  bool get isOwn =>
      account is ChartAccount && !isSystem && expenseCategoryId == null;

  String get label => code == null ? name : '$name ($code)';
}

/// The whole chart of one business, looked up by id.
@immutable
class Chart {
  Chart({required List<ChartGroup> groups, required List<ChartEntry> accounts})
    : groups = {for (final g in groups) g.id: g},
      accounts = List.unmodifiable(accounts),
      _byId = {for (final a in accounts) a.id: a};

  final Map<String, ChartGroup> groups;
  final List<ChartEntry> accounts;
  final Map<String, ChartEntry> _byId;

  ChartEntry? byId(String id) => _byId[id];

  ChartGroup? groupOf(ChartEntry a) => groups[a.groupId];

  AccountNature natureOf(ChartEntry a) =>
      groupOf(a)?.nature ?? AccountNature.asset;

  /// The top-level group [groupId] sits under (itself when top-level).
  ChartGroup? rootOf(String groupId) {
    var g = groups[groupId];
    final seen = <String>{};
    while (g != null && g.parentId != null && seen.add(g.id)) {
      final parent = groups[g.parentId];
      if (parent == null) break;
      g = parent;
    }
    return g;
  }

  /// Whether group [groupId] is [system] or sits under it.
  bool groupWithin(String groupId, AccountGroup system) {
    String? id = groupId;
    final seen = <String>{};
    while (id != null && seen.add(id)) {
      final g = groups[id];
      if (g == null) return false;
      if (g.code == system.code) return true;
      id = g.parentId;
    }
    return false;
  }

  /// [groupId] and every group under it.
  Set<String> groupAndChildren(String groupId) {
    final out = {groupId};
    var grew = true;
    while (grew) {
      grew = false;
      for (final g in groups.values) {
        if (g.parentId != null && out.contains(g.parentId) && out.add(g.id)) {
          grew = true;
        }
      }
    }
    return out;
  }

  /// Groups in display order: parents first, each followed by its children.
  List<ChartGroup> get orderedGroups {
    final roots = groups.values.where((g) => g.parentId == null).toList()
      ..sort(_byOrder);
    final out = <ChartGroup>[];
    void visit(ChartGroup g) {
      out.add(g);
      (groups.values.where((c) => c.parentId == g.id).toList()..sort(_byOrder))
          .forEach(visit);
    }

    roots.forEach(visit);
    return out;
  }

  static int _byOrder(ChartGroup a, ChartGroup b) {
    final ai = a.system?.index ?? 1000;
    final bi = b.system?.index ?? 1000;
    return ai != bi ? ai.compareTo(bi) : a.name.compareTo(b.name);
  }

  /// The voucher-rule kind of an account in [groupId] that is not a party or
  /// a book: Sales / Purchase by group, else other.
  VoucherAccountKind kindForGroup(String groupId) {
    if (groupWithin(groupId, AccountGroup.salesAccounts)) {
      return VoucherAccountKind.sales;
    }
    if (groupWithin(groupId, AccountGroup.purchaseAccounts)) {
      return VoucherAccountKind.purchase;
    }
    return VoucherAccountKind.other;
  }
}

/// Σ debit and Σ credit of one account over some dates.
@immutable
class AccountTotals {
  const AccountTotals(this.debit, this.credit);

  static const zero = AccountTotals(Money.zero, Money.zero);

  final Money debit;
  final Money credit;

  /// Debit minus credit: positive = a debit balance.
  Money get net => debit - credit;

  AccountTotals operator +(AccountTotals o) =>
      AccountTotals(debit + o.debit, credit + o.credit);
}
