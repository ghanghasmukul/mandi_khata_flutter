import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/interest/data/settlement_slip_pdf.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_posting_providers.dart';
import 'package:mandi_khata_app/features/interest/presentation/settlement_widgets.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:printing/printing.dart';

/// "Hisaab karo": settles one party up to a day. Shows the khata, the
/// interest charged and not yet posted (khata and each loan), lets the
/// owner take part of it off (a discount, with a reason), prints the slip,
/// and posts the interest and the discount in one go. Then the party pays
/// or is paid from the khata. Needs `loans.manage`; a discount also
/// `entries.reverse`.
class SettlementScreen extends ConsumerStatefulWidget {
  const SettlementScreen({required this.partyId, super.key});

  final String partyId;

  @override
  ConsumerState<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends ConsumerState<SettlementScreen> {
  final LedgerDate _today = LedgerDate.fromDateTime(DateTime.now());
  late LedgerDate _asOf = _today;
  final Map<String, TextEditingController> _waivers = {};
  final _reason = TextEditingController();
  bool _saving = false;
  String? _message;
  bool _done = false;

  @override
  void dispose() {
    for (final c in _waivers.values) {
      c.dispose();
    }
    _reason.dispose();
    super.dispose();
  }

  TextEditingController _waiverField(String key) =>
      _waivers.putIfAbsent(key, TextEditingController.new);

  /// The waivers typed so far, in paise. Blank = none; unreadable = 0.
  Map<String, int> _typedWaivers() => {
    for (final e in _waivers.entries)
      if ((Money.tryParse(e.value.text)?.paise ?? 0) != 0)
        e.key: Money.tryParse(e.value.text)!.paise,
  };

  Future<void> _post(AppLocalizations l10n) async {
    setState(() {
      _saving = true;
      _message = null;
    });
    final result = await ref
        .read(interestPostingWriterProvider)
        .settle(
          widget.partyId,
          _asOf,
          waivers: _typedWaivers(),
          reason: _reason.text,
        );
    if (!mounted) return;
    final error = l10n.postingError(result);
    setState(() {
      _saving = false;
      _message = error;
      if (result is SettlementDone) {
        _done = true;
        _message = l10n.settleDone(
          result.interest.format(),
          result.waived.format(),
        );
        for (final c in _waivers.values) {
          c.clear();
        }
        _reason.clear();
      }
    });
  }

  Future<void> _print(
    AppLocalizations l10n,
    Party party,
    Settlement settlement,
    Map<RefType, SideTotals> totals,
    List<PostingCandidate> sources,
  ) async {
    final fonts = await StatementFonts.load();
    if (!mounted) return;
    final business = ref.read(activeMembershipProvider)?.tenantName ?? '';
    final bytes = await SettlementSlipPdf.build(
      fonts: fonts,
      slip: settlementSlip(
        l10n,
        context: context,
        businessName: business,
        party: party,
        asOf: _asOf,
        settlement: settlement,
        totals: totals,
        sources: sources,
        reason: _reason.text.trim(),
      ),
    );
    await Printing.layoutPdf(
      name: '${l10n.settleTitle} ${party.name}',
      onLayout: (_) async => bytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canManage = ref.watch(canProvider(Permission.loansManage));
    final canWaive = ref.watch(canProvider(Permission.entriesReverse));
    final party = ref.watch(partyProvider(widget.partyId)).value;
    final entries = ref.watch(partyEntriesProvider(widget.partyId)).value;
    final candidates = ref
        .watch(postingCandidatesProvider(_asOf, partyId: widget.partyId))
        .value;
    void back() => context.go(PartyRoutes.detail(widget.partyId));

    Widget body() {
      if (!canManage) return Center(child: Text(l10n.byajNoPermission));
      if (party == null || entries == null || candidates == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final sources = [
        for (final c in candidates)
          if (!c.alreadyPosted) c,
      ];
      final waivers = _typedWaivers();
      final problems = Settlement.validate(
        sources: [for (final c in sources) c.source],
        waivers: waivers,
        reason: _reason.text,
      );
      final settlement = Settlement.compute(
        balance: LedgerCalculator.balance(entries),
        sources: [for (final c in sources) c.source],
        waivers:
            problems.contains(SettlementProblem.waiverExceedsInterest) ||
                problems.contains(SettlementProblem.waiverNegative)
            ? const {}
            : waivers,
      );
      final totals = LedgerCalculator.totalsByRefType(entries);
      return ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          Text(l10n.settleIntro),
          const SizedBox(height: MkSpacing.md),
          SizedBox(
            width: 240,
            child: PaymentDateField(
              key: const ValueKey('settle-asof'),
              label: l10n.settleAsOf,
              date: _asOf,
              onChanged: (d) => setState(() {
                _asOf = d > _today ? _today : d;
                _message = null;
              }),
            ),
          ),
          const SizedBox(height: MkSpacing.md),
          SettlementKhataCard(totals: totals, balance: settlement.balance),
          const SizedBox(height: MkSpacing.md),
          if (sources.isEmpty)
            Text(l10n.settleNothing, key: const ValueKey('settle-nothing'))
          else
            for (final c in sources)
              SettlementSourceCard(
                candidate: c,
                controller: _waiverField(c.source.key),
                canWaive: canWaive,
                onChanged: () => setState(() {}),
              ),
          if (sources.isNotEmpty && canWaive) ...[
            const SizedBox(height: MkSpacing.sm),
            MkTextField(
              key: const ValueKey('settle-reason'),
              controller: _reason,
              label: l10n.settleReason,
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: MkSpacing.md),
          MkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.settleInterestDue)),
                    MkMoneyText(
                      settlement.interestDue,
                      key: const ValueKey('settle-interest-due'),
                    ),
                  ],
                ),
                const Divider(),
                Text(switch (settlement.direction) {
                  SettlementDirection.receivable => l10n.settleReceivable,
                  SettlementDirection.payable => l10n.settlePayable,
                  SettlementDirection.settled => l10n.settleSettled,
                }, style: Theme.of(context).textTheme.bodySmall),
                MkMoneyText(
                  settlement.finalBalance.abs(),
                  key: const ValueKey('settle-final'),
                  size: 28,
                ),
              ],
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: MkSpacing.md),
            Text(
              _message!,
              key: const ValueKey('settle-message'),
              style: _done
                  ? null
                  : TextStyle(color: MkTokens.of(context).udhaar),
            ),
            if (_done)
              Text(
                l10n.settleNextHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
          if (problems.isNotEmpty && waivers.isNotEmpty) ...[
            const SizedBox(height: MkSpacing.sm),
            Text(
              problems.map(l10n.settlementProblem).join('\n'),
              key: const ValueKey('settle-problems'),
              style: TextStyle(color: MkTokens.of(context).udhaar),
            ),
          ],
          const SizedBox(height: MkSpacing.md),
          Wrap(
            spacing: MkSpacing.sm,
            runSpacing: MkSpacing.sm,
            children: [
              MkButton(
                key: const ValueKey('settle-print'),
                label: l10n.settlePrint,
                icon: Icons.print_outlined,
                variant: MkButtonVariant.secondary,
                onPressed: () =>
                    _print(l10n, party, settlement, totals, sources),
              ),
              if (sources.isNotEmpty)
                MkButton(
                  key: const ValueKey('settle-post'),
                  label: l10n.settlePost,
                  icon: Icons.check,
                  onPressed: _saving || problems.isNotEmpty
                      ? null
                      : () => _post(l10n),
                ),
              MkButton(
                key: const ValueKey('settle-khata'),
                label: l10n.settleOpenKhata,
                variant: MkButtonVariant.ghost,
                onPressed: back,
              ),
            ],
          ),
        ],
      );
    }

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): back},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(title: l10n.settleTitle, subtitle: party?.name),
              Expanded(child: body()),
            ],
          ),
        ),
      ),
    );
  }
}
