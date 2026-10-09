import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/subscription/subscription_models.dart';
import 'package:mandi_khata_app/core/subscription/subscription_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/subscription/presentation/lifecycle_banner.dart';
import 'package:mandi_khata_app/features/subscription/presentation/module_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Plan and billing: what the business has, how much of it is used, what
/// else is on offer, and a request to change. Payments are handled by the
/// vendor for now (Razorpay comes later), so a change is a request.
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final Map<String, int> _addonQty = {};

  Future<void> _request({
    String? planCode,
    List<({String code, int qty})> addons = const [],
  }) async {
    final l10n = AppLocalizations.of(context);
    final answer = await showDialog<_RequestAnswer>(
      context: context,
      builder: (_) => _RequestDialog(
        title: planCode == null
            ? l10n.billRequestAddonsTitle
            : l10n.billRequestTitle(
                ref
                        .read(subscriptionBundleProvider)
                        .value
                        ?.plans
                        .where((p) => p.code == planCode)
                        .firstOrNull
                        ?.name ??
                    planCode,
              ),
      ),
    );
    if (answer == null || !mounted) return;
    final ctx = ref.read(writeContextProvider);
    if (ctx == null) return;
    final repo = await ref.read(subscriptionRepositoryProvider.future);
    await repo.requestPlan(
      ctx,
      planCode: planCode,
      billingCycle: answer.cycle,
      addons: addons,
      note: answer.note,
    );
    if (!mounted) return;
    setState(_addonQty.clear);
    MkToast.show(context, l10n.billRequestSent, tone: MkToastTone.success);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final member = ref.watch(activeMembershipProvider);
    final bundle = ref.watch(subscriptionBundleProvider).value;
    final life = ref.watch(lifecycleProvider);
    final usage = ref.watch(subscriptionUsageProvider).value;
    final requests = ref.watch(planRequestsProvider).value ?? const [];
    final support = ref.watch(supportSessionsProvider).value ?? const [];
    final ent = ref.watch(entitlementsProvider);
    final isOwner = member?.canIgnoringLock(Permission.adminManage) ?? false;
    final tokens = MkTokens.of(context);

    String date(DateTime? d) => d == null
        ? ''
        : (DateFormat.yMMMd(lang)..useNativeDigits = false).format(d.toLocal());
    String price(Money m, String per) =>
        m.isZero ? l10n.billPriceOnRequest : per;

    final Widget body;
    if (member == null || bundle == null) {
      body = Center(child: Text(l10n.billNoSubscription));
    } else {
      final plan = bundle.plan;
      final terms = bundle.subscription.terms;
      final pending = requests.where((r) => r.pending).toList();
      final offered = [
        for (final p in bundle.plans)
          if (p.isActive &&
              (p.isPublic || p.code == bundle.subscription.planCode))
            p,
      ];
      final addons = [
        for (final a in bundle.addonCatalog)
          if (a.isActive) a,
      ];

      body = ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          MkCard(
            title: l10n.billCurrentPlan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan?.name ?? bundle.subscription.planCode,
                  key: const ValueKey('billing-plan-name'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: MkSpacing.xs),
                Text(
                  l10n.billStatus(life.effective.wire),
                  key: const ValueKey('billing-status'),
                  style: TextStyle(
                    color: life.canWrite ? MkColors.brand : tokens.udhaar,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (lifecycleText(l10n, life, lang).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: MkSpacing.xs),
                    child: Text(lifecycleText(l10n, life, lang)),
                  ),
                if (terms.status == SubscriptionStatus.trial &&
                    terms.trialEndsAt != null)
                  Text(l10n.billTrialEnds(date(terms.trialEndsAt)))
                else if (terms.currentPeriodEnd != null)
                  Text(l10n.billRenews(date(terms.currentPeriodEnd))),
                if (bundle.subscription.discountPct > 0)
                  Text(
                    l10n.billDiscount(
                      bundle.subscription.discountPct.toStringAsFixed(0),
                    ),
                  ),
                if (pending.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: MkSpacing.sm),
                    child: Text(
                      l10n.billRequestPending,
                      style: TextStyle(color: tokens.goldText),
                    ),
                  ),
                if (!isOwner)
                  Padding(
                    padding: const EdgeInsets.only(top: MkSpacing.sm),
                    child: Text(l10n.billOnlyOwner),
                  ),
              ],
            ),
          ),
          if (usage != null) ...[
            const SizedBox(height: MkSpacing.lg),
            MkCard(
              title: l10n.billUsage,
              child: Column(
                children: [
                  for (final key in const ['users', 'devices', 'parties'])
                    _UsageRow(
                      label: l10n.billLimitName(key),
                      used: usage.of(key),
                      limit: ent.limit(key),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: MkSpacing.lg),
          MkCard(
            title: l10n.billModules,
            child: Wrap(
              spacing: MkSpacing.sm,
              runSpacing: MkSpacing.sm,
              children: [
                for (final m in SettingsSchema.modules)
                  Chip(
                    avatar: Icon(
                      ent.module(m) ? Icons.check_circle : Icons.lock_outline,
                      size: 18,
                      color: ent.module(m) ? MkColors.brand : tokens.textFaint,
                    ),
                    label: Text(l10n.moduleName(m)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: MkSpacing.lg),
          MkCard(
            title: l10n.billPlans,
            child: Column(
              children: [
                for (final p in offered)
                  _PlanTile(
                    plan: p,
                    current: p.code == bundle.subscription.planCode,
                    monthly: price(
                      p.priceMonthly,
                      l10n.billPerMonth(p.priceMonthly.format()),
                    ),
                    yearly: price(
                      p.priceYearly,
                      l10n.billPerYear(p.priceYearly.format()),
                    ),
                    onRequest: isOwner
                        ? () => _request(planCode: p.code)
                        : null,
                  ),
              ],
            ),
          ),
          if (addons.isNotEmpty) ...[
            const SizedBox(height: MkSpacing.lg),
            MkCard(
              title: l10n.billAddons,
              child: Column(
                children: [
                  for (final a in addons)
                    ListTile(
                      key: ValueKey('addon-${a.code}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(a.name),
                      subtitle: Text(
                        price(
                          a.priceMonthly,
                          l10n.billPerMonth(a.priceMonthly.format()),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l10n.billAddonLess,
                            onPressed: (_addonQty[a.code] ?? 0) > 0
                                ? () => setState(
                                    () => _addonQty[a.code] =
                                        (_addonQty[a.code] ?? 0) - 1,
                                  )
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${_addonQty[a.code] ?? 0}'),
                          IconButton(
                            tooltip: l10n.billAddonMore,
                            onPressed: () => setState(
                              () => _addonQty[a.code] =
                                  (_addonQty[a.code] ?? 0) + 1,
                            ),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MkButton(
                      key: const ValueKey('request-addons'),
                      label: l10n.billRequestAddons,
                      variant: MkButtonVariant.secondary,
                      onPressed: isOwner && _addonQty.values.any((q) => q > 0)
                          ? () => _request(
                              addons: [
                                for (final e in _addonQty.entries)
                                  if (e.value > 0) (code: e.key, qty: e.value),
                              ],
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (requests.isNotEmpty) ...[
            const SizedBox(height: MkSpacing.lg),
            MkCard(
              title: l10n.billRequests,
              child: Column(
                children: [
                  for (final r in requests)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(r.planCode ?? l10n.billAddons),
                      subtitle: Text(
                        [
                          date(r.createdAt),
                          if (r.handledNote != null) r.handledNote!,
                        ].where((t) => t.isNotEmpty).join(' · '),
                      ),
                      trailing: Text(l10n.billRequestStatus(r.status)),
                    ),
                ],
              ),
            ),
          ],
          if (support.isNotEmpty) ...[
            const SizedBox(height: MkSpacing.lg),
            MkCard(
              title: l10n.billSupportAccess,
              child: Column(
                children: [
                  for (final s in support)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.support_agent_outlined),
                      title: Text(s.who),
                      subtitle: Text('${date(s.startedAt)} · ${s.reason}'),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: MkSpacing.lg),
          Text(
            l10n.billManualNote,
            style: TextStyle(color: tokens.textMuted, fontSize: 12),
          ),
        ],
      );
    }

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.billTitle,
            subtitle: member?.tenantName,
            languages: appLanguages,
            language: lang,
            onLanguage: (c) => ref.read(appLanguageProvider.notifier).set(c),
            actions: [
              if (ref.watch(gateStepProvider) != GateStep.ready)
                TextButton(
                  onPressed: () => context.go(GateRoutes.selectTenant),
                  child: Text(l10n.billSwitchBusiness),
                ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.label,
    required this.used,
    required this.limit,
  });

  final String label;
  final int used;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cap = limit;
    final over = cap != null && used >= cap;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MkSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                cap == null
                    ? l10n.billUsageNoLimit(used)
                    : l10n.billUsageOf(used, cap),
                style: TextStyle(
                  color: over ? MkTokens.of(context).udhaar : null,
                  fontWeight: over ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
          if (cap != null && cap > 0)
            LinearProgressIndicator(
              value: (used / cap).clamp(0, 1).toDouble(),
              color: over ? MkTokens.of(context).udhaar : MkColors.brand,
            ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.current,
    required this.monthly,
    required this.yearly,
    required this.onRequest,
  });

  final PlanInfo plan;
  final bool current;
  final String monthly;
  final String yearly;
  final VoidCallback? onRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final modules = [
      for (final e in plan.spec.modules.entries)
        if (e.value) l10n.moduleName(e.key),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MkSpacing.sm),
      child: Row(
        key: ValueKey('plan-${plan.code}'),
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: Theme.of(context).textTheme.titleMedium),
                if (plan.description != null) Text(plan.description!),
                Text(
                  '$monthly · $yearly',
                  style: TextStyle(color: MkTokens.of(context).textMuted),
                ),
                Text(
                  [
                    modules.join(', '),
                    l10n.billUsersDevices(
                      plan.spec.maxUsers?.toString() ?? '∞',
                      plan.spec.maxDevices?.toString() ?? '∞',
                    ),
                  ].join(' · '),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          if (current)
            Chip(label: Text(l10n.billCurrentBadge))
          else
            MkButton(
              key: ValueKey('request-${plan.code}'),
              label: l10n.billRequestPlan,
              variant: MkButtonVariant.secondary,
              onPressed: onRequest,
            ),
        ],
      ),
    );
  }
}

class _RequestAnswer {
  const _RequestAnswer(this.cycle, this.note);
  final String cycle;
  final String? note;
}

class _RequestDialog extends StatefulWidget {
  const _RequestDialog({required this.title});

  final String title;

  @override
  State<_RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<_RequestDialog> {
  String _cycle = 'monthly';
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'monthly', label: Text(l10n.billMonthly)),
                ButtonSegment(value: 'yearly', label: Text(l10n.billYearly)),
              ],
              selected: {_cycle},
              onSelectionChanged: (s) => setState(() => _cycle = s.first),
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('request-note'),
              controller: _note,
              label: l10n.billRequestNote,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('request-send'),
          onPressed: () =>
              Navigator.of(context).pop(_RequestAnswer(_cycle, _note.text)),
          child: Text(l10n.billRequestSend),
        ),
      ],
    );
  }
}
