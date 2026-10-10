import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';
import 'package:mandi_khata_app/features/products/domain/product_import.dart';

Sheet sheet(List<List<String>> rows) =>
    Sheet([for (final (i, r) in rows.indexed) SheetRow(i + 1, r)]);

ProductImportPreview read(
  List<List<String>> rows, {
  List<ExistingProduct> existing = const [],
  Map<String, String> categories = const {},
}) => ProductImport.preview(
  sheet(rows),
  existing: existing,
  categoriesByName: categories,
);

void main() {
  test('a Busy / Marg style header is understood', () {
    final p = read(
      [
        [
          'Item Name',
          'Item Code',
          'Unit',
          'HSN/SAC',
          'Tax Rate',
          'MRP',
          'Company',
          'Item Group',
        ],
        [
          'Urea 45kg',
          'UREA45',
          'Bags',
          '3102',
          '5%',
          '1,266.50',
          'IFFCO',
          'Fertiliser',
        ],
      ],
      categories: {'fertiliser': 'cat-1'},
    );
    expect(p.problem, isNull);
    final r = p.valid.single.input;
    expect(r.sku, 'UREA45');
    expect(r.name, 'Urea 45kg');
    expect(r.unit, ProductUnit.bag);
    expect(r.hsn, '3102');
    expect(r.gstRateBp, 500);
    expect(r.prices, {'retail': 126650});
    expect(r.brand, 'IFFCO');
    expect(r.categoryId, 'cat-1');
  });

  test('barcode stands in for a missing SKU; neither is an error', () {
    final p = read([
      ['name', 'barcode'],
      ['A', '8901'],
      ['B', ''],
    ]);
    expect(p.rows[0].input.sku, '8901');
    expect(p.rows[1].problems, [ProductRowProblem.skuMissing]);
  });

  test('every kind of bad row is reported, none is guessed', () {
    final p = read(
      [
        ['name', 'sku', 'unit', 'gst', 'hsn', 'price'],
        ['', 'A', '', '', '', ''],
        ['X', 'B', 'barrel', '', '', ''],
        ['X', 'C', '', '7', '', ''],
        ['X', 'D', '', '', '12', ''],
        ['X', 'E', '', '', '', '-5'],
        ['X', 'F', '', '', '', ''],
        ['X', 'f', '', '', '', ''],
        ['X', 'OLD', '', '', '', ''],
      ],
      existing: const [ExistingProduct(sku: 'old')],
    );
    expect(p.rows[0].problems, [ProductRowProblem.nameMissing]);
    expect(p.rows[1].problems, [ProductRowProblem.unitUnknown]);
    expect(p.rows[2].problems, [ProductRowProblem.gstInvalid]);
    expect(p.rows[3].problems, [ProductRowProblem.hsnInvalid]);
    expect(p.rows[4].problems, [ProductRowProblem.priceInvalid]);
    expect(p.rows[5].isValid, isTrue);
    expect(p.rows[6].problems, [ProductRowProblem.duplicateInFile]);
    expect(p.rows[7].problems, [ProductRowProblem.skuExists]);
    expect(p.valid, hasLength(1));
  });

  test('existing barcode is refused; unknown category only warns', () {
    final p = read(
      [
        ['name', 'sku', 'barcode', 'category'],
        ['A', '1', '8901', 'Seeds'],
      ],
      existing: const [ExistingProduct(sku: 'z', barcode: '8901')],
    );
    expect(p.rows.single.problems, [ProductRowProblem.barcodeExists]);
    expect(p.rows.single.warnings, [ProductRowWarning.categoryUnknown]);
  });

  test('file-level problems', () {
    expect(read([]).problem, ProductSheetProblem.empty);
    expect(
      read([
        ['sku'],
        ['1'],
      ]).problem,
      ProductSheetProblem.noNameColumn,
    );
  });

  test('same rows -> same fingerprint', () {
    final a = read([
      ['name', 'sku'],
      ['A', '1'],
    ]);
    final b = read([
      ['sku', 'name', 'unit'],
      ['1', 'A', 'kg'],
    ]);
    expect(a.fingerprint, b.fingerprint);
  });
}
