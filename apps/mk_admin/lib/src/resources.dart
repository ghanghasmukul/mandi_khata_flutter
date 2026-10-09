import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/form_fields.dart';
import 'package:mk_ui/mk_ui.dart';

/// One column of a list.
class ColumnSpec {
  const ColumnSpec(this.label, this.value);

  final String label;
  final String Function(Map<String, Object?> row) value;
}

/// A simple "list, edit one, add one" resource backed by two `admin-api`
/// actions. Plans, presets, crops, referral codes, announcements and platform
/// settings are all this shape, so one screen serves them.
class ResourceConfig {
  const ResourceConfig({
    required this.title,
    required this.listAction,
    required this.upsertAction,
    required this.fields,
    required this.columns,
    this.rowsOf,
    this.carryKeys = const [],
    this.note,
  });

  final String title;
  final String listAction;
  final String upsertAction;
  final List<FieldSpec> fields;
  final List<ColumnSpec> columns;

  /// Picks the rows out of a list result that holds several lists.
  final List<Map<String, Object?>> Function(Object? data)? rowsOf;

  /// Keys copied from the edited row into the request (ids).
  final List<String> carryKeys;
  final String? note;
}

String _rupees(Object? paise) => paise is int ? Money(paise).format() : '';
String _yes(Object? v) => v == true ? 'yes' : 'no';
String _text(Object? v) => v?.toString() ?? '';

const platformSettingsResource = ResourceConfig(
  title: 'Platform settings',
  listAction: 'platform_settings_list',
  upsertAction: 'platform_setting_set',
  note:
      'Trial length, grace, signup rules. Public ones are readable by every '
      'device (offline tolerance, signup on/off).',
  fields: [
    FieldSpec(
      'key',
      'Key',
      FieldKind.text,
      required: true,
      lockedWhenEditing: true,
    ),
    FieldSpec(
      'value',
      'Value (JSON)',
      FieldKind.json,
      required: true,
      hint: '14 or "trial" or true',
    ),
    FieldSpec(
      'is_public',
      'Public (devices can read it)',
      FieldKind.boolean,
      initial: false,
    ),
    FieldSpec('description', 'Description', FieldKind.text),
  ],
  columns: [
    ColumnSpec('Key', _key),
    ColumnSpec('Value', _value),
    ColumnSpec('Public', _public),
    ColumnSpec('Description', _desc),
  ],
);
String _key(Map<String, Object?> r) => _text(r['key']);
String _value(Map<String, Object?> r) => _text(r['value']);
String _public(Map<String, Object?> r) => _yes(r['is_public']);
String _desc(Map<String, Object?> r) => _text(r['description']);

final statePresetsResource = ResourceConfig(
  title: 'State presets',
  listAction: 'presets_list',
  upsertAction: 'preset_upsert',
  note:
      'Settings copied into a new business of that state at signup, for '
      'example {"mandi.commission_pct": "2.5"}. Keys must exist in the '
      'settings schema; an invalid value is ignored by the app. Fee schedules '
      'change each year: check them before filling these in.',
  fields: const [
    FieldSpec(
      'state_code',
      'GST state code',
      FieldKind.text,
      required: true,
      lockedWhenEditing: true,
      hint: '03',
    ),
    FieldSpec('name', 'Name', FieldKind.text, required: true),
    FieldSpec('settings', 'Settings (JSON)', FieldKind.json),
    FieldSpec('is_active', 'Active', FieldKind.boolean, initial: true),
  ],
  columns: [
    ColumnSpec('Code', (r) => _text(r['state_code'])),
    ColumnSpec('State', (r) => _text(r['name'])),
    ColumnSpec('Settings', (r) => '${(r['settings'] as Map?)?.length ?? 0}'),
    ColumnSpec('Active', (r) => _yes(r['is_active'])),
  ],
);

