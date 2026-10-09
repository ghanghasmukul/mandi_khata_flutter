import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/form_fields.dart';
import 'package:mk_admin/src/tenant_detail.dart';
import 'package:mk_ui/mk_ui.dart';

/// Plan and add-on requests from customers, waiting for a decision.
class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  late Future<List<Map<String, Object?>>> _future = _load();

  Future<List<Map<String, Object?>>> _load() async => rows(
    await ref.read(adminApiProvider).call('requests_list', {
      'status': 'pending',
    }),
  );

  Future<void> _resolve(Map<String, Object?> r, String status) async {
    final text = await promptText(
      context,
      title: status == 'done' ? 'Mark as done' : 'Decline',
      label: 'Note for the customer (optional)',
    );
    if (text == null) return;
    await ref.read(adminApiProvider).call('request_resolve', {
      'id': r['id'],
      'status': status,
      'note': text,
    });
    if (mounted) {
      setState(() {
        _future = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _future,
    builder: (context, snap) {
      if (snap.hasError) return Center(child: Text('${snap.error}'));
      final data = snap.data;
      if (data == null) return const Center(child: CircularProgressIndicator());
      if (data.isEmpty) {
        return const Center(child: Text('No pending requests.'));
      }
      final fmt = DateFormat('d MMM y, HH:mm');
      return ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          for (final r in data)
            MkCard(
              title: '${asMap(r['tenants'])['name'] ?? r['tenant_id']}',
              trailing: Text(
                fmt.format(DateTime.parse('${r['created_at']}').toLocal()),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      if (r['requested_plan_code'] != null)
                        'Plan: ${r['requested_plan_code']}',
                      if (r['billing_cycle'] != null) '${r['billing_cycle']}',
                      if ((r['addons'] as List?)?.isNotEmpty ?? false)
                        'Add-ons: ${(r['addons']! as List).map((a) => '${(a as Map)['code']} x${a['qty']}').join(', ')}',
                    ].join('  ·  '),
                  ),
                  if (r['note'] != null) Text('“${r['note']}”'),
                  const SizedBox(height: MkSpacing.sm),
                  Wrap(
                    spacing: MkSpacing.sm,
                    children: [
                      MkButton(
                        label: 'Open business',
                        variant: MkButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TenantDetailScreen(
                              tenantId: '${r['tenant_id']}',
                              name: '${asMap(r['tenants'])['name'] ?? ''}',
                            ),
                          ),
                        ),
                      ),
                      MkButton(
                        key: ValueKey('done-${r['id']}'),
                        label: 'Mark done',
                        onPressed: () => _resolve(r, 'done'),
                      ),
                      MkButton(
                        label: 'Decline',
                        variant: MkButtonVariant.ghost,
                        onPressed: () => _resolve(r, 'rejected'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}
