import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:uuid/uuid.dart';

/// A product the import can match a row to.
@immutable
class ProductRef {
  const ProductRef({
    required this.id,
    required this.sku,
    required this.name,
    this.barcode,
  });

  final String id;
  final String sku;
  final String name;
  final String? barcode;
}

/// What is wrong with one row.
enum StockRowProblem {
  unknownProduct,
  ambiguousProduct,
  qtyInvalid,
  costInvalid,
  mfgInvalid,
  expiryInvalid,
  expiryBeforeMfg,
  duplicateInFile,
}

/// What is wrong with the whole file.
enum StockSheetProblem { empty, noProductColumn, noQtyColumn, noCostColumn }

/// One row of the opening-stock file, read and checked.
@immutable
class OpeningStockRow {
  const OpeningStockRow({
    required this.number,
    required this.reference,
    required this.batchNo,
    required this.problems,
    this.productId,
    this.productName,
    this.qtyMilli = 0,
    this.cost = Money.zero,
    this.mfgDate,
    this.expiry,
  });

  /// Row number in the file.
  final int number;

  /// What the row said to identify the product (sku / barcode / name).
  final String reference;
  final String? productId;
  final String? productName;
  final String batchNo;
  final int qtyMilli;
  final Money cost;
  final LedgerDate? mfgDate;
  final LedgerDate? expiry;
  final List<StockRowProblem> problems;

  bool get isValid => problems.isEmpty;

  /// Cost of the quantity.
  Money get value => ShopMath.valueOf(cost, qtyMilli);
}

/// A read file: rows with their problems, ready to import when none is left.
@immutable
class OpeningStockPreview {
  const OpeningStockPreview({required this.rows, this.problem});

  final List<OpeningStockRow> rows;
  final StockSheetProblem? problem;

  List<OpeningStockRow> get valid => [
    for (final r in rows)
      if (r.isValid) r,
  ];
  List<OpeningStockRow> get invalid => [
    for (final r in rows)
      if (!r.isValid) r,
  ];

  /// All or nothing: a file with any bad row is not imported.
  bool get canImport => problem == null && rows.isNotEmpty && invalid.isEmpty;

  Money get totalValue => valid.fold(Money.zero, (a, r) => a + r.value);

  /// Same rows = same fingerprint (product, batch, qty, cost, dates).
  String get fingerprint => const Uuid().v5(
    Namespace.url.value,
    [
      for (final r in rows)
        [
          r.productId,
          r.batchNo,
          r.qtyMilli,
          r.cost.paise,
          r.mfgDate,
          r.expiry,
        ].join('|'),
    ].join('\n'),
  );
}

/// Turns a [Sheet] into an [OpeningStockPreview].
abstract final class OpeningStockImport {
  static const defaultBatchNo = 'OPENING';

  static const _sku = {'sku', 'code', 'item code', 'product code', 'itemcode'};
  static const _barcode = {'barcode', 'bar code', 'ean'};
  static const _name = {
    'product',
    'name',
    'product name',
    'item',
    'item name',
    'description',
  };
  static const _batch = {'batch', 'batch no', 'batch number', 'batchno', 'lot'};
  static const _mfg = {'mfg', 'mfg date', 'manufacture', 'manufactured'};
  static const _expiry = {
    'expiry',
    'exp',
    'expiry date',
    'exp date',
    'expires',
  };
  static const _qty = {'qty', 'quantity', 'stock', 'opening stock', 'opening'};
  static const _cost = {
    'cost',
    'cost price',
    'purchase price',
    'purchase rate',
    'rate',
    'price',
  };

