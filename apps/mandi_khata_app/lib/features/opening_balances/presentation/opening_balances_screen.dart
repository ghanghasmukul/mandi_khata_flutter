import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/opening_balances/data/opening_balances_repository.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_providers.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_widgets.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class OpeningBalanceRoutes {
  static const import = '/parties/import';
}

/// Opening balances import: paste or upload a CSV / Excel file of parties
/// with their opening baki, preview and validate every row, then post it all
/// as `opening_balance` entries in one all-or-nothing step. Works offline.
class OpeningBalancesScreen extends ConsumerStatefulWidget {
  const OpeningBalancesScreen({super.key});

  @override
  ConsumerState<OpeningBalancesScreen> createState() => _State();
}

class _State extends ConsumerState<OpeningBalancesScreen> {
  final _paste = TextEditingController();
  Sheet? _sheet;
  String? _fileName;
  String? _readError;
  List<ExistingParty> _existing = const [];
  OpeningPreview? _preview;
  Side? _defaultSide;
  PartyRole _role = PartyRole.farmer;
  LedgerDate _asOn = LedgerDate.fromDateTime(DateTime.now());
  bool _problemsOnly = false;
  bool _alreadyDone = false;
  bool _busy = false;
  OpeningImportResult? _result;

  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  Future<void> _load(Sheet sheet, String? name) async {
    final importer = ref.read(openingBalanceImporterProvider);
    final existing = await importer.existingParties();
    if (!mounted) return;
    _existing = existing;
    _sheet = sheet;
    _fileName = name;
    _result = null;
    await _recompute();
  }

