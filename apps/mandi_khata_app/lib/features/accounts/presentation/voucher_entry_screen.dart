import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/accounts/data/voucher_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_labels.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/accounts/presentation/voucher_line_row.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Tally-style voucher entry: F4–F9 pick the type, Enter moves to the next
/// field (and adds a balancing line when needed), Ctrl+Enter saves, Esc
/// leaves. Shows the running difference until Dr = Cr.
class VoucherEntryScreen extends ConsumerStatefulWidget {
  const VoucherEntryScreen({this.initialType = VoucherType.payment, super.key});

  final VoucherType initialType;

  @override
  ConsumerState<VoucherEntryScreen> createState() => _VoucherEntryState();
}

class _VoucherEntryState extends ConsumerState<VoucherEntryScreen> {
  late VoucherType _type = widget.initialType;
  LedgerDate _date = LedgerDate.fromDateTime(DateTime.now());
  final _narration = TextEditingController();
  final _narrationFocus = FocusNode();
  late List<VoucherLineState> _lines = _fresh();
  String? _error;
  bool _saving = false;

  List<VoucherLineState> _fresh() => [
    VoucherLineState(DrCr.dr),
    VoucherLineState(DrCr.cr),
  ];

  @override
  void dispose() {
    for (final l in _lines) {
      l.dispose();
    }
    _narration.dispose();
    _narrationFocus.dispose();
    super.dispose();
  }

  List<VoucherDraftLine> get _filled => [
    for (final l in _lines)
      if (l.account != null)
        VoucherDraftLine(
          account: l.account!,
          side: l.side,
          amount: l.amount ?? Money.zero,
        ),
  ];

  Money get _debit => _sum(DrCr.dr);
  Money get _credit => _sum(DrCr.cr);

  Money _sum(DrCr side) => _lines
      .where((l) => l.side == side)
      .fold(Money.zero, (s, l) => s + (l.amount ?? Money.zero));

  void _setType(VoucherType t) => setState(() {
    _type = t;
    _error = null;
  });

