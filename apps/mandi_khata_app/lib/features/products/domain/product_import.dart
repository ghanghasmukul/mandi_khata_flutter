import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';

/// What is wrong with one row of a product file.
enum ProductRowProblem {
  nameMissing,

  /// No SKU / item code and no barcode to use instead.
  skuMissing,
  unitUnknown,
  gstInvalid,
  hsnInvalid,
  priceInvalid,
  duplicateInFile,
  skuExists,
  barcodeExists,
}

/// What is wrong with the whole file.
enum ProductSheetProblem { empty, noNameColumn, tooManyRows }

/// Something worth a look that does not block a row.
enum ProductRowWarning {
  /// The category named in the file does not exist; the product is added
  /// without one.
  categoryUnknown,
}

/// A product already in the business, for duplicate checks.
@immutable
class ExistingProduct {
  const ExistingProduct({required this.sku, this.barcode});

  final String sku;
  final String? barcode;
}

@immutable
class ProductImportRow {
  const ProductImportRow({
    required this.number,
    required this.input,
    required this.problems,
    this.warnings = const [],
  });

  final int number;
  final ProductInput input;
  final List<ProductRowProblem> problems;
  final List<ProductRowWarning> warnings;

  bool get isValid => problems.isEmpty;
}

@immutable
class ProductImportPreview {
  const ProductImportPreview({required this.rows, this.problem});

  final List<ProductImportRow> rows;
  final ProductSheetProblem? problem;

  List<ProductImportRow> get valid => [
    for (final r in rows)
      if (r.isValid) r,
  ];
  List<ProductImportRow> get invalid => [
    for (final r in rows)
      if (!r.isValid) r,
  ];
  bool get canImport => problem == null && valid.isNotEmpty;

  /// The same rows give the same text: recognises a file imported twice.
  String get fingerprint => [
    for (final r in valid) '${r.input.sku.toLowerCase()}|${r.input.name}',
  ].join('\n');
}

/// Reads a product master file (our template, or an export from Busy, Marg
/// or any CSV / Excel with a header row). Pure: no database, no clock.
/// Rules: docs/domain/import-export.md.
abstract final class ProductImport {
  static const maxRows = 5000;

  static const _sku = {
    'sku',
    'code',
    'item code',
    'product code',
    'itemcode',
    'alias',
    'item alias',
    'part no',
  };
  static const _barcode = {'barcode', 'bar code', 'ean', 'upc'};
  static const _name = {
    'product',
    'name',
    'product name',
    'item',
    'item name',
    'description',
    'particulars',
  };
  static const _brand = {'brand', 'company', 'manufacturer', 'make'};
  static const _category = {
    'category',
    'group',
    'item group',
    'product group',
    'type',
  };
  static const _unit = {'unit', 'uom', 'units', 'primary unit', 'base unit'};
  static const _pack = {'pack', 'pack size', 'packing', 'size'};
  static const _hsn = {'hsn', 'hsn code', 'hsn/sac', 'hsn sac', 'sac'};
  static const _gst = {
    'gst',
    'gst %',
    'gst rate',
    'tax',
    'tax %',
    'tax rate',
    'igst',
    'igst %',
    'gst percent',
  };
  static const _retail = {
    'price',
    'mrp',
    'retail',
    'retail price',
    'sale price',
    'selling price',
    'sale rate',
    's rate',
    's.rate',
    'rate',
  };
  static const _wholesale = {
    'wholesale',
    'wholesale price',
    'wholesale rate',
    'ws rate',
    'w rate',
  };
  static const _reorder = {'reorder', 'reorder level', 'min stock', 'minimum'};

