import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/interest/data/interest_statement_pdf.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_posting_providers.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_providers.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_statement_data.dart';
import 'package:mandi_khata_app/features/interest/presentation/party_interest_dialog.dart';
import 'package:mandi_khata_app/features/interest/presentation/post_interest_dialog.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_detail_cards.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_statement_table.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_tile.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:printing/printing.dart';

/// The party's byaj on its whole khata (`interest.apply_on = net_udhaar`):
/// the terms with where each one comes from, what is payable on a chosen
/// day, and the engine's day-by-day statement. In `loans_only` mode or with
/// interest off it says so instead, so the same money is never charged by
/// both the khata and a loan.
class PartyByajTab extends ConsumerStatefulWidget {
  const PartyByajTab({required this.party, super.key});

  final Party party;

  @override
  ConsumerState<PartyByajTab> createState() => _PartyByajTabState();
}

class _PartyByajTabState extends ConsumerState<PartyByajTab> {
  LedgerDate _asOf = LedgerDate.fromDateTime(DateTime.now());

  Future<void> _print(
    InterestConfig config,
    InterestResult result,
    PostedSummary posted,
  ) async {
    final l10n = AppLocalizations.of(context);
    final business = ref.read(activeMembershipProvider)?.tenantName ?? '';
    final fonts = await StatementFonts.load();
    if (!mounted) return;
    final bytes = await InterestStatementPdf.build(
      fonts: fonts,
      data: interestStatementData(
        l10n,
        businessName: business,
        party: widget.party,
        config: config,
        result: result,
        asOf: _asOf,
        postedPaise: posted.postedPaise,
        formatDate: (d) => AppFormat.ledgerDate(context, d),
      ),
    );
    await Printing.layoutPdf(
      name: '${l10n.byajStatementTitle} ${widget.party.name}',
      onLayout: (_) async => bytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final party = widget.party;
    final config = ref.watch(partyInterestConfigProvider(party));
    final resolver = ref.watch(settingsResolverProvider(partyTarget(party)));
    final entries = ref.watch(partyEntriesProvider(party.id)).value;
    final postings = ref.watch(partyPostingsProvider(party.id)).value;
    final canEdit = ref.watch(canProvider(Permission.loansManage));
    if (config == null ||
        resolver == null ||
        entries == null ||
        postings == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final mode = KhataInterest.mode(config);
    final posted = PostedSummary.of(postings);
    final result = KhataInterest.calculate(
      entries: entries,
      config: config,
      asOf: _asOf,
      waiverIds: posted.waiverIds,
      loanWaiverIds: PostedSummary.loanWaiverIds(postings),
    );
    String source(String key) => settingSourceText(
      l10n,
      resolver
          .resolve(key, partyId: party.id, partyGroupId: party.partyGroupId)
          .level,
    );

    return ListView(
      padding: const EdgeInsets.all(MkSpacing.lg),
      children: [
        MkCard(
          key: const ValueKey('byaj-terms'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.byajTermsTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (canEdit)
                    MkButton(
                      key: const ValueKey('byaj-edit'),
                      label: l10n.byajEditTerms,
                      icon: Icons.tune,
                      variant: MkButtonVariant.secondary,
                      onPressed: () => showPartyInterestDialog(context, party),
                    ),
                ],
              ),
              const SizedBox(height: MkSpacing.sm),
              switch (mode) {
                KhataInterestMode.off => _Note(
                  key: const ValueKey('byaj-off'),
                  text: l10n.byajNoInterest,
                ),
                KhataInterestMode.loansOnly => _Note(
                  key: const ValueKey('byaj-loans-only'),
                  text: l10n.byajLoansOnly,
                ),
                KhataInterestMode.khata => Column(
                  children: [
                    loanFact(
                      context,
                      l10n.settingInterestRatePa,
                      Text(
                        l10n.byajSourced(
                          l10n.loanRatePa(config.ratePa.toString()),
                          source('interest.rate_pa'),
                        ),
                      ),
                    ),
                    loanFact(
                      context,
                      l10n.settingInterestMethod,
                      Text(
                        l10n.byajSourced(
                          [
                            l10n.settingOption(
                              'interest.method',
                              config.method.name,
                            ),
                            if (config.compounds)
                              l10n.settingOption(
                                'interest.compounding',
                                config.compounding.dbName,
                              ),
                          ].join(' · '),
                          source('interest.method'),
                        ),
                      ),
                    ),
                    loanFact(
                      context,
                      l10n.settingInterestGraceDays,
                      Text(
                        l10n.byajSourced(
                          '${config.graceDays}',
                          source('interest.grace_days'),
                        ),
                      ),
                    ),
                    loanFact(
                      context,
                      l10n.settingInterestAppropriation,
                      Text(
                        l10n.byajSourced(
                          l10n.settingOption(
                            'interest.appropriation',
                            config.appropriation.dbName,
                          ),
                          source('interest.appropriation'),
                        ),
                      ),
                    ),
                    const SizedBox(height: MkSpacing.sm),
                    _Note(
                      key: const ValueKey('byaj-khata-note'),
                      text: l10n.byajKhataNote,
                    ),
                  ],
                ),
              },
            ],
          ),
        ),
        if (canEdit) ...[
          const SizedBox(height: MkSpacing.md),
          Wrap(
            spacing: MkSpacing.sm,
            runSpacing: MkSpacing.sm,
            children: [
              if (mode == KhataInterestMode.khata)
                MkButton(
                  key: const ValueKey('byaj-post'),
                  label: l10n.postInterestTitle,
                  icon: Icons.playlist_add_check,
                  onPressed: () =>
                      showPostInterestDialog(context, partyId: party.id),
                ),
              if (mode == KhataInterestMode.khata)
                MkButton(
                  key: const ValueKey('byaj-print'),
                  label: l10n.byajPrintStatement,
                  icon: Icons.print_outlined,
                  variant: MkButtonVariant.secondary,
                  onPressed: () => _print(config, result, posted),
                ),
              MkButton(
                key: const ValueKey('byaj-hisaab'),
                label: l10n.settleTitle,
                icon: Icons.balance,
                variant: MkButtonVariant.secondary,
                onPressed: () => context.go(PartyRoutes.hisaab(party.id)),
              ),
            ],
          ),
        ],
        if (mode != KhataInterestMode.loansOnly) ...[
          const SizedBox(height: MkSpacing.md),
          _Figures(
            result: result,
            postedPaise: posted.postedPaise,
            asOf: _asOf,
            interestOn: mode == KhataInterestMode.khata,
            onAsOf: (d) => setState(() => _asOf = d),
          ),
        ],
        if (mode == KhataInterestMode.khata) ...[
          const SizedBox(height: MkSpacing.lg),
          Text(
            l10n.loanStmtTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: MkSpacing.sm),
          LoanStatementTable(rows: result.schedule, forKhata: true),
        ],
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.info_outline, size: 18, color: MkTokens.of(context).textMuted),
      const SizedBox(width: MkSpacing.sm),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
    ],
  );
}

