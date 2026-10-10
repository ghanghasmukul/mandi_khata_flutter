import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_ui/mk_ui.dart';

/// How long a number of seconds is, in words a support person can read.
String lagText(int? seconds) {
  if (seconds == null) return '–';
  if (seconds < 90) return '${seconds}s';
  if (seconds < 5400) return '${(seconds / 60).round()} min';
  if (seconds < 172800) return '${(seconds / 3600).round()} h';
  return '${(seconds / 86400).round()} d';
}

/// Whether a business needs a look: its entries waited long on the device, or
/// its devices went quiet.
bool needsAttention({
  required int entries,
  required int? lagP95,
  required int late,
  required DateTime? lastSeen,
  required DateTime now,
}) {
  if (entries > 0 && (lagP95 ?? 0) > 3600) return true;
  if (entries > 0 && late * 5 > entries) return true;
  return lastSeen != null && now.difference(lastSeen).inDays >= 7;
}

/// Per business: how long entries wait on a device before they reach the
/// server (offline time or a stuck upload queue) and when devices were last
/// seen. Source: `admin_sync_health`.
class SyncHealthScreen extends ConsumerWidget {
  const SyncHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.read(adminApiProvider).call('sync_health', {'days': 7}),
    builder: (context, snap) {
      if (snap.hasError) return Center(child: Text('${snap.error}'));
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final fmt = DateFormat('d MMM, HH:mm');
      final now = DateTime.now();
      return ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          const Text(
            'Last 7 days. Lag = time an entry waited on the device before '
            'it reached the server (includes offline time).',
          ),
          const SizedBox(height: MkSpacing.md),
          for (final r in rows(snap.data))
            Builder(
              builder: (context) {
                final seen = r['last_seen_at'] == null
                    ? null
                    : DateTime.parse('${r['last_seen_at']}').toLocal();
                final warn = needsAttention(
                  entries: (r['entries'] as num?)?.toInt() ?? 0,
                  lagP95: (r['lag_p95_seconds'] as num?)?.toInt(),
                  late: (r['late_entries'] as num?)?.toInt() ?? 0,
                  lastSeen: seen,
                  now: now,
                );
                return ListTile(
                  key: ValueKey('health-${r['tenant_id']}'),
                  leading: Icon(
                    warn ? Icons.warning_amber_rounded : Icons.check_circle,
                    color: warn ? Colors.orange : Colors.green,
                  ),
                  title: Text('${r['name']}'),
                  subtitle: Text(
                    '${r['entries']} entries · lag median '
                    '${lagText((r['lag_p50_seconds'] as num?)?.toInt())}, '
                    '95% ${lagText((r['lag_p95_seconds'] as num?)?.toInt())}, '
                    'worst ${lagText((r['lag_max_seconds'] as num?)?.toInt())}'
                    ' · ${r['late_entries']} over 1 h',
                  ),
                  trailing: Text(
                    seen == null
                        ? 'never seen'
                        : '${r['active_devices']} dev · ${fmt.format(seen)}',
                  ),
                );
              },
            ),
        ],
      );
    },
  );
}
