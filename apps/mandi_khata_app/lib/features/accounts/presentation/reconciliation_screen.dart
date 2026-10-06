import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/accounts/data/reconciliation_repository.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_import_dialog.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_providers.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Bank reconciliation of one bank account: import the statement (columns
/// mapped once per bank), auto-match, match by hand, reconcile lines that
/// never reach the bank, undo. Needs `finance.view`.
class ReconciliationScreen extends ConsumerStatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  ConsumerState<ReconciliationScreen> createState() => _ReconState();
}

class _ReconState extends ConsumerState<ReconciliationScreen> {
  String? _accountId;
  String? _book;
  String? _statement;

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _import(String accountId) async {
    final l10n = AppLocalizations.of(context);
    final file = await ref.read(importFilePickerProvider)();
    if (file == null || !mounted) return;
    final Sheet sheet;
    try {
      sheet = readPickedFile(file);
    } on ImportReadException {
      _snack(l10n.obReadUnreadable);
      return;
    }
    final saved = await ref.read(bankWriterProvider).mapping(accountId);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => StatementImportDialog(
        accountId: accountId,
        sheet: sheet,
        saved: saved,
      ),
    );
  }

  Future<void> _autoMatch(String accountId) async {
    final n = await ref.read(bankWriterProvider).autoMatch(accountId);
    if (mounted) _snack(AppLocalizations.of(context).reconAutoMatched(n));
  }

  Future<void> _match(String accountId) async {
    final ok = await ref
        .read(bankWriterProvider)
        .match(accountId, _book!, _statement!);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _book = null;
        _statement = null;
      });
    } else {
      _snack(AppLocalizations.of(context).reconMismatch);
    }
  }

  Future<void> _withoutStatement(String accountId, List<String> ids) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picked == null) return;
    await ref
        .read(bankWriterProvider)
        .reconcileWithoutStatement(
          accountId,
          ids,
          LedgerDate.fromDateTime(picked),
        );
    if (mounted) setState(() => _book = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final banks = <BankAccount>[
      for (final a
          in ref.watch(bankAccountListProvider()).value ??
              const <BankAccount>[])
        if (a.kind == AccountKind.bank) a,
    ];
    final account =
        banks.where((a) => a.id == _accountId).firstOrNull ?? banks.firstOrNull;
    final state = account == null
        ? ReconState.empty
        : ref.watch(reconStateProvider(account.id)).value ?? ReconState.empty;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(AccountRoutes.hub),
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(
                title: l10n.reconTitle,
                actions: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => context.go(AccountRoutes.hub),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (account == null)
                Expanded(child: MkEmptyState(title: l10n.reconNoBank))
              else ...[
                Padding(
                  padding: const EdgeInsets.all(MkSpacing.md),
                  child: Wrap(
                    spacing: MkSpacing.sm,
                    runSpacing: MkSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: account.id,
                        items: [
                          for (final a in banks)
                            DropdownMenuItem(value: a.id, child: Text(a.name)),
                        ],
                        onChanged: (v) => setState(() {
                          _accountId = v;
                          _book = null;
                          _statement = null;
                        }),
                      ),
                      MkButton(
                        key: const ValueKey('recon-import'),
                        label: l10n.reconImport,
                        icon: Icons.upload_file,
                        variant: MkButtonVariant.secondary,
                        onPressed: () => _import(account.id),
                      ),
                      MkButton(
                        key: const ValueKey('recon-auto'),
                        label: l10n.reconAutoMatch,
                        icon: Icons.auto_fix_high,
                        variant: MkButtonVariant.secondary,
                        onPressed: () => _autoMatch(account.id),
                      ),
                      MkButton(
                        key: const ValueKey('recon-match'),
                        label: l10n.reconMatch,
                        icon: Icons.link,
                        onPressed: _book != null && _statement != null
                            ? () => _match(account.id)
                            : null,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MkSpacing.md),
                  child: Text(
                    l10n.reconPickBoth,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TabBar(
                  tabs: [
                    Tab(text: l10n.reconStatementTab(state.statement.length)),
                    Tab(text: l10n.reconBookTab(state.book.length)),
                    Tab(text: l10n.reconReconciledTab(state.reconciled.length)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _statementList(state),
                      _bookList(account.id, state),
                      _reconciledList(state),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _amount(BuildContext context, bool isIn, Money amount) => Text(
    isIn ? '+${amount.format()}' : '−${amount.format()}',
    style: MkText.mono().copyWith(
      color: isIn ? MkTokens.of(context).jama : MkTokens.of(context).udhaar,
    ),
  );

  Widget _statementList(ReconState state) => RadioGroup<String>(
    groupValue: _statement,
    onChanged: (v) => setState(() => _statement = v),
    child: ListView(
      children: [
        for (final s in state.statement)
          RadioListTile<String>(
            key: ValueKey('recon-st-${s.id}'),
            value: s.id,
            title: Text(
              [s.description, s.reference].whereType<String>().join(' · '),
            ),
            subtitle: Text(AppFormat.ledgerDate(context, s.date)),
            secondary: _amount(context, s.isIn, s.amount),
          ),
      ],
    ),
  );

  Widget _bookList(String accountId, ReconState state) {
    final l10n = AppLocalizations.of(context);
    final open = {for (final b in state.book) b.id: b};
    return RadioGroup<String>(
      groupValue: _book,
      onChanged: (v) => setState(() => _book = v),
      child: ListView(
        children: [
          for (final b in state.book)
            RadioListTile<String>(
              key: ValueKey('recon-bk-${b.id}'),
              value: b.id,
              title: Text(b.text ?? ''),
              subtitle: Text(
                [
                  AppFormat.ledgerDate(context, b.date),
                  if (b.reference?.isNotEmpty ?? false) b.reference!,
                ].join(' · '),
              ),
              secondary: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _amount(context, b.isIn, b.amount),
                  PopupMenuButton<int>(
                    onSelected: (choice) {
                      // A reversal pair is reconciled together.
                      final pair = [
                        for (final o in open.values)
                          if (o.id == b.reversesId || o.reversesId == b.id)
                            o.id,
                      ];
                      unawaited(
                        _withoutStatement(accountId, [
                          b.id,
                          if (choice == 1) ...pair,
                        ]),
                      );
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 0,
                        child: Text(l10n.reconWithoutStatement),
                      ),
                      if (open.values.any(
                        (o) => o.id == b.reversesId || o.reversesId == b.id,
                      ))
                        PopupMenuItem(
                          value: 1,
                          child: Text(l10n.reconWithReversal),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _reconciledList(ReconState state) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        for (final r in state.reconciled)
          ListTile(
            key: ValueKey('recon-done-${r.id}'),
            title: Text(r.book.text ?? ''),
            subtitle: Text(
              [
                l10n.reconOn(AppFormat.ledgerDate(context, r.on)),
                if (r.statement == null) l10n.reconWithoutStatement,
                if (r.statement?.description != null) r.statement!.description!,
              ].join(' · '),
            ),
            leading: _amount(context, r.book.isIn, r.book.amount),
            trailing: TextButton(
              onPressed: () => ref.read(bankWriterProvider).undo(r.id),
              child: Text(l10n.reconUndo),
            ),
          ),
      ],
    );
  }
}
