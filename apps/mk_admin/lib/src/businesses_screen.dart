import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/tenant_detail.dart';
import 'package:mk_ui/mk_ui.dart';

/// All customers: status, plan, users, devices, last sync, size, MRR.
class BusinessesScreen extends ConsumerStatefulWidget {
  const BusinessesScreen({super.key});

  @override
  ConsumerState<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends ConsumerState<BusinessesScreen> {
  late Future<List<Map<String, Object?>>> _future = _load();
  String _query = '';
  String _status = 'all';

  Future<List<Map<String, Object?>>> _load() async =>
      rows(await ref.read(adminApiProvider).call('overview'));

  static String _date(Object? iso) => iso == null
      ? ''
      : DateFormat('d MMM y').format(DateTime.parse('$iso').toLocal());

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _future,
    builder: (context, snap) {
      if (snap.hasError) return Center(child: Text('${snap.error}'));
      final all = snap.data;
      if (all == null) return const Center(child: CircularProgressIndicator());
      final shown = [
        for (final r in all)
          if ((_status == 'all' || r['status'] == _status) &&
              ('${r['name']}'.toLowerCase().contains(_query.toLowerCase()) ||
                  '${r['referral_code']}'.toLowerCase().contains(
                    _query.toLowerCase(),
                  )))
            r,
      ];
      final mrr = all.fold<int>(
        0,
        (s, r) => s + ((r['mrr_paise'] as num?)?.toInt() ?? 0),
      );
      return ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          Wrap(
            spacing: MkSpacing.md,
            runSpacing: MkSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: MkTextField(
                  key: const ValueKey('business-search'),
                  hint: 'Search name or referral code',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              DropdownMenu<String>(
                initialSelection: _status,
                onSelected: (v) => setState(() => _status = v ?? 'all'),
                dropdownMenuEntries: [
                  for (final s in const [
                    'all',
                    'trial',
                    'active',
                    'past_due',
                    'grace',
                    'locked',
                    'cancelled',
                  ])
                    DropdownMenuEntry(value: s, label: s),
                ],
              ),
              Text('${shown.length} of ${all.length} businesses'),
              Text(
                'MRR ${Money(mrr).format()}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              IconButton(
                tooltip: 'Reload',
                onPressed: () => setState(() {
                  _future = _load();
                }),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          MkCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text('Business')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Access')),
                  DataColumn(label: Text('Plan')),
                  DataColumn(label: Text('Users')),
                  DataColumn(label: Text('Devices')),
                  DataColumn(label: Text('Parties')),
                  DataColumn(label: Text('Entries')),
                  DataColumn(label: Text('Last seen')),
                  DataColumn(label: Text('Ends')),
                  DataColumn(label: Text('MRR')),
                ],
                rows: [
                  for (final r in shown)
                    DataRow(
                      onSelectChanged: (_) => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TenantDetailScreen(
                            tenantId: '${r['tenant_id']}',
                            name: '${r['name']}',
                          ),
                        ),
                      ),
                      cells: [
                        DataCell(Text('${r['name']}')),
                        DataCell(Text('${r['status']}')),
                        DataCell(Text('${r['access']}')),
                        DataCell(Text('${r['plan_code']}')),
                        DataCell(Text('${r['users']}')),
                        DataCell(Text('${r['devices']}')),
                        DataCell(Text('${r['parties']}')),
                        DataCell(Text('${r['ledger_entries']}')),
                        DataCell(Text(_date(r['last_seen_at']))),
                        DataCell(
                          Text(
                            _date(
                              r['status'] == 'trial'
                                  ? r['trial_ends_at']
                                  : r['current_period_end'],
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            Money(
                              (r['mrr_paise'] as num?)?.toInt() ?? 0,
                            ).format(),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