  /// After an amount: the next line, or a new line that balances, or the
  /// narration when everything balances.
  void _afterAmount(int index) {
    final diff = _debit - _credit;
    if (index + 1 < _lines.length) {
      _lines[index + 1].accountFocus.requestFocus();
      return;
    }
    if (diff.isZero) {
      _narrationFocus.requestFocus();
      return;
    }
    final line = VoucherLineState(
      diff.isPositive ? DrCr.cr : DrCr.dr,
      amount: diff.abs(),
    );
    setState(() => _lines = [..._lines, line]);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => line.accountFocus.requestFocus(),
    );
  }

  void _afterAccount(int index) {
    final line = _lines[index];
    // A line opened to balance already carries the amount.
    if (line.amount == null) {
      final diff = _debit - _credit;
      final wanted = line.side == DrCr.dr ? -diff : diff;
      if (wanted.isPositive) line.amount = wanted;
    }
    setState(() {});
    line.amountFocus.requestFocus();
  }

  void _remove(int index) {
    if (_lines.length <= 2) return;
    final line = _lines[index];
    setState(() => _lines = [..._lines]..removeAt(index));
    line.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref
        .read(accountsWriterProvider)
        .save(
          VoucherDraft(
            type: _type,
            date: _date,
            lines: _filled,
            narration: _narration.text,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is VoucherSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.voucherSaved(result.voucherNo))),
      );
      final old = _lines;
      setState(() {
        _lines = _fresh();
        _narration.clear();
      });
      for (final l in old) {
        l.dispose();
      }
      ref.invalidate(nextVoucherNoProvider(_type));
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _lines.first.accountFocus.requestFocus(),
      );
    } else {
      setState(() => _error = l10n.voucherResult(result));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366)),
      initialDate: DateTime(_date.year, _date.month, _date.day),
    );
    if (picked != null) setState(() => _date = LedgerDate.fromDateTime(picked));
  }

  void _leave() =>
      context.canPop() ? context.pop() : context.go(AccountRoutes.hub);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chart = ref.watch(chartProvider).value;
    final nextNo = ref.watch(nextVoucherNoProvider(_type)).value;
    final diff = _debit - _credit;
    return CallbackShortcuts(
      bindings: {
        for (final (key, type) in voucherTypeKeys)
          SingleActivator(key): () => _setType(type),
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _save,
        const SingleActivator(LogicalKeyboardKey.escape): _leave,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(
                title: l10n.voucherEntryTitle,
                subtitle: nextNo == null ? null : l10n.voucherNoPreview(nextNo),
                actions: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: _leave,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: chart == null
                    ? const Center(child: CircularProgressIndicator())
                    : _form(context, chart, diff),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, Chart chart, Money diff) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(MkSpacing.lg),
      children: [
        Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          children: [
            for (final (key, type) in voucherTypeKeys)
              ChoiceChip(
                key: ValueKey('type-${type.dbName}'),
                label: Text('${key.keyLabel} ${l10n.voucherTypeName(type)}'),
                selected: _type == type,
                onSelected: (_) => _setType(type),
              ),
          ],
        ),
        const SizedBox(height: MkSpacing.md),
        Row(
          children: [
            TextButton.icon(
              key: const ValueKey('voucher-date'),
              onPressed: _pickDate,
              icon: const Icon(Icons.event, size: 18),
              label: Text(
                '${l10n.voucherDate}: ${AppFormat.ledgerDate(context, _date)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: MkSpacing.sm),
        for (var i = 0; i < _lines.length; i++)
          VoucherLineRow(
            key: ObjectKey(_lines[i]),
            line: _lines[i],
            index: i,
            chart: chart,
            accounts: voucherAccounts(
              chart,
              suggested: VoucherDefaults.suggestedKinds(_type, _lines[i].side),
            ),
            onChanged: () => setState(() {}),
            onAccountPicked: () => _afterAccount(i),
            onAmountSubmitted: () => _afterAmount(i),
            onRemove: _lines.length > 2 ? () => _remove(i) : null,
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const ValueKey('voucher-add-line'),
            onPressed: () => setState(
              () => _lines = [
                ..._lines,
                VoucherLineState(diff.isPositive ? DrCr.cr : DrCr.dr),
              ],
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.voucherAddLine),
          ),
        ),
        _Totals(debit: _debit, credit: _credit),
        const SizedBox(height: MkSpacing.md),
        MkTextField(
          key: const ValueKey('voucher-narration'),
          label: l10n.voucherNarration,
          controller: _narration,
          focusNode: _narrationFocus,
          onSubmitted: (_) => _save(),
        ),
        if (_error != null) ...[
          const SizedBox(height: MkSpacing.md),
          Text(
            _error!,
            key: const ValueKey('voucher-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: MkSpacing.lg),
        Row(
          children: [
            MkButton(
              key: const ValueKey('voucher-save'),
              label: l10n.voucherSave,
              icon: Icons.check,
              busy: _saving,
              onPressed: _save,
            ),
          ],
        ),
        const SizedBox(height: MkSpacing.md),
        Text(
          l10n.voucherShortcuts,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.debit, required this.credit});

  final Money debit;
  final Money credit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final diff = debit - credit;
    final tokens = MkTokens.of(context);
    return Row(
      key: const ValueKey('voucher-totals'),
      children: [
        Expanded(
          child: Text(
            l10n.voucherTotals(debit.format(), credit.format()),
            style: MkText.mono(),
          ),
        ),
        Text(
          diff.isZero
              ? l10n.voucherBalanced
              : l10n.voucherDifference(l10n.drCr(diff)),
          key: const ValueKey('voucher-difference'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: diff.isZero ? tokens.jama : tokens.udhaar,
          ),
        ),
      ],
    );
  }
}