final cropMasterResource = ResourceConfig(
  title: 'Crop master',
  listAction: 'crops_list',
  upsertAction: 'crop_upsert',
  note:
      'The crops every new business starts with. "Push to all businesses" '
      'adds crops a business lacks; it never renames or removes theirs.',
  fields: const [
    FieldSpec(
      'code',
      'Code',
      FieldKind.text,
      required: true,
      lockedWhenEditing: true,
      hint: 'wheat',
    ),
    FieldSpec('name_en', 'Name (English)', FieldKind.text, required: true),
    FieldSpec('name_hi', 'Name (Hindi)', FieldKind.text),
    FieldSpec('name_pa', 'Name (Punjabi)', FieldKind.text),
    FieldSpec(
      'msp_or_std_rate',
      'MSP or standard rate (₹ per qtl)',
      FieldKind.rupees,
    ),
    FieldSpec('sort_order', 'Order', FieldKind.integer, initial: 0),
    FieldSpec('is_active', 'Active', FieldKind.boolean, initial: true),
  ],
  columns: [
    ColumnSpec('Code', (r) => _text(r['code'])),
    ColumnSpec('English', (r) => _text(r['name_en'])),
    ColumnSpec('Hindi', (r) => _text(r['name_hi'])),
    ColumnSpec('Punjabi', (r) => _text(r['name_pa'])),
    ColumnSpec('Rate', (r) => _rupees(r['msp_or_std_rate'])),
    ColumnSpec('Active', (r) => _yes(r['is_active'])),
  ],
);

final referralsResource = ResourceConfig(
  title: 'Referral codes',
  listAction: 'referrals_list',
  upsertAction: 'referral_upsert',
  fields: const [
    FieldSpec(
      'code',
      'Code',
      FieldKind.text,
      required: true,
      lockedWhenEditing: true,
      hint: 'DEALER-1',
    ),
    FieldSpec('owner_name', 'Dealer / agent', FieldKind.text, required: true),
    FieldSpec('commission_pct', 'Commission %', FieldKind.decimal, initial: 0),
    FieldSpec('is_active', 'Active', FieldKind.boolean, initial: true),
    FieldSpec('note', 'Note', FieldKind.text),
  ],
  columns: [
    ColumnSpec('Code', (r) => _text(r['code'])),
    ColumnSpec('Dealer', (r) => _text(r['owner_name'])),
    ColumnSpec('Commission %', (r) => _text(r['commission_pct'])),
    ColumnSpec('Active', (r) => _yes(r['is_active'])),
  ],
);

final announcementsResource = ResourceConfig(
  title: 'Announcements',
  listAction: 'announcements_list',
  upsertAction: 'announcement_upsert',
  carryKeys: const ['id'],
  note:
      'Shown as a banner in every customer app (all businesses, or only the '
      'plans listed). Visible on every customer device: never put private '
      'information here.',
  fields: const [
    FieldSpec('title_en', 'Title (English)', FieldKind.text, required: true),
    FieldSpec('title_hi', 'Title (Hindi)', FieldKind.text),
    FieldSpec('title_pa', 'Title (Punjabi)', FieldKind.text),
    FieldSpec('body_en', 'Message (English)', FieldKind.multiline),
    FieldSpec('body_hi', 'Message (Hindi)', FieldKind.multiline),
    FieldSpec('body_pa', 'Message (Punjabi)', FieldKind.multiline),
    FieldSpec(
      'severity',
      'Severity',
      FieldKind.choice,
      choices: ['info', 'warning', 'critical'],
    ),
    FieldSpec(
      'plan_codes',
      'Only for plans (one code per line, empty = all)',
      FieldKind.lines,
    ),
    FieldSpec(
      'starts_at',
      'Starts (ISO date-time, optional)',
      FieldKind.text,
      hint: '2027-04-01T00:00:00Z',
    ),
    FieldSpec('ends_at', 'Ends (ISO date-time, optional)', FieldKind.text),
    FieldSpec('is_active', 'Active', FieldKind.boolean, initial: true),
  ],
  columns: [
    ColumnSpec('Title', (r) => _text(r['title_en'])),
    ColumnSpec('Severity', (r) => _text(r['severity'])),
    ColumnSpec('Plans', (r) => (r['plan_codes'] as List?)?.join(', ') ?? 'all'),
    ColumnSpec('Active', (r) => _yes(r['is_active'])),
  ],
);

