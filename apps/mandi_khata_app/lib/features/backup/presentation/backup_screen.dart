import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/backup/data/backup_codec.dart';
import 'package:mandi_khata_app/features/backup/data/backup_service.dart';
import 'package:mandi_khata_app/features/backup/presentation/backup_providers.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/khata/presentation/statement_labels.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Backup, restore and "download all my data" (step 6.4). Owner only.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  static const route = '/backup';

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _pass = TextEditingController();
  final _restorePass = TextEditingController();
  bool _busy = false;
  late bool _enabled = ref.read(appPrefsProvider).backupEnabled;

  @override
  void initState() {
    super.initState();
    _pass.text = ref.read(appPrefsProvider).backupPassphrase ?? '';
  }

  @override
  void dispose() {
    _pass.dispose();
    _restorePass.dispose();
    super.dispose();
  }

  void _toast(String text, {bool error = false}) => MkToast.show(
    context,
    text,
    tone: error ? MkToastTone.error : MkToastTone.success,
  );

  Future<void> _guard(Future<void> Function() body) async {
    setState(() => _busy = true);
    try {
      await body();
    } on Object catch (e) {
      if (mounted) _toast('$e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportAll() => _guard(() async {
    final l10n = AppLocalizations.of(context);
    final tenantId = ref.read(activeTenantProvider)!;
    final name = ref.read(activeMembershipProvider)?.tenantName ?? '';
    final service = await ref.read(backupServiceProvider.future);
    final rows = await ref.read(
      statementsReportProvider(const ReportFilter()).future,
    );
    if (!mounted) return;
    final fonts = await StatementFonts.load();
    if (!mounted) return;
    Uint8List? pdf;
    if (rows.isNotEmpty) {
      pdf = await StatementPdf.buildMany(
        title: '$name – ${l10n.statementTitle}',
        labels: statementLabels(
          l10n,
          period: l10n.rangeAll,
          formatDate: (d) => AppFormat.ledgerDate(context, d),
        ),
        fonts: fonts,
        statements: [
          for (final r in rows)
            (
              statement: r.statement,
              header: StatementHeader(
                businessName: name,
                partyName: r.name,
                partyCode: r.code,
                partyPlace: r.village,
                mobile: r.mobile,
              ),
            ),
        ],
      );
    }
    final zip = await service.exportZip(
      tenantId,
      tenantName: name,
      statementsPdf: pdf,
    );
    final saved = await FileSaver.instance.saveAs(
      name: 'mandi-khata-data-${LedgerDate.fromDateTime(DateTime.now())}',
      bytes: zip,
      fileExtension: 'zip',
      mimeType: MimeType.zip,
    );
    if (saved != null && mounted) _toast(l10n.reportExportSaved(saved));
  });

  Future<void> _pickFolder() async {
    final dir = await FilePicker.getDirectoryPath();
    if (dir == null) return;
    await ref.read(appPrefsProvider).setBackup(enabled: _enabled, folder: dir);
    if (mounted) setState(() {});
  }

  Future<void> _saveSettings({required bool enabled}) async {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.read(appPrefsProvider);
    if (enabled && (prefs.backupFolder == null || _pass.text.length < 6)) {
      _toast(l10n.backupNeedsSetup, error: true);
      return;
    }
    await prefs.setBackup(
      enabled: enabled,
      passphrase: _pass.text.length >= 6 ? _pass.text : null,
    );
    setState(() => _enabled = enabled);
  }

  Future<void> _backupNow() => _guard(() async {
    final l10n = AppLocalizations.of(context);
    await _saveSettings(enabled: _enabled);
    final path = await ref.read(backupRunNowProvider.future);
    if (!mounted) return;
    _toast(
      path == null ? l10n.backupNeedsSetup : l10n.backupDone(path),
      error: path == null,
    );
  });

  Future<void> _restore() => _guard(() async {
    final l10n = AppLocalizations.of(context);
    final ctx = ref.read(writeContextProvider);
    if (ctx == null) return;
    final file = await FilePicker.pickFile();
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final Map<String, Object?> snapshot;
    try {
      snapshot = await BackupCodec.decrypt(bytes, _restorePass.text);
    } on BackupWrongPassphrase {
      if (mounted) _toast(l10n.restoreWrongPassphrase, error: true);
      return;
    } on BackupCorrupt {
      if (mounted) _toast(l10n.restoreCorrupt, error: true);
      return;
    }
    if (!mounted) return;
    final counts = BackupService.rowCounts(snapshot);
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(
          l10n.restoreConfirmBody(
            '${snapshot['tenant_name']}',
            total,
            '${snapshot['created_at']}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('restore-confirm'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(l10n.restoreAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final service = await ref.read(backupServiceProvider.future);
    try {
      final n = await service.restore(ctx, snapshot);
      if (mounted) _toast(l10n.restoreDone(n));
    } on RestoreRefused catch (e) {
      if (mounted) {
        _toast(switch (e.reason) {
          RestoreRefusal.otherBusiness => l10n.restoreOtherBusiness,
          RestoreRefusal.notEmpty => l10n.restoreNotEmpty,
          RestoreRefusal.newerFormat => l10n.restoreNewerFormat,
        }, error: true);
      }
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOwner =
        ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
    final prefs = ref.watch(appPrefsProvider);
    final last = ref.watch(lastBackupProvider);
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.backupTitle,
            actions: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
          Expanded(
            child: !isOwner
                ? Center(child: Text(l10n.backupOwnerOnly))
                : ListView(
                    padding: const EdgeInsets.all(MkSpacing.lg),
                    children: [
                      MkCard(
                        title: l10n.exportAllTitle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.exportAllBody),
                            const SizedBox(height: MkSpacing.md),
                            MkButton(
                              key: const ValueKey('export-all'),
                              label: l10n.exportAllButton,
                              icon: Icons.download_outlined,
                              busy: _busy,
                              onPressed: _busy ? null : _exportAll,
                            ),
                          ],
                        ),
                      ),
                      if (localBackupSupported)
                        Padding(
                          padding: const EdgeInsets.only(top: MkSpacing.lg),
                          child: MkCard(
                            title: l10n.backupLocalTitle,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.backupLocalBody),
                                SwitchListTile(
                                  key: const ValueKey('backup-enabled'),
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l10n.backupDaily),
                                  value: _enabled,
                                  onChanged: _busy
                                      ? null
                                      : (v) => _saveSettings(enabled: v),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.folder_outlined),
                                  title: Text(
                                    prefs.backupFolder ?? l10n.backupNoFolder,
                                  ),
                                  trailing: TextButton(
                                    onPressed: _pickFolder,
                                    child: Text(l10n.backupChooseFolder),
                                  ),
                                ),
                                TextField(
                                  key: const ValueKey('backup-pass'),
                                  controller: _pass,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.backupPassphrase,
                                    helperText: l10n.backupPassphraseHelp,
                                    helperMaxLines: 3,
                                  ),
                                ),
                                const SizedBox(height: MkSpacing.md),
                                Row(
                                  children: [
                                    MkButton(
                                      key: const ValueKey('backup-now'),
                                      label: l10n.backupNow,
                                      icon: Icons.backup_outlined,
                                      busy: _busy,
                                      onPressed: _busy ? null : _backupNow,
                                    ),
                                    const SizedBox(width: MkSpacing.md),
                                    Text(
                                      last == null
                                          ? l10n.backupNever
                                          : l10n.backupLast(
                                              AppFormat.dateTime(context, last),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: MkSpacing.lg),
                        child: MkCard(
                          title: l10n.restoreTitle,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.restoreBody),
                              TextField(
                                key: const ValueKey('restore-pass'),
                                controller: _restorePass,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: l10n.backupPassphrase,
                                ),
                              ),
                              const SizedBox(height: MkSpacing.md),
                              MkButton(
                                key: const ValueKey('restore-pick'),
                                label: l10n.restorePick,
                                icon: Icons.restore,
                                variant: MkButtonVariant.secondary,
                                onPressed: _busy ? null : _restore,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
