import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/imports/data/import_batches_repository.dart';
import 'package:mandi_khata_app/features/imports/presentation/imports_hub_screen.dart';
import 'package:mandi_khata_app/features/imports/presentation/imports_providers.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_providers.dart';
import 'package:mandi_khata_app/features/products/domain/product_import.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

extension ProductImportLabels on AppLocalizations {
  String productRowProblem(ProductRowProblem p) => switch (p) {
    ProductRowProblem.nameMissing => piNameMissing,
    ProductRowProblem.skuMissing => piSkuMissing,
    ProductRowProblem.unitUnknown => piUnitUnknown,
    ProductRowProblem.gstInvalid => piGstInvalid,
    ProductRowProblem.hsnInvalid => piHsnInvalid,
    ProductRowProblem.priceInvalid => piPriceInvalid,
    ProductRowProblem.duplicateInFile => piDuplicateInFile,
    ProductRowProblem.skuExists => piSkuExists,
    ProductRowProblem.barcodeExists => piBarcodeExists,
  };

  String productSheetProblem(ProductSheetProblem p) => switch (p) {
    ProductSheetProblem.empty => obProblemEmpty,
    ProductSheetProblem.noNameColumn => piNoNameColumn,
    ProductSheetProblem.tooManyRows => piTooManyRows,
  };
}

/// Product master import from CSV / Excel (own template, Busy, Marg, any
/// file with a header row): preview, validate, import in one step.
class ProductImportScreen extends ConsumerStatefulWidget {
  const ProductImportScreen({super.key});

  @override
  ConsumerState<ProductImportScreen> createState() => _State();
}

class _State extends ConsumerState<ProductImportScreen> {
  Sheet? _sheet;
  String? _fileName;
  String? _error;
  ProductImportPreview? _preview;
  bool _busy = false;
  ProductImportResult? _result;

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    final file = await ref.read(importFilePickerProvider)();
    if (file == null || !mounted) return;
    try {
      _sheet = readPickedFile(file);
      _fileName = file.name;
      _result = null;
      await _recompute();
    } on ImportReadException {
      setState(() {
        _sheet = null;
        _preview = null;
        _error = l10n.obReadUnreadable;
      });
    }
  }

  Future<void> _recompute() async {
    final sheet = _sheet;
    if (sheet == null) return;
    final ctx = await ref.read(productImportContextProvider.future);
    if (!mounted) return;
    setState(() {
      _error = null;
      _preview = ProductImport.preview(
        sheet,
        existing: ctx.products,
        categoriesByName: ctx.categories,
      );
    });
  }

  Future<void> _import() async {
    final p = _preview!;
    setState(() => _busy = true);
    final r = await ref
        .read(importActionsProvider)
        .importProducts(p, fileName: _fileName);
    ref.invalidate(productImportContextProvider);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = r;
    });
    if (r is! ProductsImported) await _recompute();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allowed = ref.watch(canProvider(Permission.productsManage));
    final p = _preview;
    final r = _result;
    final theme = Theme.of(context);

    final body = <Widget>[];
    if (!allowed) {
      body.add(MkEmptyState(icon: Icons.lock_outline, title: l10n.obNoAccess));
    } else if (r is ProductsImported) {
      body.add(
        MkCard(
          child: Text(
            l10n.piDone(r.count),
            key: const ValueKey('pi-done'),
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    } else {
      body.addAll([
        MkCard(
          title: l10n.piTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.piHelp),
              const SizedBox(height: MkSpacing.md),
              Wrap(
                spacing: MkSpacing.sm,
                children: [
                  MkButton(
                    key: const ValueKey('pi-pick'),
                    label: l10n.obChooseFile,
                    icon: Icons.upload_file_outlined,
                    onPressed: _pick,
                  ),
                  if (_fileName != null) Chip(label: Text(_fileName!)),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: MkSpacing.sm),
                  child: Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
        if (p != null) ...[
          const SizedBox(height: MkSpacing.lg),
          if (p.problem != null)
            MkCard(
              child: Text(
                l10n.productSheetProblem(p.problem!),
                key: const ValueKey('pi-problem'),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            )
          else ...[
            MkCard(
              child: Text(
                l10n.piSummary(p.valid.length, p.invalid.length),
                key: const ValueKey('pi-summary'),
              ),
            ),
            if (r != null && r is! ProductsImported)
              Padding(
                padding: const EdgeInsets.only(top: MkSpacing.sm),
                child: Text(
                  switch (r) {
                    ProductsAlreadyImported() => l10n.obResAlready,
                    ProductsNothingToImport() => l10n.obResNothing,
                    ProductsNotPermitted() => l10n.obResNotPermitted,
                    ProductsStale(:final rowNumber) => l10n.obResStale(
                      rowNumber,
                    ),
                    ProductsImported() => '',
                  },
                  key: const ValueKey('pi-failure'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: MkSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: MkButton(
                key: const ValueKey('pi-import'),
                label: l10n.piImportNow(p.valid.length),
                icon: Icons.download_done_outlined,
                busy: _busy,
                onPressed: p.canImport && !_busy ? _import : null,
              ),
            ),
            const SizedBox(height: MkSpacing.md),
            for (final row in p.rows.where(
              (x) => !x.isValid || x.warnings.isNotEmpty,
            ))
              MkCard(
                key: ValueKey('pi-row-${row.number}'),
                child: Text(
                  l10n.piRow(
                    row.number,
                    row.input.name.isEmpty ? '—' : row.input.name,
                    [
                      for (final x in row.problems) l10n.productRowProblem(x),
                      for (final _ in row.warnings) l10n.piCategoryUnknown,
                    ].join(', '),
                  ),
                ),
              ),
          ],
        ],
      ]);
    }

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.piTitle,
            actions: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go(ImportRoutes.hub),
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(MkSpacing.lg),
              children: body,
            ),
          ),
        ],
      ),
    );
  }
}
