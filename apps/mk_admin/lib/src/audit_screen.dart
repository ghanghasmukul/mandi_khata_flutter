import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_ui/mk_ui.dart';

/// Every super-admin action, newest first.
class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.read(adminApiProvider).call('audit_list'),
    builder: (context, snap) {
      if (snap.hasError) return Center(child: Text('${snap.error}'));
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return AdminLogList(rows: rows(snap.data));
    },
  );
}

class AdminLogList extends StatelessWidget {
  const AdminLogList({required this.rows, super.key});

  final List<Map<String, Object?>> rows;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM y, HH:mm');
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(MkSpacing.lg),
      children: [
        for (final r in rows)
          ListTile(
            dense: true,
            title: Text('${r['action']}  ·  ${r['admin_email'] ?? ''}'),
            subtitle: Text(
              [
                if (r['note'] != null) '${r['note']}',
                if (r['target_id'] != null)
                  '${r['target_type']}: ${r['target_id']}',
              ].join('  ·  '),
            ),
            trailing: Text(
              fmt.format(DateTime.parse('${r['created_at']}').toLocal()),
            ),
          ),
      ],
    );
  }
}
