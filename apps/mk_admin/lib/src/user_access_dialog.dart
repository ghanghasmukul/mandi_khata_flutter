import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_admin/src/access_catalog.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/users_screen.dart';
import 'package:mk_ui/mk_ui.dart';

String _error(Object e) => e is AdminApiException ? e.toString() : '$e';

/// Shows a password once, with a copy button.
Future<void> showPasswordOnce(
  BuildContext context, {
  required String email,
  required String password,
}) => showDialog<void>(
  context: context,
  builder: (c) => AlertDialog(
    title: const Text('Password'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(email),
        const SizedBox(height: MkSpacing.md),
        SelectableText(
          password,
          key: const ValueKey('shown-password'),
          style: MkText.mono(),
        ),
        const SizedBox(height: MkSpacing.md),
        const Text(
          'Shown only now. Give it to the user; they sign in with this email '
          'and password and can change it later.',
        ),
      ],
    ),
    actions: [
      TextButton.icon(
        onPressed: () => Clipboard.setData(ClipboardData(text: password)),
        icon: const Icon(Icons.copy),
        label: const Text('Copy'),
      ),
      FilledButton(
        onPressed: () => Navigator.of(c).pop(),
        child: const Text('Done'),
      ),
    ],
  ),
);

/// New sign-in: name, email, optional phone and password (generated when
/// empty), and optionally a business, role and features right away.
class CreateUserDialog extends ConsumerStatefulWidget {
  const CreateUserDialog({super.key});

