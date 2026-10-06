import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/presentation/account_picker.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_page.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_tables.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statements_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

LedgerDate _today() => LedgerDate.fromDateTime(DateTime.now());

/// Tallies / does not tally, as a strip under the controls.
class _TallyStrip extends StatelessWidget {
  const _TallyStrip({required this.left, required this.right});

  final Money left;
  final Money right;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ok = left == right;
    final tokens = MkTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MkSpacing.md),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.error_outline,
            color: ok ? tokens.jama : tokens.udhaar,
            size: 18,
          ),
          const SizedBox(width: MkSpacing.sm),
          Text(
            ok
                ? l10n.stmtTallies
                : l10n.stmtDoesNotTally((left - right).abs().format()),
            key: const ValueKey('statement-tally'),
          ),
        ],
      ),
    );
  }
}

class TrialBalanceScreen extends ConsumerStatefulWidget {
  const TrialBalanceScreen({super.key});

  @override
  ConsumerState<TrialBalanceScreen> createState() => _TrialBalanceState();
}

class _TrialBalanceState extends ConsumerState<TrialBalanceScreen> {
  LedgerDate _asOf = _today();
  bool _groupsOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tb = ref
        .watch(trialBalanceProvider(asOf: _asOf, withAccounts: !_groupsOnly))
        .value;
    return StatementPage(
      title: l10n.tbTitle,
      fileStem: 'trial-balance-$_asOf',
      filterLines: [l10n.stmtAsOf('$_asOf')],
      table: tb == null ? null : StatementTables.trialBalance(l10n, tb),
      summary: tb == null
          ? null
          : _TallyStrip(left: tb.debit, right: tb.credit),
      controls: [
        StatementDateButton(
          date: _asOf,
          onChanged: (d) => setState(() => _asOf = d),
        ),
        FilterChip(
          key: const ValueKey('tb-groups-only'),
          label: Text(l10n.tbGroupsOnly),
          selected: _groupsOnly,
          onSelected: (v) => setState(() => _groupsOnly = v),
        ),
      ],
    );
  }
}

class ProfitLossScreen extends ConsumerStatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  ConsumerState<ProfitLossScreen> createState() => _ProfitLossState();
}

class _ProfitLossState extends ConsumerState<ProfitLossScreen> {
  LedgerDate _from = FinancialYear.containing(_today()).start;
  LedgerDate _to = _today();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pl = ref.watch(profitAndLossProvider(from: _from, to: _to)).value;
    return StatementPage(
      title: l10n.plTitle,
      fileStem: 'profit-loss-$_from-$_to',
      filterLines: ['$_from – $_to'],
      table: pl == null ? null : StatementTables.profitAndLoss(l10n, pl),
      controls: [
        PeriodChips(
          from: _from,
          to: _to,
          onChanged: (f, t) => setState(() {
            _from = f;
            _to = t;
          }),
        ),
      ],
    );
  }
}

class BalanceSheetScreen extends ConsumerStatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  ConsumerState<BalanceSheetScreen> createState() => _BalanceSheetState();
}

class _BalanceSheetState extends ConsumerState<BalanceSheetScreen> {
  LedgerDate _asOf = _today();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bs = ref.watch(balanceSheetProvider(asOf: _asOf)).value;
    final chart = ref.watch(chartProvider).value;
    return StatementPage(
      title: l10n.bsTitle,
      fileStem: 'balance-sheet-$_asOf',
      filterLines: [l10n.stmtAsOf('$_asOf')],
      table: bs == null ? null : StatementTables.balanceSheet(l10n, bs, chart),
      summary: bs == null
          ? null
          : _TallyStrip(left: bs.assets, right: bs.liabilitiesAndCapital),
      controls: [
        StatementDateButton(
          date: _asOf,
          onChanged: (d) => setState(() => _asOf = d),
        ),
      ],
    );
  }
}

class AccountLedgerScreen extends ConsumerStatefulWidget {
  const AccountLedgerScreen({this.accountId, super.key});

  final String? accountId;

  @override
  ConsumerState<AccountLedgerScreen> createState() => _LedgerState();
}

class _LedgerState extends ConsumerState<AccountLedgerScreen> {
  late String? _accountId = widget.accountId;
  LedgerDate _from = FinancialYear.containing(_today()).start;
  LedgerDate _to = _today();
  final _search = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chart = ref.watch(chartProvider).value;
    final id = _accountId;
    final ledger = id == null
        ? null
        : ref.watch(accountLedgerProvider(id, from: _from, to: _to)).value;
    final account = id == null ? null : chart?.byId(id);
    if (account != null && _search.text.isEmpty) {
      _search.text = account.label;
    }
    return StatementPage(
      title: account == null
          ? l10n.ledgerTitle
          : '${l10n.ledgerTitle} · ${account.label}',
      fileStem: 'ledger-${account?.name ?? ''}-$_from-$_to',
      filterLines: ['$_from – $_to'],
      table: id == null
          ? const ReportTable(columns: [], rows: [])
          : ledger == null
          ? null
          : StatementTables.ledger(l10n, ledger, from: _from),
      controls: [
        if (chart != null)
          SizedBox(
            width: 320,
            child: AccountPicker(
              key: const ValueKey('ledger-account'),
              accounts: chart.accounts,
              chart: chart,
              controller: _search,
              focusNode: _focus,
              onPicked: (a) => setState(() => _accountId = a.id),
            ),
          ),
        PeriodChips(
          from: _from,
          to: _to,
          onChanged: (f, t) => setState(() {
            _from = f;
            _to = t;
          }),
        ),
      ],
    );
  }
}

class GroupSummaryScreen extends ConsumerStatefulWidget {
  const GroupSummaryScreen({super.key});

  @override
  ConsumerState<GroupSummaryScreen> createState() => _GroupSummaryState();
}

class _GroupSummaryState extends ConsumerState<GroupSummaryScreen> {
  String? _groupId;
  LedgerDate _asOf = _today();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chart = ref.watch(chartProvider).value;
    final groups = chart?.orderedGroups ?? const [];
    final groupId = _groupId ?? (groups.isEmpty ? null : groups.first.id);
    final rows = groupId == null
        ? null
        : ref.watch(groupSummaryProvider(groupId, asOf: _asOf)).value;
    final name = groupId == null ? '' : chart?.groups[groupId]?.name ?? '';
    return StatementPage(
      title: '${l10n.groupSummaryTitle} · $name',
      fileStem: 'group-summary-$name-$_asOf',
      filterLines: [l10n.stmtAsOf('$_asOf')],
      table: rows == null ? null : StatementTables.groupSummary(l10n, rows),
      controls: [
        DropdownButton<String>(
          key: const ValueKey('group-pick'),
          value: groupId,
          items: [
            for (final g in groups)
              DropdownMenuItem(
                value: g.id,
                child: Text('${g.parentId == null ? '' : '   '}${g.name}'),
              ),
          ],
          onChanged: (v) => setState(() => _groupId = v),
        ),
        StatementDateButton(
          date: _asOf,
          onChanged: (d) => setState(() => _asOf = d),
        ),
      ],
    );
  }
}
