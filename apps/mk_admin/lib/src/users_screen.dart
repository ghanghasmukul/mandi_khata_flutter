import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_admin/src/access_catalog.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/user_access_dialog.dart';
import 'package:mk_ui/mk_ui.dart';

/// Everyone who can sign in: create users, give them a business and a role,
/// and switch features on and off for each person.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  late Future<List<Map<String, Object?>>> _future = _load();
  String _query = '';

  Future<List<Map<String, Object?>>> _load() async =>
      rows(await ref.read(adminApiProvider).call('users_list'));

  void _reload() {
    final next = _load();
    setState(() {
      _future = next;
    });
  }

  Future<void> _create() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const CreateUserDialog(),
    );
    if (created == true) _reload();
  }

  Future<void> _open(Map<String, Object?> user) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => UserAccessDialog(user: user),
    );
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _future,
    builder: (context, snap) {
      if (snap.hasError) return Center(child: Text('${snap.error}'));
      final all = snap.data;
      if (all == null) return const Center(child: CircularProgressIndicator());
      final q = _query.toLowerCase();
      final shown = [
        for (final u in all)
          if ('${u['email']} ${u['full_name']} ${u['phone']}'
              .toLowerCase()
              .contains(q))
            u,
      ];
      final active = all.where((u) => u['is_banned'] != true).length;
      return ListView(
        padding: const EdgeInsets.all(MkSpacing.xl),
        children: [
          Row(
            children: [
              _Stat('Users', '${all.length}', Icons.people_outline),
              const SizedBox(width: MkSpacing.md),
              _Stat('Active', '$active', Icons.verified_user_outlined),
              const SizedBox(width: MkSpacing.md),
              _Stat(
                'Without a business',
                '${all.where((u) => rows(u['memberships']).isEmpty).length}',
                Icons.link_off,
              ),
            ],
          ),
          const SizedBox(height: MkSpacing.lg),
          Row(
            children: [
              SizedBox(
                width: 300,
                child: MkTextField(
                  key: const ValueKey('user-search'),
                  hint: 'Search name, email or phone',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const Spacer(),
              MkButton(
                key: const ValueKey('user-create'),
                label: 'Create user',
                icon: Icons.person_add_alt_1_outlined,
                onPressed: _create,
              ),
            ],
          ),
          const SizedBox(height: MkSpacing.lg),
          if (shown.isEmpty)
            const MkEmptyState(
              icon: Icons.person_search_outlined,
              title: 'No users match.',
            ),
          for (final u in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: MkSpacing.sm),
              child: _UserTile(user: u, onTap: () => _open(u)),
            ),
        ],
      );
    },
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
    child: MkCard(
      child: Row(
        children: [
          Icon(icon, color: MkColors.brand),
          const SizedBox(width: MkSpacing.md),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onTap});

  final Map<String, Object?> user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = '${user['full_name'] ?? ''}'.trim();
    final email = '${user['email'] ?? ''}';
    final memberships = rows(user['memberships']);
    final banned = user['is_banned'] == true;
    final last = user['last_sign_in_at'];
    return MkCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: MkSpacing.lg,
        vertical: MkSpacing.md,
      ),
      child: Row(
        key: ValueKey('user-${user['user_id']}'),
        children: [
          CircleAvatar(
            backgroundColor: MkColors.brand,
            child: Text(
              (name.isEmpty ? email : name).characters.first.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: MkSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name.isEmpty ? email : name,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user['is_platform_admin'] == true) ...[
                      const SizedBox(width: MkSpacing.sm),
                      const MkRoleChip(label: 'Super admin'),
                    ],
                    if (banned) ...[
                      const SizedBox(width: MkSpacing.sm),
                      const MkRoleChip(label: 'Disabled', warning: true),
                    ],
                  ],
                ),
                Text(
                  [
                    if (name.isNotEmpty) email,
                    if (user['phone'] != null) '${user['phone']}',
                    if (last == null)
                      'never signed in'
                    else
                      'last seen ${DateFormat('d MMM y').format(DateTime.parse('$last').toLocal())}',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Wrap(
            spacing: MkSpacing.xs,
            children: [
              for (final m in memberships.take(3))
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    '${m['tenant_name']} · ${m['role']}'
                    '${m['is_active'] == true ? '' : ' (off)'}',
                  ),
                ),
              if (memberships.length > 3)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('+${memberships.length - 3}'),
                ),
              if (memberships.isEmpty)
                const Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('no business'),
                ),
            ],
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

/// Role chips for the pickers.
String roleLabel(MemberRole r) => switch (r) {
  MemberRole.owner => 'Owner',
  MemberRole.accountant => 'Accountant',
  MemberRole.munshi => 'Munshi',
  MemberRole.custom => 'Custom',
};

/// A summary such as "9 of 16 features".
String featureCount(MemberRole role, Map<String, Object?> custom) {
  var on = 0;
  var total = 0;
  for (final g in featureGroups) {
    for (final f in g.features) {
      total++;
      if (effective(role, custom, f.permission)) on++;
    }
  }
  return '$on of $total features';
}