  @override
  ConsumerState<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<CreateUserDialog> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  late final Future<List<Map<String, Object?>>> _businesses = ref
      .read(adminApiProvider)
      .call('businesses_brief')
      .then(rows);
  String? _tenant;
  MemberRole _role = MemberRole.munshi;
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final r = asMap(
        await ref.read(adminApiProvider).call('user_create', {
          'full_name': _name.text,
          'email': _email.text,
          'phone': _phone.text,
          if (_password.text.isNotEmpty) 'password': _password.text,
          if (_tenant != null) 'tenant_id': _tenant,
          if (_tenant != null) 'role': _role.name,
        }),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      await showPasswordOnce(
        context,
        email: '${r['email']}',
        password: '${r['password']}',
      );
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _err = _error(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create user'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MkTextField(
              key: const ValueKey('new-name'),
              controller: _name,
              label: 'Full name',
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('new-email'),
              controller: _email,
              label: 'Email (the sign-in)',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('new-phone'),
              controller: _phone,
              label: 'Mobile (optional, 10 digits)',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('new-password'),
              controller: _password,
              label: 'Password (leave empty to generate one)',
            ),
            const SizedBox(height: MkSpacing.lg),
            Text(
              'Business (optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: MkSpacing.sm),
            FutureBuilder(
              future: _businesses,
              builder: (context, snap) => DropdownButtonFormField<String?>(
                key: const ValueKey('new-business'),
                initialValue: _tenant,
                hint: const Text('Not in any business yet'),
                items: [
                  const DropdownMenuItem<String?>(
                    child: Text('Not in any business yet'),
                  ),
                  for (final b in snap.data ?? const <Map<String, Object?>>[])
                    DropdownMenuItem<String?>(
                      value: '${b['id']}',
                      child: Text('${b['name']}'),
                    ),
                ],
                onChanged: (v) => setState(() => _tenant = v),
              ),
            ),
            if (_tenant != null) ...[
              const SizedBox(height: MkSpacing.md),
              SegmentedButton<MemberRole>(
                key: const ValueKey('new-role'),
                showSelectedIcon: false,
                segments: [
                  for (final r in MemberRole.values)
                    ButtonSegment(value: r, label: Text(roleLabel(r))),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
              ),
              const SizedBox(height: MkSpacing.xs),
              Text(
                roleHelp[_role]!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_err != null)
              Padding(
                padding: const EdgeInsets.only(top: MkSpacing.md),
                child: Text(
                  _err!,
                  key: const ValueKey('create-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const ValueKey('create-save'),
        onPressed: _busy ? null : _save,
        child: const Text('Create'),
      ),
    ],
  );
}

/// One person: password, enable / disable, and for each business the role,
/// device limit and a switch for every feature.
class UserAccessDialog extends ConsumerStatefulWidget {
  const UserAccessDialog({required this.user, super.key});

  final Map<String, Object?> user;

  @override
  ConsumerState<UserAccessDialog> createState() => _UserAccessDialogState();
}

class _UserAccessDialogState extends ConsumerState<UserAccessDialog> {
  late List<Map<String, Object?>> _memberships = rows(
    widget.user['memberships'],
  );
  int _selected = 0;
  bool _changed = false;

  // Edits of the selected business, not yet saved.
  MemberRole _role = MemberRole.munshi;
  Map<String, Object?> _custom = {};
  bool _active = true;
  int _devices = 5;
  bool _dirty = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _userId => '${widget.user['user_id']}';

  void _load() {
    if (_memberships.isEmpty) return;
    final m = _memberships[_selected];
    _role = MemberRole.parse('${m['role']}');
    _custom = Map<String, Object?>.from(asMap(m['custom_permissions']));
    _active = m['is_active'] == true;
    _devices = (m['device_limit'] as num?)?.toInt() ?? 5;
    _dirty = false;
  }

  void _toast(String text, {bool error = false}) => MkToast.show(
    context,
    text,
    tone: error ? MkToastTone.error : MkToastTone.success,
  );

  Future<void> _run(Future<void> Function() body) async {
    setState(() => _busy = true);
    try {
      await body();
    } on Object catch (e) {
      if (mounted) _toast(_error(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() => _run(() async {
    final m = _memberships[_selected];
    final saved = asMap(
      await ref.read(adminApiProvider).call('member_set_access', {
        'tenant_id': m['tenant_id'],
        'user_id': _userId,
        'role': _role.name,
        'custom_permissions': _custom,
        'is_active': _active,
        'device_limit': _devices,
      }),
    );
    _memberships[_selected] = {
      ...m,
      'role': saved['role'],
      'custom_permissions': saved['custom_permissions'],
      'is_active': saved['is_active'],
      'device_limit': saved['device_limit'],
    };
    _changed = true;
    _dirty = false;
    if (mounted) _toast('Access saved. Applies on their next sync.');
  });

  Future<void> _resetPassword() => _run(() async {
    final r = asMap(
      await ref.read(adminApiProvider).call('user_reset_password', {
        'user_id': _userId,
      }),
    );
    if (!mounted) return;
    await showPasswordOnce(
      context,
      email: '${widget.user['email']}',
      password: '${r['password']}',
    );
  });

  Future<void> _toggleBan() => _run(() async {
    final banned = widget.user['is_banned'] == true;
    await ref.read(adminApiProvider).call('user_set_banned', {
      'user_id': _userId,
      'banned': !banned,
    });
    widget.user['is_banned'] = !banned;
    _changed = true;
    if (mounted) {
      setState(() {});
      _toast(banned ? 'User enabled.' : 'User disabled. They cannot sign in.');
    }
  });

  Future<void> _addToBusiness() async {
    final tenants = rows(
      await ref.read(adminApiProvider).call('businesses_brief'),
    );
    final have = {for (final m in _memberships) '${m['tenant_id']}'};
    final free = [
      for (final t in tenants)
        if (!have.contains('${t['id']}')) t,
    ];
    if (!mounted) return;
    final picked = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (c) => SimpleDialog(
        title: const Text('Add to a business'),
        children: [
          if (free.isEmpty)
            const Padding(
              padding: EdgeInsets.all(MkSpacing.lg),
              child: Text('Already in every business.'),
            ),
          for (final t in free)
            SimpleDialogOption(
              onPressed: () => Navigator.of(c).pop(t),
              child: Text('${t['name']}'),
            ),
        ],
      ),
    );
    if (picked == null) return;
    await _run(() async {
      final saved = asMap(
        await ref.read(adminApiProvider).call('member_set_access', {
          'tenant_id': picked['id'],
          'user_id': _userId,
          'role': 'munshi',
          'is_active': true,
        }),
      );
      _memberships = [
        ..._memberships,
        {
          'tenant_id': picked['id'],
          'tenant_name': picked['name'],
          'role': saved['role'],
          'is_active': saved['is_active'],
          'custom_permissions': saved['custom_permissions'],
          'device_limit': saved['device_limit'],
        },
      ];
      _selected = _memberships.length - 1;
      _changed = true;
      if (mounted) setState(_load);
    });
  }

  void _setAccess(FeatureDef f, Access a) => setState(() {
    switch (a) {
      case Access.byRole:
        _custom.remove(f.key);
      case Access.allow:
        _custom[f.key] = true;
      case Access.deny:
        _custom[f.key] = false;
    }
    _dirty = true;
  });

  void _preset(bool? value) => setState(() {
    _custom = {
      if (value != null)
        for (final g in featureGroups)
          for (final f in g.features) f.key: value,
    };
    _dirty = true;
  });

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final name = '${u['full_name'] ?? ''}'.trim();
    final banned = u['is_banned'] == true;
    final isPlatformAdmin = u['is_platform_admin'] == true;
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(MkSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? '${u['email']}' : name,
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          [
                            if (name.isNotEmpty) '${u['email']}',
                            ?(u['phone'] as String?),
                          ].join(' · '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (!isPlatformAdmin) ...[
                    OutlinedButton.icon(
                      key: const ValueKey('user-reset-password'),
                      onPressed: _busy ? null : _resetPassword,
                      icon: const Icon(Icons.key_outlined),
                      label: const Text('New password'),
                    ),
                    const SizedBox(width: MkSpacing.sm),
                    OutlinedButton.icon(
                      key: const ValueKey('user-toggle-ban'),
                      onPressed: _busy ? null : _toggleBan,
                      icon: Icon(
                        banned ? Icons.lock_open : Icons.block_outlined,
                      ),
                      label: Text(banned ? 'Enable' : 'Disable'),
                    ),
                  ],
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(_changed),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(MkSpacing.lg),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: MkSpacing.sm,
                          children: [
                            for (final (i, m) in _memberships.indexed)
                              ChoiceChip(
                                key: ValueKey('biz-$i'),
                                label: Text('${m['tenant_name']}'),
                                selected: i == _selected,
                                onSelected: (_) => setState(() {
                                  _selected = i;
                                  _load();
                                }),
                              ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        key: const ValueKey('user-add-business'),
                        onPressed: _busy ? null : _addToBusiness,
                        icon: const Icon(Icons.add_business_outlined),
                        label: const Text('Add to a business'),
                      ),
                    ],
                  ),
                  if (_memberships.isEmpty)
                    const MkEmptyState(
                      icon: Icons.storefront_outlined,
                      title: 'Not in any business yet.',
                    )
                  else
                    ..._access(theme),
                ],
              ),
            ),
            if (_memberships.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(MkSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dirty
                            ? 'Unsaved changes'
                            : featureCount(_role, _custom),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    FilledButton(
                      key: const ValueKey('access-save'),
                      onPressed: _busy || !_dirty ? null : _save,
                      child: const Text('Save access'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _access(ThemeData theme) {
    final isOwner = _role == MemberRole.owner;
    return [
      const SizedBox(height: MkSpacing.lg),
      Text('Role', style: theme.textTheme.titleSmall),
      const SizedBox(height: MkSpacing.sm),
      SegmentedButton<MemberRole>(
        key: const ValueKey('access-role'),
        showSelectedIcon: false,
        segments: [
          for (final r in MemberRole.values)
            ButtonSegment(value: r, label: Text(roleLabel(r))),
        ],
        selected: {_role},
        onSelectionChanged: (s) => setState(() {
          _role = s.first;
          _dirty = true;
        }),
      ),
      const SizedBox(height: MkSpacing.xs),
      Text(roleHelp[_role]!, style: theme.textTheme.bodySmall),
      const SizedBox(height: MkSpacing.md),
      Row(
        children: [
          Expanded(
            child: SwitchListTile(
              key: const ValueKey('access-active'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Can use this business'),
              subtitle: const Text('Off: signed out of it on the next sync.'),
              value: _active,
              onChanged: (v) => setState(() {
                _active = v;
                _dirty = true;
              }),
            ),
          ),
          const SizedBox(width: MkSpacing.lg),
          const Text('Devices'),
          IconButton(
            onPressed: _devices > 1
                ? () => setState(() {
                    _devices--;
                    _dirty = true;
                  })
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$_devices'),
          IconButton(
            onPressed: _devices < 50
                ? () => setState(() {
                    _devices++;
                    _dirty = true;
                  })
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      const SizedBox(height: MkSpacing.md),
      Row(
        children: [
          Expanded(child: Text('Features', style: theme.textTheme.titleSmall)),
          if (!isOwner) ...[
            TextButton(
              key: const ValueKey('preset-role'),
              onPressed: () => _preset(null),
              child: const Text('Follow role'),
            ),
            TextButton(
              key: const ValueKey('preset-all'),
              onPressed: () => _preset(true),
              child: const Text('Allow all'),
            ),
            TextButton(
              key: const ValueKey('preset-none'),
              onPressed: () => _preset(false),
              child: const Text('Allow none'),
            ),
          ],
        ],
      ),
      if (isOwner)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: MkSpacing.sm),
          child: Text('An owner always has every feature.'),
        ),
      for (final g in featureGroups)
        Padding(
          padding: const EdgeInsets.only(top: MkSpacing.md),
          child: MkCard(
            title: g.title,
            child: Column(
              children: [for (final f in g.features) _featureRow(f, isOwner)],
            ),
          ),
        ),
    ];
  }

  Widget _featureRow(FeatureDef f, bool isOwner) {
    final access = Access.of(_custom, f.key);
    final on = isOwner || effective(_role, _custom, f.permission);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MkSpacing.xs),
      child: Row(
        key: ValueKey('feature-${f.key}'),
        children: [
          Icon(
            on ? Icons.check_circle : Icons.cancel_outlined,
            size: 20,
            color: on ? MkColors.jama : MkColors.textFaint,
          ),
          const SizedBox(width: MkSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.label),
                Text(f.help, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          SegmentedButton<Access>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            segments: const [
              ButtonSegment(value: Access.byRole, label: Text('Role')),
              ButtonSegment(value: Access.allow, label: Text('Allow')),
              ButtonSegment(value: Access.deny, label: Text('Deny')),
            ],
            selected: {access},
            onSelectionChanged: isOwner ? null : (s) => _setAccess(f, s.first),
          ),
        ],
      ),
    );
  }
}