  static String _norm(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'[_\-]+'), ' ');

  static int? _col(List<String> header, Set<String> names) {
    for (var i = 0; i < header.length; i++) {
      if (names.contains(_norm(header[i]))) return i;
    }
    return null;
  }

  /// First row is the header.
  static ProductImportPreview preview(
    Sheet sheet, {
    required List<ExistingProduct> existing,
    required Map<String, String> categoriesByName,
  }) {
    if (sheet.isEmpty) {
      return const ProductImportPreview(
        rows: [],
        problem: ProductSheetProblem.empty,
      );
    }
    final header = sheet.rows.first.cells;
    final cName = _col(header, _name);
    if (cName == null) {
      return const ProductImportPreview(
        rows: [],
        problem: ProductSheetProblem.noNameColumn,
      );
    }
    final data = sheet.rows.skip(1).toList();
    if (data.length > maxRows) {
      return const ProductImportPreview(
        rows: [],
        problem: ProductSheetProblem.tooManyRows,
      );
    }
    final cSku = _col(header, _sku);
    final cBarcode = _col(header, _barcode);
    final cBrand = _col(header, _brand);
    final cCategory = _col(header, _category);
    final cUnit = _col(header, _unit);
    final cPack = _col(header, _pack);
    final cHsn = _col(header, _hsn);
    final cGst = _col(header, _gst);
    final cRetail = _col(header, _retail);
    final cWholesale = _col(header, _wholesale);
    final cReorder = _col(header, _reorder);

    final skus = {for (final e in existing) e.sku.toLowerCase()};
    final barcodes = {
      for (final e in existing)
        if (e.barcode != null) e.barcode!.toLowerCase(),
    };
    final seenSkus = <String>{};
    final seenBarcodes = <String>{};
    final categories = {
      for (final e in categoriesByName.entries)
        e.key.trim().toLowerCase(): e.value,
    };

    final rows = <ProductImportRow>[];
    for (final raw in data) {
      final problems = <ProductRowProblem>[];
      final warnings = <ProductRowWarning>[];
      final name = raw.cell(cName);
      final barcode = raw.cell(cBarcode);
      var sku = raw.cell(cSku);
      if (sku.isEmpty) sku = barcode;
      if (name.isEmpty) problems.add(ProductRowProblem.nameMissing);
      if (sku.isEmpty) problems.add(ProductRowProblem.skuMissing);

      final unitText = raw.cell(cUnit);
      var unit = ProductUnit.pc;
      if (unitText.isNotEmpty) {
        final parsed = ProductUnit.tryParse(unitText);
        if (parsed == null) {
          problems.add(ProductRowProblem.unitUnknown);
        } else {
          unit = parsed;
        }
      }

      var gstBp = 0;
      final gstText = raw.cell(cGst).replaceAll('%', '').trim();
      if (gstText.isNotEmpty) {
        final bp = GstRates.parse(gstText);
        if (bp == null || !GstRates.isValid(bp)) {
          problems.add(ProductRowProblem.gstInvalid);
        } else {
          gstBp = bp;
        }
      }

      final hsn = raw.cell(cHsn);
      if (hsn.isNotEmpty && !RegExp(r'^(\d{4}|\d{6}|\d{8})$').hasMatch(hsn)) {
        problems.add(ProductRowProblem.hsnInvalid);
      }

      final prices = <String, int>{};
      for (final (tier, col) in [
        ('retail', cRetail),
        ('wholesale', cWholesale),
      ]) {
        final text = raw.cell(col);
        if (text.isEmpty) continue;
        final m = Money.tryParse(text.replaceAll('₹', '').replaceAll(',', ''));
        if (m == null || m.isNegative) {
          problems.add(ProductRowProblem.priceInvalid);
        } else {
          prices[tier] = m.paise;
        }
      }

      var reorder = 0;
      final reorderText = raw.cell(cReorder);
      if (reorderText.isNotEmpty) {
        final q = Money.tryParse(reorderText);
        if (q == null || q.isNegative) {
          problems.add(ProductRowProblem.priceInvalid);
        } else {
          // Money parses "12.5" as 1250 hundredths: milli units are x10.
          reorder = q.paise * 10;
        }
      }

      String? categoryId;
      final categoryText = raw.cell(cCategory);
      if (categoryText.isNotEmpty) {
        categoryId = categories[categoryText.toLowerCase()];
        if (categoryId == null) warnings.add(ProductRowWarning.categoryUnknown);
      }

      if (sku.isNotEmpty) {
        final key = sku.toLowerCase();
        if (skus.contains(key)) problems.add(ProductRowProblem.skuExists);
        if (!seenSkus.add(key)) problems.add(ProductRowProblem.duplicateInFile);
      }
      if (barcode.isNotEmpty) {
        final key = barcode.toLowerCase();
        if (barcodes.contains(key)) {
          problems.add(ProductRowProblem.barcodeExists);
        }
        if (!seenBarcodes.add(key) &&
            !problems.contains(ProductRowProblem.duplicateInFile)) {
          problems.add(ProductRowProblem.duplicateInFile);
        }
      }

      rows.add(
        ProductImportRow(
          number: raw.number,
          problems: problems,
          warnings: warnings,
          input: ProductInput(
            sku: sku,
            barcode: barcode.isEmpty ? null : barcode,
            name: name,
            brand: raw.cell(cBrand).isEmpty ? null : raw.cell(cBrand),
            categoryId: categoryId,
            unit: unit,
            packSize: raw.cell(cPack).isEmpty ? null : raw.cell(cPack),
            hsn: hsn.isEmpty ? null : hsn,
            gstRateBp: gstBp,
            reorderLevelMilli: reorder,
            prices: prices,
          ),
        ),
      );
    }
    return ProductImportPreview(rows: rows);
  }
}