final plansResource = ResourceConfig(
  title: 'Plans',
  listAction: 'plans_list',
  upsertAction: 'plan_upsert',
  rowsOf: (d) => rows(asMap(d)['plans']),
  note:
      'Prices are in rupees. Users / devices empty = unlimited. Limits is '
      'JSON, for example {"parties": 2000}. Default settings become the plan '
      'level of the settings cascade.',
  fields: const [
    FieldSpec(
      'code',
      'Code',
      FieldKind.text,
      required: true,
      lockedWhenEditing: true,
      hint: 'mandi_pro',
    ),
    FieldSpec('name', 'Name', FieldKind.text, required: true),
    FieldSpec('description', 'Description', FieldKind.text),
    FieldSpec(
      'price_monthly_paise',
      'Price per month (₹)',
      FieldKind.rupees,
      initial: 0,
    ),
    FieldSpec(
      'price_yearly_paise',
      'Price per year (₹)',
      FieldKind.rupees,
      initial: 0,
    ),
    FieldSpec('max_users', 'Max users', FieldKind.integer),
    FieldSpec('max_devices', 'Max devices', FieldKind.integer),
    FieldSpec('modules', 'Modules', FieldKind.modules),
    FieldSpec('limits', 'Other limits (JSON)', FieldKind.json),
    FieldSpec('default_settings', 'Default settings (JSON)', FieldKind.json),
    FieldSpec(
      'is_public',
      'Offered to new customers',
      FieldKind.boolean,
      initial: false,
    ),
    FieldSpec('is_active', 'Active', FieldKind.boolean, initial: true),
    FieldSpec('sort_order', 'Order', FieldKind.integer, initial: 0),
  ],
  columns: [
    ColumnSpec('Code', (r) => _text(r['code'])),
    ColumnSpec('Name', (r) => _text(r['name'])),
    ColumnSpec('Monthly', (r) => _rupees(r['price_monthly_paise'])),
    ColumnSpec('Yearly', (r) => _rupees(r['price_yearly_paise'])),
    ColumnSpec('Users', (r) => _text(r['max_users'] ?? 'no limit')),
    ColumnSpec('Devices', (r) => _text(r['max_devices'] ?? 'no limit')),
    ColumnSpec(
      'Modules',
      (r) => [
        for (final e in ((r['modules'] as Map?) ?? const {}).entries)
          if (e.value == true) e.key,
      ].join(', '),
    ),
    ColumnSpec('Public', (r) => _yes(r['is_public'])),
    ColumnSpec('Active', (r) => _yes(r['is_active'])),
  ],
);

final addonsResource = ResourceConfig(
  title: 'Add-ons',
  listAction: 'plans_list',
  upsertAction: 'addon_upsert',
  rowsOf: (d) => rows(asMap(d)['addons']),
  note:
      'Granted per unit bought: "Limits granted" like {"users": 1}; modules '
      'switch on. Quantity is capped by the maximum.',
  fields: const [
    FieldSpec(
      'code',
      'Code',
      FieldKind.text,
      required: true,
      lockedWhenEditing: true,
      hint: 'extra_user',
    ),
    FieldSpec('name', 'Name', FieldKind.text, required: true),
    FieldSpec('description', 'Description', FieldKind.text),
    FieldSpec(
      'grants_limits',
      'Limits granted per unit (JSON)',
      FieldKind.json,
    ),
    FieldSpec('grants_modules', 'Modules granted', FieldKind.modules),
    FieldSpec(
      'price_monthly_paise',
      'Price per month (₹)',
      FieldKind.rupees,
      initial: 0,
    ),
    FieldSpec(
      'price_yearly_paise',
      'Price per year (₹)',
      FieldKind.rupees,
      initial: 0,
    ),
    FieldSpec('max_quantity', 'Max quantity', FieldKind.integer),
    FieldSpec('is_active', 'Active', FieldKind.boolean, initial: true),
    FieldSpec('sort_order', 'Order', FieldKind.integer, initial: 0),
  ],
  columns: [
    ColumnSpec('Code', (r) => _text(r['code'])),
    ColumnSpec('Name', (r) => _text(r['name'])),
    ColumnSpec('Monthly', (r) => _rupees(r['price_monthly_paise'])),
    ColumnSpec('Grants', (r) => _text(r['grants_limits'])),
    ColumnSpec('Active', (r) => _yes(r['is_active'])),
  ],
);

