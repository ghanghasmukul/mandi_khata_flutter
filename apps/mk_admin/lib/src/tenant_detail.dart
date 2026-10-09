import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/audit_screen.dart';
import 'package:mk_admin/src/form_fields.dart';
import 'package:mk_admin/src/support_view.dart';
import 'package:mk_ui/mk_ui.dart';

const _statuses = [
  'trial',
  'active',
  'past_due',
  'grace',
  'locked',
  'cancelled',
];

/// One customer: plan, trial and grace, discounts, add-ons and overrides,
/// defaults set on their behalf, requests, read-only support view and the
/// log of everything done to this business.
class TenantDetailScreen extends ConsumerStatefulWidget {
  const TenantDetailScreen({
    required this.tenantId,
    required this.name,
    super.key,
  });

  final String tenantId;
  final String name;

  @override
  ConsumerState<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends ConsumerState<TenantDetailScreen> {
  late Future<({Map<String, Object?> detail, Map<String, Object?> plans})>
  _future = _load();

  Future<({Map<String, Object?> detail, Map<String, Object?> plans})>
  _load() async {
    final api = ref.read(adminApiProvider);
    final detail = asMap(
      await api.call('tenant_detail', {'tenant_id': widget.tenantId}),
    );
    final plans = asMap(await api.call('plans_list'));
    return (detail: detail, plans: plans);
  }

  void _reload() => setState(() {
    _future = _load();
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.name)),
    body: FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        final data = snap.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final sub = asMap(data.detail['subscription']);
        final tenant = asMap(data.detail['tenant']);
        return ListView(
          padding: const EdgeInsets.all(MkSpacing.lg),
          children: [
            Text(
              [
                '${tenant['name']}',
                'state ${tenant['state_code']}',
                '${tenant['business_type'] ?? ''}',
                if (tenant['referral_code'] != null)
                  'referral ${tenant['referral_code']}${tenant['referral_valid'] == true ? '' : ' (unknown code)'}',
              ].join('  ·  '),
            ),
            const SizedBox(height: MkSpacing.md),
            SubscriptionCard(
              tenantId: widget.tenantId,
              sub: sub,
              plans: rows(data.plans['plans']),
              onSaved: _reload,
            ),
            const SizedBox(height: MkSpacing.md),
            EntitlementsCard(
              tenantId: widget.tenantId,
              sub: sub,
              addons: rows(data.plans['addons']),
              effective: asMap(data.detail['entitlements']),
              onSaved: _reload,
            ),
            const SizedBox(height: MkSpacing.md),
            DefaultsCard(
              tenantId: widget.tenantId,
              settings: rows(data.detail['settings']),
              onSaved: _reload,
            ),
            const SizedBox(height: MkSpacing.md),
            MkCard(
              title: 'Support',
              child: Align(
                alignment: Alignment.centerLeft,
                child: MkButton(
                  key: const ValueKey('support-start'),
                  label: 'Open read-only support view',
                  icon: Icons.support_agent_outlined,
                  variant: MkButtonVariant.secondary,
                  onPressed: () => startSupportView(
                    context,
                    ref,
                    tenantId: widget.tenantId,
                    name: widget.name,
                  ),
                ),
              ),
            ),
            const SizedBox(height: MkSpacing.md),
            MkCard(
              title: 'Admin log for this business',
              padding: EdgeInsets.zero,
              child: AdminLogList(rows: rows(data.detail['admin_log'])),
            ),
          ],
        );
      },
    ),
  );
}

String _iso(String text) {
  final t = text.trim();
  if (t.isEmpty) return '';
  final d = DateTime.tryParse(t);
  return d == null ? t : d.toUtc().toIso8601String();
}

String _day(Object? iso) => iso == null ? '' : '$iso'.split('T').first;

/// Plan, status, dates, grace, discount.
class SubscriptionCard extends ConsumerStatefulWidget {
  const SubscriptionCard({
    required this.tenantId,
    required this.sub,
    required this.plans,
    required this.onSaved,
    super.key,
  });

  final String tenantId;
  final Map<String, Object?> sub;
  final List<Map<String, Object?>> plans;
  final VoidCallback onSaved;