  static String _norm(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'[_\.\-]+'), ' ');

  static int? _col(List<String> header, Set<String> names) {
    for (var i = 0; i < header.length; i++) {
      if (names.contains(_norm(header[i]))) return i;
    }
    return null;
  }

  /// First row is the header.
  static OpeningStockPreview preview(
    Sheet sheet, {
    required List<ProductRef> products,
  }) {
    if (sheet.isEmpty) {
      return const OpeningStockPreview(
        rows: [],
        problem: StockSheetProblem.empty,
      );
    }
    final header = sheet.rows.first.cells;
    final cSku = _col(header, _sku);
    final cBarcode = _col(header, _barcode);
    final cName = _col(header, _name);
    final cBatch = _col(header, _batch);
    final cMfg = _col(header, _mfg);
    final cExpiry = _col(header, _expiry);
    final cQty = _col(header, _qty);
    final cCost = _col(header, _cost);
    if (cSku == null && cBarcode == null && cName == null) {
      return const OpeningStockPreview(
        rows: [],
        problem: StockSheetProblem.noProductColumn,
      );
    }
    if (cQty == null) {
      return const OpeningStockPreview(
        rows: [],
        problem: StockSheetProblem.noQtyColumn,
      );
    }
    if (cCost == null) {
      return const OpeningStockPreview(
        rows: [],
        problem: StockSheetProblem.noCostColumn,
      );
    }

    final bySku = <String, List<ProductRef>>{};
    final byBarcode = <String, List<ProductRef>>{};
    final byName = <String, List<ProductRef>>{};
    for (final p in products) {
      bySku.putIfAbsent(p.sku.toLowerCase(), () => []).add(p);
      final b = p.barcode;
      if (b != null) byBarcode.putIfAbsent(b.toLowerCase(), () => []).add(p);
      byName.putIfAbsent(_norm(p.name), () => []).add(p);
    }

    final seen = <String>{};
    final rows = <OpeningStockRow>[];
    for (final row in sheet.rows.skip(1)) {
      final sku = row.cell(cSku);
      final barcode = row.cell(cBarcode);
      final name = row.cell(cName);
      final ref = [
        sku,
        barcode,
        name,
      ].firstWhere((s) => s.isNotEmpty, orElse: () => '');
      final problems = <StockRowProblem>[];

      var found = const <ProductRef>[];
      if (sku.isNotEmpty) found = bySku[sku.toLowerCase()] ?? const [];
      if (found.isEmpty && barcode.isNotEmpty) {
        found = byBarcode[barcode.toLowerCase()] ?? const [];
      }
      if (found.isEmpty && sku.isEmpty && barcode.isEmpty && name.isNotEmpty) {
        found = byName[_norm(name)] ?? const [];
      }
      ProductRef? product;
      if (found.length == 1) {
        product = found.first;
      } else if (found.isEmpty) {
        problems.add(StockRowProblem.unknownProduct);
      } else {
        problems.add(StockRowProblem.ambiguousProduct);
      }

      final qty = Qty.parse(row.cell(cQty));
      if (qty == null || qty <= 0) problems.add(StockRowProblem.qtyInvalid);
      final costText = row.cell(cCost);
      final cost = Money.tryParse(costText);
      if (cost == null || cost.isNegative) {
        problems.add(StockRowProblem.costInvalid);
      }
      final mfgText = row.cell(cMfg);
      final expText = row.cell(cExpiry);
      final mfg = mfgText.isEmpty ? null : parseDate(mfgText);
      final exp = expText.isEmpty ? null : parseDate(expText, endOfMonth: true);
      if (mfgText.isNotEmpty && mfg == null) {
        problems.add(StockRowProblem.mfgInvalid);
      }
      if (expText.isNotEmpty && exp == null) {
        problems.add(StockRowProblem.expiryInvalid);
      }
      if (mfg != null && exp != null && exp < mfg) {
        problems.add(StockRowProblem.expiryBeforeMfg);
      }
      final batchText = row.cell(cBatch);
      final batchNo = batchText.isEmpty ? defaultBatchNo : batchText;
      if (product != null && !seen.add('${product.id}|$batchNo')) {
        problems.add(StockRowProblem.duplicateInFile);
      }

      rows.add(
        OpeningStockRow(
          number: row.number,
          reference: ref,
          productId: product?.id,
          productName: product?.name,
          batchNo: batchNo,
          qtyMilli: qty ?? 0,
          cost: cost ?? Money.zero,
          mfgDate: mfg,
          expiry: exp,
          problems: problems,
        ),
      );
    }
    return OpeningStockPreview(
      rows: rows,
      problem: rows.isEmpty ? StockSheetProblem.empty : null,
    );
  }

  /// `2027-03-31`, `31/03/2027`, `31-3-27`, `03/2027` (month: first day, or
  /// the last when [endOfMonth]) and Excel date serials. Null when it is not
  /// a real date.
  static LedgerDate? parseDate(String text, {bool endOfMonth = false}) {
    final t = text.trim();
    LedgerDate? make(int y, int m, int d) {
      try {
        return LedgerDate(y, m, d);
      } on Object {
        return null;
      }
    }

    int year(int y) => y < 100 ? 2000 + y : y;
    var m = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})').firstMatch(t);
    if (m != null) {
      return make(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    }
    m = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})$').firstMatch(t);
    if (m != null) {
      return make(year(int.parse(m[3]!)), int.parse(m[2]!), int.parse(m[1]!));
    }
    m = RegExp(r'^(\d{1,2})[-/.](\d{4})$').firstMatch(t);
    if (m != null) {
      final y = int.parse(m[2]!);
      final mo = int.parse(m[1]!);
      if (mo < 1 || mo > 12) return null;
      if (!endOfMonth) return make(y, mo, 1);
      return LedgerDate.fromDateTime(
        DateTime.utc(y, mo + 1).subtract(const Duration(days: 1)),
      );
    }
    final serial = RegExp(r'^(\d{5})(\.\d+)?$').firstMatch(t);
    if (serial != null) {
      final n = int.parse(serial[1]!);
      if (n < 20000 || n > 80000) return null;
      return LedgerDate.fromDateTime(
        DateTime.utc(1899, 12, 30).add(Duration(days: n)),
      );
    }
    return null;
  }
}