/// List + add + edit for a [ResourceConfig].
class ResourceScreen extends ConsumerStatefulWidget {
  const ResourceScreen({
    required this.config,
    this.actions = const [],
    super.key,
  });

  final ResourceConfig config;

  /// Extra buttons next to "New".
  final List<Widget> actions;

  @override
  ConsumerState<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends ConsumerState<ResourceScreen> {
  late Future<List<Map<String, Object?>>> _future = _load();

  Future<List<Map<String, Object?>>> _load() async {
    final data = await ref
        .read(adminApiProvider)
        .call(widget.config.listAction);
    final pick = widget.config.rowsOf;
    return pick == null ? rows(data) : pick(data);
  }

  void _reload() => setState(() {
    _future = _load();
  });

  Future<void> _edit(Map<String, Object?>? row) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditDialog(config: widget.config, row: row),
    );
    if (saved ?? false) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    return ListView(
      padding: const EdgeInsets.all(MkSpacing.lg),
      children: [
        if (c.note != null)
          Padding(
            padding: const EdgeInsets.only(bottom: MkSpacing.md),
            child: Text(c.note!),
          ),
        Wrap(
          spacing: MkSpacing.sm,
          children: [
            MkButton(
              key: ValueKey('new-${c.upsertAction}'),
              label: 'New',
              icon: Icons.add,
              onPressed: () => _edit(null),
            ),
            ...widget.actions,
          ],
        ),
        const SizedBox(height: MkSpacing.md),
        FutureBuilder(
          future: _future,
          builder: (context, snap) {
            if (snap.hasError) return Text('${snap.error}');
            final data = snap.data;
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return MkCard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: [
                    for (final col in c.columns)
                      DataColumn(label: Text(col.label)),
                  ],
                  rows: [
                    for (final r in data)
                      DataRow(
                        onSelectChanged: (_) => _edit(r),
                        cells: [
                          for (final col in c.columns)
                            DataCell(Text(col.value(r))),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EditDialog extends ConsumerStatefulWidget {
  const _EditDialog({required this.config, required this.row});

  final ResourceConfig config;
  final Map<String, Object?>? row;

  @override
  ConsumerState<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends ConsumerState<_EditDialog> {
  late final FormValues _values = FormValues(widget.config.fields, widget.row);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _values.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final read = _values.read();
    if (read.error != null) {
      setState(() => _error = read.error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminApiProvider).call(widget.config.upsertAction, {
        for (final k in widget.config.carryKeys)
          if (widget.row?[k] != null) k: widget.row![k],
        ...read.values!,
      });
      if (mounted) Navigator.of(context).pop(true);
    } on AdminApiException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.row == null ? 'New' : 'Edit'),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(child: FormFields(values: _values)),
    ),
    actions: [
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(right: MkSpacing.md),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      TextButton(
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const ValueKey('save-resource'),
        onPressed: _busy ? null : _save,
        child: const Text('Save'),
      ),
    ],
  );
}

/// The crop master with its "push to all businesses" action.
class CropMasterScreen extends ConsumerWidget {
  const CropMasterScreen({required this.config, super.key});

  final ResourceConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ResourceScreen(
    config: config,
    actions: [
      MkButton(
        key: const ValueKey('push-crops'),
        label: 'Push to all businesses',
        icon: Icons.cloud_upload_outlined,
        variant: MkButtonVariant.secondary,
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final res = asMap(
            await ref.read(adminApiProvider).call('crops_push'),
          );
          messenger.showSnackBar(
            SnackBar(
              content: Text('Added ${res['added']} crops to businesses.'),
            ),
          );
        },
      ),
    ],
  );
}