  @override
  ConsumerState<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends ConsumerState<SubscriptionCard> {
  late String _plan = '${widget.sub['plan_code']}';
  late String _status = '${widget.sub['status']}';
  late String _cycle = '${widget.sub['billing_cycle'] ?? 'monthly'}';
  late final _trialEnd = TextEditingController(
    text: _day(widget.sub['trial_ends_at']),
  );
  late final _periodEnd = TextEditingController(
    text: _day(widget.sub['current_period_end']),
  );
  late final _graceDays = TextEditingController(
    text: '${widget.sub['grace_days'] ?? 7}',
  );
  late final _graceUntil = TextEditingController(
    text: _day(widget.sub['grace_until']),
  );
  late final _discount = TextEditingController(
    text: '${widget.sub['discount_pct'] ?? 0}',
  );
  late final _discountNote = TextEditingController(
    text: '${widget.sub['discount_note'] ?? ''}',
  );
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _trialEnd,
      _periodEnd,
      _graceDays,
      _graceUntil,
      _discount,
      _discountNote,
      _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, Object?> _changes() {
    final out = <String, Object?>{};
    void diff(String key, Object? now) {
      if ('${widget.sub[key] ?? ''}' != '${now ?? ''}') out[key] = now;
    }

    diff('plan_code', _plan);
    diff('status', _status);
    diff('billing_cycle', _cycle);
    for (final (key, c) in [
      ('trial_ends_at', _trialEnd),
      ('current_period_end', _periodEnd),
      ('grace_until', _graceUntil),
    ]) {
      final now = _iso(c.text);
      if (_iso(_day(widget.sub[key])) != now) {
        out[key] = now.isEmpty ? null : now;
      }
    }
    final grace = int.tryParse(_graceDays.text.trim());
    if (grace != null && grace != widget.sub['grace_days']) {
      out['grace_days'] = grace;
    }
    final discount = num.tryParse(_discount.text.trim());
    if (discount != null &&
        discount != num.tryParse('${widget.sub['discount_pct']}')) {
      out['discount_pct'] = discount;
    }
    if (_discountNote.text != '${widget.sub['discount_note'] ?? ''}') {
      out['discount_note'] = _discountNote.text.trim().isEmpty
          ? null
          : _discountNote.text.trim();
    }
    return out;
  }

  Future<void> _apply(Map<String, Object?> changes, {String? note}) async {
    if (changes.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminApiProvider).call('update_subscription', {
        'tenant_id': widget.tenantId,
        'changes': changes,
        'note': note ?? _note.text.trim(),
      });
      widget.onSaved();
    } on AdminApiException catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  DateTime _from(Object? iso) =>
      DateTime.tryParse('${iso ?? ''}')?.toUtc() ?? DateTime.now().toUtc();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    DateTime later(Object? iso, int days) {
      final base = _from(iso);
      return (base.isAfter(now) ? base : now).add(Duration(days: days));
    }

    return MkCard(
      title: 'Subscription',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MkSpacing.md,
            runSpacing: MkSpacing.md,
            children: [
              DropdownMenu<String>(
                label: const Text('Plan'),
                initialSelection: _plan,
                onSelected: (v) => setState(() => _plan = v ?? _plan),
                dropdownMenuEntries: [
                  for (final p in widget.plans)
                    DropdownMenuEntry(
                      value: '${p['code']}',
                      label: '${p['name']} (${p['code']})',
                    ),
                ],
              ),
              DropdownMenu<String>(
                label: const Text('Status'),
                initialSelection: _status,
                onSelected: (v) => setState(() => _status = v ?? _status),
                dropdownMenuEntries: [
                  for (final s in _statuses)
                    DropdownMenuEntry(value: s, label: s),
                ],
              ),
              DropdownMenu<String>(
                label: const Text('Billing'),
                initialSelection: _cycle,
                onSelected: (v) => setState(() => _cycle = v ?? _cycle),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'monthly', label: 'monthly'),
                  DropdownMenuEntry(value: 'yearly', label: 'yearly'),
                ],
              ),
              _box(
                _trialEnd,
                'Trial ends (yyyy-mm-dd)',
                const ValueKey('sub-trial'),
              ),
              _box(
                _periodEnd,
                'Paid until (yyyy-mm-dd)',
                const ValueKey('sub-period'),
              ),
              _box(_graceDays, 'Grace days', const ValueKey('sub-grace-days')),
              _box(
                _graceUntil,
                'Grace until (override)',
                const ValueKey('sub-grace-until'),
              ),
              _box(_discount, 'Discount %', const ValueKey('sub-discount')),
              _box(
                _discountNote,
                'Discount note',
                const ValueKey('sub-discount-note'),
              ),
              _box(
                _note,
                'Reason (kept in the admin log)',
                const ValueKey('sub-note'),
              ),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          Wrap(
            spacing: MkSpacing.sm,
            runSpacing: MkSpacing.sm,
            children: [
              MkButton(
                key: const ValueKey('sub-save'),
                label: 'Save changes',
                busy: _busy,
                onPressed: _busy ? null : () => _apply(_changes()),
              ),
              MkButton(
                label: 'Extend trial 7 days',
                variant: MkButtonVariant.secondary,
                onPressed: _busy
                    ? null
                    : () => _apply({
                        'status': 'trial',
                        'trial_ends_at': later(
                          widget.sub['trial_ends_at'],
                          7,
                        ).toIso8601String(),
                      }, note: 'extend trial 7 days'),
              ),
              MkButton(
                label: 'Extend grace 7 days',
                variant: MkButtonVariant.secondary,
                onPressed: _busy
                    ? null
                    : () => _apply({
                        'grace_until': later(
                          widget.sub['grace_until'] ??
                              widget.sub['current_period_end'],
                          7,
                        ).toIso8601String(),
                      }, note: 'extend grace 7 days'),
              ),
              MkButton(
                label: 'Mark paid: +30 days',
                variant: MkButtonVariant.secondary,
                onPressed: _busy
                    ? null
                    : () => _apply({
                        'status': 'active',
                        'grace_until': null,
                        'current_period_end': later(
                          widget.sub['current_period_end'],
                          30,
                        ).toIso8601String(),
                      }, note: 'paid, +30 days'),
              ),
              MkButton(
                label: 'Lock now',
                variant: MkButtonVariant.danger,
                onPressed: _busy
                    ? null
                    : () =>
                          _apply({'status': 'locked'}, note: 'locked by admin'),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.sm),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _box(TextEditingController c, String label, Key key) => SizedBox(
    width: 220,
    child: MkTextField(key: key, controller: c, label: label),
  );
}

/// Add-ons bought and per-business module / limit overrides.
class EntitlementsCard extends ConsumerStatefulWidget {
  const EntitlementsCard({
    required this.tenantId,
    required this.sub,
    required this.addons,
    required this.effective,
    required this.onSaved,
    super.key,
  });

  final String tenantId;
  final Map<String, Object?> sub;
  final List<Map<String, Object?>> addons;
  final Map<String, Object?> effective;
  final VoidCallback onSaved;

  @override
  ConsumerState<EntitlementsCard> createState() => _EntitlementsCardState();
}

class _EntitlementsCardState extends ConsumerState<EntitlementsCard> {
  static const _limitKeys = ['users', 'devices', 'parties'];
  final Map<String, TextEditingController> _qty = {};
  final Map<String, String> _module = {};
  final Map<String, TextEditingController> _limit = {};
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final have = {
      for (final a in (widget.sub['addons'] as List?) ?? const [])
        '${(a as Map)['code']}': '${a['qty']}',
    };
    for (final a in widget.addons) {
      _qty['${a['code']}'] = TextEditingController(
        text: have['${a['code']}'] ?? '',
      );
    }
    final overrides = asMap(widget.sub['overrides']);
    final modules = asMap(overrides['modules']);
    final limits = asMap(overrides['limits']);
    for (final m in knownModules) {
      _module[m] = modules[m] == true
          ? 'on'
          : modules[m] == false
          ? 'off'
          : 'plan';
    }
    for (final k in _limitKeys) {
      _limit[k] = TextEditingController(
        text: !limits.containsKey(k)
            ? ''
            : limits[k] == null
            ? 'unlimited'
            : '${limits[k]}',
      );
    }
  }

  @override
  void dispose() {
    for (final c in [..._qty.values, ..._limit.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final addons = <Map<String, Object?>>[];
    for (final e in _qty.entries) {
      final t = e.value.text.trim();
      if (t.isEmpty) continue;
      final n = int.tryParse(t);
      if (n == null || n < 0) {
        setState(() => _error = 'Add-on quantities are whole numbers');
        return;
      }
      if (n > 0) addons.add({'code': e.key, 'qty': n});
    }
    final modules = <String, bool>{
      for (final e in _module.entries)
        if (e.value != 'plan') e.key: e.value == 'on',
    };
    final limits = <String, int?>{};
    for (final e in _limit.entries) {
      final t = e.value.text.trim().toLowerCase();
      if (t.isEmpty) continue;
      if (t == 'unlimited') {
        limits[e.key] = null;
      } else {
        final n = int.tryParse(t);
        if (n == null || n < 0) {
          setState(() => _error = 'Limits: a number, "unlimited" or empty');
          return;
        }
        limits[e.key] = n;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminApiProvider).call('update_subscription', {
        'tenant_id': widget.tenantId,
        'changes': {
          'addons': addons,
          'overrides': {
            if (modules.isNotEmpty) 'modules': modules,
            if (limits.isNotEmpty) 'limits': limits,
          },
        },
        'note': 'add-ons / overrides',
      });
      widget.onSaved();
    } on AdminApiException catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mods = asMap(widget.effective['modules']);
    final lims = asMap(widget.effective['limits']);
    return MkCard(
      title: 'Add-ons, overrides and what the business really gets',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Now: modules ${[for (final e in mods.entries)
              if (e.value == true) e.key].join(', ')}; '
            'limits ${jsonEncode(lims)}',
          ),
          const SizedBox(height: MkSpacing.md),
          Text(
            'Add-ons (quantity)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Wrap(
            spacing: MkSpacing.md,
            runSpacing: MkSpacing.sm,
            children: [
              for (final a in widget.addons)
                SizedBox(
                  width: 200,
                  child: MkTextField(
                    key: ValueKey('addon-${a['code']}'),
                    controller: _qty['${a['code']}'],
                    label: '${a['name']}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          Text(
            'Module overrides',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Wrap(
            spacing: MkSpacing.md,
            runSpacing: MkSpacing.sm,
            children: [
              for (final m in knownModules)
                DropdownMenu<String>(
                  key: ValueKey('override-$m'),
                  width: 190,
                  label: Text(m),
                  initialSelection: _module[m],
                  onSelected: (v) => setState(() => _module[m] = v ?? 'plan'),
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'plan', label: 'as plan'),
                    DropdownMenuEntry(value: 'on', label: 'force on'),
                    DropdownMenuEntry(value: 'off', label: 'force off'),
                  ],
                ),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          Text(
            'Limit overrides (empty = plan, number, or "unlimited")',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Wrap(
            spacing: MkSpacing.md,
            runSpacing: MkSpacing.sm,
            children: [
              for (final k in _limitKeys)
                SizedBox(
                  width: 200,
                  child: MkTextField(
                    key: ValueKey('limit-$k'),
                    controller: _limit[k],
                    label: k,
                  ),
                ),
            ],
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: MkSpacing.md),
          MkButton(
            key: const ValueKey('entitlements-save'),
            label: 'Save add-ons and overrides',
            busy: _busy,
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Defaults of this business (interest method, commission...) set on their
/// behalf. They appear in the customer's own audit log.
class DefaultsCard extends ConsumerStatefulWidget {
  const DefaultsCard({
    required this.tenantId,
    required this.settings,
    required this.onSaved,
    super.key,
  });

  final String tenantId;
  final List<Map<String, Object?>> settings;
  final VoidCallback onSaved;

  @override
  ConsumerState<DefaultsCard> createState() => _DefaultsCardState();
}

class _DefaultsCardState extends ConsumerState<DefaultsCard> {
  static const _suggestions = [
    'interest.method',
    'interest.rate_pa',
    'interest.compounding',
    'interest.day_basis',
    'interest.grace_days',
    'interest.appropriation',
    'mandi.commission_pct',
    'mandi.mandi_fee_pct',
    'business.credit_limit',
    'business.backdate_days',
  ];
  final _key = TextEditingController();
  final _value = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _key.dispose();
    _value.dispose();
    super.dispose();
  }

  Future<void> _set(String key, String valueText) async {
    Object? value;
    try {
      value = jsonDecode(valueText);
    } on FormatException {
      setState(
        () => _error = 'Value must be JSON: "compound", 18, "2.5", true, null',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminApiProvider).call('set_tenant_setting', {
        'tenant_id': widget.tenantId,
        'key': key,
        'value': value,
        'note': 'set by support',
      });
      widget.onSaved();
    } on AdminApiException catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => MkCard(
    title: 'Business defaults (set on their behalf)',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in widget.settings)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('${s['key']}'),
            subtitle: Text(jsonEncode(s['value'])),
            onTap: () {
              _key.text = '${s['key']}';
              _value.text = jsonEncode(s['value']);
            },
          ),
        const SizedBox(height: MkSpacing.sm),
        Wrap(
          spacing: MkSpacing.md,
          runSpacing: MkSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: MkTextField(
                key: const ValueKey('default-key'),
                controller: _key,
                label: 'Setting key',
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 220,
              child: MkTextField(
                key: const ValueKey('default-value'),
                controller: _value,
                label: 'Value (JSON)',
                hint: '"compound"',
              ),
            ),
            MkButton(
              key: const ValueKey('default-save'),
              label: 'Set',
              busy: _busy,
              onPressed: _busy || _key.text.trim().isEmpty
                  ? null
                  : () => _set(_key.text.trim(), _value.text.trim()),
            ),
          ],
        ),
        Wrap(
          spacing: MkSpacing.xs,
          children: [
            for (final k in _suggestions)
              ActionChip(
                label: Text(k),
                onPressed: () => setState(() => _key.text = k),
              ),
          ],
        ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
  );
}