  Future<void> _recompute() async {
    final sheet = _sheet;
    if (sheet == null) return;
    final preview = OpeningBalanceImport.preview(
      sheet,
      existing: _existing,
      defaultSide: _defaultSide,
      defaultRole: _role,
    );
    final done = await ref
        .read(openingBalanceImporterProvider)
        .alreadyImported(preview, _asOn);
    if (!mounted) return;
    setState(() {
      _preview = preview;
      _alreadyDone = done;
      _readError = null;
    });
  }

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context);
    final file = await ref.read(importFilePickerProvider)();
    if (file == null || !mounted) return;
    try {
      await _load(readPickedFile(file), file.name);
    } on ImportReadException catch (e) {
      setState(() {
        _sheet = null;
        _preview = null;
        _readError = switch (e.reason) {
          ImportReadFailure.oldExcel => l10n.obReadOldExcel,
          ImportReadFailure.unreadable => l10n.obReadUnreadable,
          ImportReadFailure.empty => l10n.obProblemEmpty,
        };
      });
    }
  }

  Future<void> _readPaste() => _load(DelimitedText.parse(_paste.text), null);

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_asOn.year, _asOn.month, _asOn.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked == null) return;
    _asOn = LedgerDate.fromDateTime(picked);
    await _recompute();
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final p = _preview!;
    final ok = await MkDialog.show<bool>(
      context,
      title: l10n.obConfirmTitle,
      content: Text(
        l10n.obConfirmBody(
          p.entries,
          p.newParties,
          p.totalUdhaar.format(),
          p.totalJama.format(),
          AppFormat.ledgerDate(context, _asOn),
        ),
      ),
      actions: [
        Builder(
          builder: (c) => MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.secondary,
            onPressed: () => Navigator.of(c).pop(false),
          ),
        ),
        Builder(
          builder: (c) => MkButton(
            key: const ValueKey('ob-confirm'),
            label: l10n.obImportNow,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ),
      ],
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final result = await ref
        .read(openingBalanceImporterProvider)
        .run(p, asOn: _asOn, fileName: _fileName);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = result;
    });
    // After a failure the books may have changed: read them again.
    if (result is! OpeningImported) {
      _existing = await ref
          .read(openingBalanceImporterProvider)
          .existingParties();
      await _recompute();
    }
  }

  String _failure(AppLocalizations l10n, OpeningImportResult r) => switch (r) {
    OpeningAlreadyImported() => l10n.obResAlready,
    OpeningNothingToImport() => l10n.obResNothing,
    OpeningNotPermitted() => l10n.obResNotPermitted,
    OpeningBadDate() => l10n.obResBadDate,
    OpeningStale(:final rowNumber) => l10n.obResStale(rowNumber),
    OpeningImported() => '',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allowed =
        ref.watch(canProvider(Permission.entriesReverse)) &&
        ref.watch(canProvider(Permission.partiesManage));
    final preview = _preview;
    final result = _result;

    final top = <Widget>[];
    if (!allowed) {
      top.add(MkEmptyState(icon: Icons.lock_outline, title: l10n.obNoAccess));
    } else if (result is OpeningImported) {
      top.add(_Done(result: result));
    } else {
      top.addAll([
        MkCard(
          title: l10n.obSourceTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.obFormatHelp),
              const SizedBox(height: MkSpacing.md),
              Wrap(
                spacing: MkSpacing.sm,
                runSpacing: MkSpacing.sm,
                children: [
                  MkButton(
                    key: const ValueKey('ob-pick-file'),
                    label: l10n.obChooseFile,
                    icon: Icons.upload_file_outlined,
                    onPressed: _pickFile,
                  ),
                  if (_fileName != null) Chip(label: Text(_fileName!)),
                ],
              ),
              const SizedBox(height: MkSpacing.md),
              MkTextField(
                key: const ValueKey('ob-paste'),
                controller: _paste,
                label: l10n.obPasteLabel,
                hint: l10n.obPasteHint,
                maxLines: 5,
              ),
              const SizedBox(height: MkSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: MkButton(
                  key: const ValueKey('ob-read-paste'),
                  label: l10n.obReadPasted,
                  variant: MkButtonVariant.secondary,
                  onPressed: _readPaste,
                ),
              ),
              if (_readError != null)
                Padding(
                  padding: const EdgeInsets.only(top: MkSpacing.sm),
                  child: Text(
                    _readError!,
                    key: const ValueKey('ob-read-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (preview != null) ...[
          const SizedBox(height: MkSpacing.lg),
          _options(l10n),
          const SizedBox(height: MkSpacing.lg),
          if (preview.problem != null)
            MkCard(
              child: Text(
                l10n.openingProblem(preview.problem!),
                key: const ValueKey('ob-problem'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            )
          else ...[
            OpeningSummary(preview: preview),
            const SizedBox(height: MkSpacing.md),
            _actions(l10n, preview, result),
          ],
        ],
      ]);
    }

    final rows =
        preview == null || preview.problem != null || result is OpeningImported
        ? const <OpeningRow>[]
        : (_problemsOnly
              ? [
                  for (final r in preview.rows)
                    if (r.hasError || r.warnings.isNotEmpty) r,
                ]
              : preview.rows);

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.obTitle,
            languages: appLanguages,
            language: Localizations.localeOf(context).languageCode,
            onLanguage: (c) => ref.read(appLanguageProvider.notifier).set(c),
            actions: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go(PartyRoutes.list),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(MkSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(top),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MkSpacing.lg,
                      ),
                      sliver: SliverList.builder(
                        itemCount: rows.length,
                        itemBuilder: (_, i) => OpeningRowTile(
                          row: rows[i],
                          key: ValueKey('row-${rows[i].number}'),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _options(AppLocalizations l10n) => MkCard(
    title: l10n.obOptionsTitle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: MkSpacing.md,
          children: [
            Text(l10n.obAsOn),
            MkButton(
              key: const ValueKey('ob-date'),
              label: AppFormat.ledgerDate(context, _asOn),
              icon: Icons.calendar_today_outlined,
              variant: MkButtonVariant.secondary,
              onPressed: _pickDate,
            ),
          ],
        ),
        const SizedBox(height: MkSpacing.md),
        Text(l10n.obDefaultSide),
        const SizedBox(height: MkSpacing.xs),
        Wrap(
          spacing: MkSpacing.sm,
          children: [
            ChoiceChip(
              key: const ValueKey('ob-side-none'),
              label: Text(l10n.obSideNone),
              selected: _defaultSide == null,
              onSelected: (_) {
                _defaultSide = null;
                unawaited(_recompute());
              },
            ),
            ChoiceChip(
              key: const ValueKey('ob-side-udhaar'),
              label: Text(l10n.obSideUdhaar),
              selected: _defaultSide == Side.udhaar,
              onSelected: (_) {
                _defaultSide = Side.udhaar;
                unawaited(_recompute());
              },
            ),
            ChoiceChip(
              key: const ValueKey('ob-side-jama'),
              label: Text(l10n.obSideJama),
              selected: _defaultSide == Side.jama,
              onSelected: (_) {
                _defaultSide = Side.jama;
                unawaited(_recompute());
              },
            ),
          ],
        ),
        const SizedBox(height: MkSpacing.md),
        Text(l10n.obDefaultRole),
        const SizedBox(height: MkSpacing.xs),
        Wrap(
          spacing: MkSpacing.sm,
          children: [
            for (final r in PartyRole.values)
              ChoiceChip(
                key: ValueKey('ob-role-${r.name}'),
                label: Text(l10n.partyRole(r)),
                selected: _role == r,
                onSelected: (_) {
                  _role = r;
                  unawaited(_recompute());
                },
              ),
          ],
        ),
      ],
    ),
  );

  Widget _actions(
    AppLocalizations l10n,
    OpeningPreview preview,
    OpeningImportResult? result,
  ) {
    final skipped = preview.invalid.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_alreadyDone)
          Padding(
            padding: const EdgeInsets.only(bottom: MkSpacing.sm),
            child: Text(
              l10n.obResAlready,
              key: const ValueKey('ob-already'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (result != null && result is! OpeningImported)
          Padding(
            padding: const EdgeInsets.only(bottom: MkSpacing.sm),
            child: Text(
              _failure(l10n, result),
              key: const ValueKey('ob-failure'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (preview.rows.any((r) => r.hasError || r.warnings.isNotEmpty))
              FilterChip(
                key: const ValueKey('ob-problems-only'),
                label: Text(l10n.obProblemsOnly),
                selected: _problemsOnly,
                onSelected: (v) => setState(() => _problemsOnly = v),
              ),
            MkButton(
              key: const ValueKey('ob-import'),
              label: skipped == 0
                  ? l10n.obImportButton(preview.entries)
                  : l10n.obImportValidButton(preview.entries, skipped),
              icon: Icons.download_done_outlined,
              busy: _busy,
              onPressed: preview.canImport && !_alreadyDone && !_busy
                  ? _import
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.result});

  final OpeningImported result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkEmptyState(
            icon: Icons.check_circle_outline,
            title: l10n.obDoneTitle,
            message: l10n.obDoneBody(
              result.entries,
              result.newParties,
              result.totalUdhaar.format(),
              result.totalJama.format(),
            ),
          ),
          const SizedBox(height: MkSpacing.md),
          MkButton(
            key: const ValueKey('ob-done-parties'),
            label: l10n.obDoneParties,
            onPressed: () => context.go(PartyRoutes.list),
          ),
          const SizedBox(height: MkSpacing.sm),
          MkButton(
            label: l10n.onboardingDoneHome,
            variant: MkButtonVariant.ghost,
            onPressed: () => context.go(GateRoutes.home),
          ),
        ],
      ),
    );
  }
}