/// "Payable on a date" with the as-of date picker, and the figures.
class _Figures extends StatelessWidget {
  const _Figures({
    required this.result,
    required this.postedPaise,
    required this.asOf,
    required this.interestOn,
    required this.onAsOf,
  });

  final InterestResult result;

  /// Interest posted to the khata so far (not reversed).
  final int postedPaise;
  final LedgerDate asOf;
  final bool interestOn;
  final ValueChanged<LedgerDate> onAsOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkCard(
      key: const ValueKey('byaj-figures'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PaymentDateField(
                  key: const ValueKey('byaj-asof'),
                  label: l10n.loanDetailAsOf,
                  date: asOf,
                  onChanged: onAsOf,
                ),
              ),
              const SizedBox(width: MkSpacing.sm),
              TextButton(
                key: const ValueKey('byaj-asof-today'),
                onPressed: () =>
                    onAsOf(LedgerDate.fromDateTime(DateTime.now())),
                child: Text(l10n.loanDetailToday),
              ),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          Text(
            l10n.loanPayableOn(AppFormat.ledgerDate(context, asOf)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          MkMoneyText(
            Money(result.totalPayablePaise),
            key: const ValueKey('byaj-payable'),
            size: 28,
          ),
          const Divider(height: MkSpacing.xl),
          loanFact(
            context,
            l10n.loanPrincipalOutstanding,
            MkMoneyText(
              Money(result.principalPaise),
              key: const ValueKey('byaj-principal'),
            ),
          ),
          if (interestOn) ...[
            loanFact(
              context,
              l10n.loanInterestAccrued,
              MkMoneyText(
                Money(result.accruedUnpaidPaise),
                key: const ValueKey('byaj-accrued'),
              ),
            ),
            loanFact(
              context,
              l10n.loanInterestRecovered,
              MkMoneyText(
                Money(result.interestRecoveredPaise),
                tone: MkMoneyTone.jama,
                key: const ValueKey('byaj-recovered'),
              ),
            ),
            loanFact(
              context,
              l10n.byajPosted,
              MkMoneyText(
                Money(postedPaise),
                key: const ValueKey('byaj-posted'),
              ),
            ),
            loanFact(
              context,
              l10n.byajUnposted,
              MkMoneyText(
                Money(
                  InterestPosting.unposted(result, postedPaise: postedPaise),
                ),
                key: const ValueKey('byaj-unposted'),
              ),
            ),
          ],
          if (interestOn &&
              InterestPosting.overPosted(result, postedPaise: postedPaise) > 0)
            loanFact(
              context,
              l10n.byajOverPosted,
              MkMoneyText(
                Money(
                  InterestPosting.overPosted(result, postedPaise: postedPaise),
                ),
                tone: MkMoneyTone.udhaar,
                key: const ValueKey('byaj-overposted'),
              ),
            ),
          if (result.interestPayableToPartyPaise > 0)
            loanFact(
              context,
              l10n.byajPayableToParty,
              MkMoneyText(
                Money(result.interestPayableToPartyPaise),
                tone: MkMoneyTone.jama,
                key: const ValueKey('byaj-payable-to-party'),
              ),
            ),
          if (result.creditBalancePaise > 0)
            loanFact(
              context,
              l10n.byajCreditBalance,
              MkMoneyText(
                Money(result.creditBalancePaise),
                tone: MkMoneyTone.jama,
                key: const ValueKey('byaj-credit'),
              ),
            ),
        ],
      ),
    );
  }
}
