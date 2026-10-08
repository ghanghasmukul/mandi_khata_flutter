import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_providers.dart';
import 'package:mandi_khata_app/features/products/data/stock_repository.dart';
import 'package:mandi_khata_app/features/products/domain/opening_stock_import.dart';
import 'package:mandi_khata_app/features/products/presentation/products_labels.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/features/products/presentation/products_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Opening stock from XLSX / CSV / pasted text: preview with per-row
/// problems, then one all-or-nothing import. Importing the same file twice
/// changes nothing (deterministic ids).
class StockImportScreen extends ConsumerStatefulWidget {
  const StockImportScreen({super.key});

  @override
  ConsumerState<StockImportScreen> createState() => _StockImportState();
}

class _StockImportState extends ConsumerState<StockImportScreen> {
  final _paste = TextEditingController();
  OpeningStockPreview? _preview;
  String? _readError;
  StockResult? _result;
  LedgerDate _asOn = LedgerDate.fromDateTime(DateTime.now());
  bool _busy = false;

  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  Future<void> _load(Sheet sheet) async {
    final refs = await ref.read(productsWriterProvider).productRefs();
    if (!mounted) return;
    setState(() {
      _preview = OpeningStockImport.preview(sheet, products: refs);
      _readError = null;
      _result = null;
    });
  }

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    final file = await ref.read(importFilePickerProvider)();
    if (file == null || !mounted) return;
    try {
      await _load(readPickedFile(file));
    } on ImportReadException catch (e) {
      setState(() {
        _preview = null;
        _readError = e.reason == ImportReadFailure.oldExcel
            ? l10n.prodImpOldExcel
            : e.reason == ImportReadFailure.empty
            ? l10n.prodImpSheetEmpty
            : l10n.prodImpUnreadable;
      });
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    final result = await ref
        .read(productsWriterProvider)
        .importOpening(_preview!, _asOn);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = result;
    });
  }

  Future<void> _date() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_asOn.year, _asOn.month, _asOn.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) setState(() => _asOn = LedgerDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allowed =
        ref.watch(canProvider(Permission.stockAdjust)) &&
        ref.watch(canProvider(Permission.productsManage));
    final preview = _preview;
    final result = _result;
    final message = result == null
        ? null
        : result is OpeningStockImported
        ? l10n.prodImpDone(result.rows, result.skipped)
        : l10n.stockFailure(result);
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.prodImpTitle,
            actions: [
              IconButton(
                onPressed: () => context.go(ProductRoutes.list),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Expanded(
            child: !allowed
                ? MkEmptyState(
                    icon: Icons.lock_outline,
                    title: l10n.prodNoAccess,
                  )
                : ListView(
                    padding: const EdgeInsets.all(MkSpacing.lg),
                    children: [
                      MkCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.prodImpHelp),
                            const SizedBox(height: MkSpacing.md),
                            Wrap(
                              spacing: MkSpacing.sm,
                              children: [
                                MkButton(
                                  key: const ValueKey('si-pick'),
                                  label: l10n.prodImpChoose,
                                  icon: Icons.upload_file_outlined,
                                  onPressed: _pick,
                                ),
                                MkButton(
                                  key: const ValueKey('si-date'),
                                  label:
                                      '${l10n.prodImpDate}: '
                                      '${AppFormat.ledgerDate(context, _asOn)}',
                                  variant: MkButtonVariant.secondary,
                                  onPressed: _date,
                                ),
                              ],
                            ),
                            const SizedBox(height: MkSpacing.md),
                            MkTextField(
                              key: const ValueKey('si-paste'),
                              controller: _paste,
                              label: l10n.prodImpPasteLabel,
                              hint: l10n.prodImpPasteHint,
                              maxLines: 5,
                            ),
                            const SizedBox(height: MkSpacing.sm),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: MkButton(
                                key: const ValueKey('si-read'),
                                label: l10n.prodImpRead,
                                variant: MkButtonVariant.secondary,
                                onPressed: () =>
                                    _load(DelimitedText.parse(_paste.text)),
                              ),
                            ),
                            if (_readError != null)
                              Text(
                                _readError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (preview != null) ...[
                        const SizedBox(height: MkSpacing.lg),
                        _Preview(preview: preview),
                        const SizedBox(height: MkSpacing.md),
                        MkButton(
                          key: const ValueKey('si-import'),
                          label: l10n.prodImpButton,
                          busy: _busy,
                          onPressed:
                              preview.canImport &&
                                  _result is! OpeningStockImported
                              ? _import
                              : null,
                        ),
                      ],
                      if (message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: MkSpacing.md),
                          child: Text(
                            message,
                            key: const ValueKey('si-result'),
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

class _Preview extends StatelessWidget {
  const _Preview({required this.preview});

  final OpeningStockPreview preview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (preview.problem != null) {
      return Text(
        l10n.sheetProblem(preview.problem!),
        key: const ValueKey('si-problem'),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    final bad = preview.invalid;
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.prodImpSummary(
              preview.valid.length,
              preview.totalValue.format(),
            ),
            key: const ValueKey('si-summary'),
          ),
          if (bad.isNotEmpty) ...[
            const SizedBox(height: MkSpacing.sm),
            Text(
              l10n.prodImpErrorsFound(bad.length),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            for (final r in bad)
              Text(
                '${l10n.prodImpRowNumber(r.number)}: ${r.reference} — '
                '${r.problems.map(l10n.rowProblem).join(', ')}',
              ),
          ],
        ],
      ),
    );
  }
}
