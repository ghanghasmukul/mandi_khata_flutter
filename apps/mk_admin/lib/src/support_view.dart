import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/form_fields.dart';
import 'package:mk_ui/mk_ui.dart';

/// Asks for a reason, opens a support session (the customer sees it under
/// Plan & billing) and shows a read-only snapshot. Closing the page ends the
/// session. Nothing can be edited from here.
Future<void> startSupportView(
  BuildContext context,
  WidgetRef ref, {
  required String tenantId,
  required String name,
}) async {
  final text = await promptText(
    context,
    title: 'Why do you need to look?',
    label: 'Reason (the customer will see this)',
    required: true,
    confirmLabel: 'Open',
    fieldKey: const ValueKey('support-reason'),
    confirmKey: const ValueKey('support-confirm'),
  );
  if (text == null || text.isEmpty || !context.mounted) return;
  final api = ref.read(adminApiProvider);
  final started = asMap(
    await api.call('support_start', {'tenant_id': tenantId, 'reason': text}),
  );
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SupportViewScreen(
        name: name,
        reason: text,
        snapshot: asMap(started['snapshot']),
      ),
    ),
  );
  await api.call('support_end', {'session_id': started['session_id']});
}

class SupportViewScreen extends StatelessWidget {
  const SupportViewScreen({
    required this.name,
    required this.reason,
    required this.snapshot,
    super.key,
  });

  final String name;
  final String reason;
  final Map<String, Object?> snapshot;

  @override
  Widget build(BuildContext context) {
    final counts = asMap(snapshot['counts']);
    return Scaffold(
      appBar: AppBar(title: Text('Support view: $name (read-only)')),
      body: ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          MkCard(
            title: 'Session',
            child: Text(
              'Reason: $reason. The customer can see this session. '
              'Access: ${snapshot['access']}. '
              'Members ${counts['members']}, devices ${counts['devices']}, '
              'parties ${counts['parties']}, entries ${counts['ledger_entries']}.',
            ),
          ),
          const SizedBox(height: MkSpacing.md),
          MkCard(
            title: 'Team',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final m in rows(snapshot['members']))
                  Text(
                    '${m['name'] ?? '-'}  ·  ${m['phone'] ?? ''}  ·  ${m['role']}'
                    '${m['active'] == true ? '' : '  (inactive)'}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: MkSpacing.md),
          MkCard(
            title: 'Recent khata entries',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in rows(snapshot['recent_entries']))
                  Text(
                    '${e['date']}  ·  ${e['party']}  ·  ${e['side']}  ·  '
                    '${Money((e['amount_paise']! as num).toInt()).format()}  ·  ${e['ref_type']}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: MkSpacing.md),
          MkCard(
            title: 'Recent audit log',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final a in rows(snapshot['recent_audit']))
                  Text(
                    '${a['created_at']}  ·  ${a['role'] ?? ''}  ·  ${a['action']}  ·  '
                    '${a['table_name']}  ·  ${jsonEncode(a['after'])}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
