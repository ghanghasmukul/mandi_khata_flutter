import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The business's cash and bank accounts with their book balances. Bank
/// accounts are added, edited and switched off by members with
/// `finance.view`; the Cash account is fixed.
class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canManage = ref.watch(canProvider(Permission.financeView));
    final accounts = ref
        .watch(bankAccountListProvider(includeInactive: true))
        .value;
    final balances = ref.watch(accountBalancesProvider).value ?? const {};
    void back() => context.go(PaymentRoutes.list);

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): back},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          floatingActionButton: canManage
              ? FloatingActionButton.extended(
                  key: const ValueKey('accounts-add'),
                  onPressed: () => showBankAccountDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.accountsAdd),
                )
              : null,
          body: Column(
            children: [
              MkTopBar(
                title: l10n.accountsTitle,
                actions: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: back,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: accounts == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          MkSpacing.lg,
                          MkSpacing.lg,
                          MkSpacing.lg,
                          88,
                        ),
                        children: [
                          for (final a in accounts)
                            _AccountTile(
                              account: a,
                              balance: balances[a.id] ?? Money.zero,
                              canManage: canManage,
                            ),
                          if (accounts.every((a) => a.isCash))
                            Padding(
                              padding: const EdgeInsets.only(top: MkSpacing.lg),
                              child: Text(
                                l10n.accountsEmpty,
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({
    required this.account,
    required this.balance,
    required this.canManage,
  });

  final BankAccount account;
  final Money balance;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final a = account;
    return MkCard(
      key: ValueKey('account-${a.id}'),
      padding: const EdgeInsets.symmetric(
        horizontal: MkSpacing.lg,
        vertical: MkSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            a.isCash ? Icons.payments_outlined : Icons.account_balance_outlined,
          ),
          const SizedBox(width: MkSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.isCash ? l10n.accountCash : a.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (a.bankName != null || a.ifsc != null)
                  Text(
                    [a.bankName, a.ifsc].whereType<String>().join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (!a.isActive) MkRoleChip(label: l10n.accountInactive),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.accountBookBalance,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              MkMoneyText(balance),
            ],
          ),
          if (canManage && !a.isCash)
            PopupMenuButton<String>(
              key: ValueKey('account-menu-${a.id}'),
              onSelected: (v) async {
                if (v == 'edit') {
                  await showBankAccountDialog(context, account: a);
                } else {
                  final result = await ref
                      .read(paymentWriterProvider)
                      .setAccountActive(a.id, active: !a.isActive);
                  if (!context.mounted) return;
                  final error = l10n.bankAccountError(result);
                  if (error != null) {
                    MkToast.show(context, error, tone: MkToastTone.error);
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.accountsEdit)),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    a.isActive ? l10n.accountSwitchOff : l10n.accountSwitchOn,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Adds a bank account, or edits [account].
Future<bool> showBankAccountDialog(
  BuildContext context, {
  BankAccount? account,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierColor: MkColors.scrim,
      builder: (_) => _BankAccountDialog(account: account),
    ) ??
    false;

class _BankAccountDialog extends ConsumerStatefulWidget {
  const _BankAccountDialog({this.account});

  final BankAccount? account;

  @override
  ConsumerState<_BankAccountDialog> createState() => _BankAccountDialogState();
}

class _BankAccountDialogState extends ConsumerState<_BankAccountDialog> {
  late final _name = TextEditingController(text: widget.account?.name);
  late final _bank = TextEditingController(text: widget.account?.bankName);
  late final _last4 = TextEditingController(text: widget.account?.last4);
  late final _ifsc = TextEditingController(text: widget.account?.ifsc);
  Set<BankAccountProblem> _problems = const {};
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _bank.dispose();
    _last4.dispose();
    _ifsc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final input = BankAccountInput(
      name: _name.text,
      bankName: _bank.text,
      last4: _last4.text,
      ifsc: _ifsc.text,
    );
    final problems = input.validate();
    if (problems.isNotEmpty) {
      setState(() => _problems = problems);
      return;
    }
    setState(() {
      _saving = true;
      _problems = const {};
      _error = null;
    });
    final writer = ref.read(paymentWriterProvider);
    final result = widget.account == null
        ? await writer.createAccount(input)
        : await writer.updateAccount(widget.account!.id, input);
    if (!mounted) return;
    final error = AppLocalizations.of(context).bankAccountError(result);
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkDialog(
      title: widget.account == null ? l10n.accountsAdd : l10n.accountsEdit,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MkTextField(
              key: const ValueKey('account-name'),
              controller: _name,
              label: l10n.accountFieldName,
              autofocus: true,
              errorText: _problems.contains(BankAccountProblem.nameMissing)
                  ? l10n.accountErrorName
                  : null,
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('account-bank'),
              controller: _bank,
              label: l10n.accountFieldBank,
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('account-last4'),
              controller: _last4,
              label: l10n.accountFieldLast4,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              errorText: _problems.contains(BankAccountProblem.last4Invalid)
                  ? l10n.accountErrorLast4
                  : null,
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('account-ifsc'),
              controller: _ifsc,
              label: l10n.accountFieldIfsc,
              errorText: _problems.contains(BankAccountProblem.ifscInvalid)
                  ? l10n.accountErrorIfsc
                  : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: MkSpacing.md),
              Text(
                _error!,
                style: TextStyle(color: MkTokens.of(context).udhaar),
              ),
            ],
          ],
        ),
      ),
      actions: [
        MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.ghost,
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        ),
        MkButton(
          key: const ValueKey('account-save'),
          label: l10n.paymentDone,
          icon: Icons.check,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
