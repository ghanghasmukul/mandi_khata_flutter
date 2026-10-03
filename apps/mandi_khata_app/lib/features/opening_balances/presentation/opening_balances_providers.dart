import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/opening_balances/data/opening_balances_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'opening_balances_providers.g.dart';

@Riverpod(keepAlive: true)
Future<OpeningBalancesRepository> openingBalancesRepository(Ref ref) async =>
    OpeningBalancesRepository(
      await ref.watch(powerSyncDatabaseProvider.future),
    );

/// A file the person chose.
class PickedFile {
  const PickedFile(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}

/// Opens the system file dialog for a CSV / Excel file; null when cancelled.
/// A provider so tests can replace it.
typedef FilePickerFn = Future<PickedFile?> Function();

@Riverpod(keepAlive: true)
FilePickerFn importFilePicker(Ref ref) => () async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['csv', 'tsv', 'txt', 'xlsx', 'xls'],
  );
  if (file == null) return null;
  return PickedFile(file.name, await file.readAsBytes());
};

/// Why a file could not be read.
enum ImportReadFailure { oldExcel, unreadable, empty }

/// Reads a picked file (CSV / text / .xlsx) into a [Sheet].
/// Throws [ImportReadException].
Sheet readPickedFile(PickedFile file) {
  final name = file.name.toLowerCase();
  try {
    if (name.endsWith('.xls')) {
      throw const ImportReadException(ImportReadFailure.oldExcel);
    }
    final Sheet sheet;
    if (name.endsWith('.xlsx')) {
      sheet = XlsxReader.read(file.bytes);
    } else {
      sheet = DelimitedText.parse(
        utf8.decode(file.bytes, allowMalformed: true),
      );
    }
    if (sheet.isEmpty) {
      throw const ImportReadException(ImportReadFailure.empty);
    }
    return sheet;
  } on SheetFormatException {
    throw const ImportReadException(ImportReadFailure.unreadable);
  }
}

class ImportReadException implements Exception {
  const ImportReadException(this.reason);

  final ImportReadFailure reason;
}

/// Runs the import as the signed-in member of the active business.
class OpeningBalanceImporter {
  OpeningBalanceImporter(this._ref);

  final Ref _ref;

  Future<List<ExistingParty>> existingParties() async {
    final ctx = _ref.read(writeContextProvider);
    if (ctx == null) return const [];
    final repo = await _ref.read(openingBalancesRepositoryProvider.future);
    return await repo.existingParties(ctx.tenantId);
  }

  Future<bool> alreadyImported(OpeningPreview preview, LedgerDate asOn) async {
    final ctx = _ref.read(writeContextProvider);
    if (ctx == null || !preview.canImport) return false;
    final repo = await _ref.read(openingBalancesRepositoryProvider.future);
    return await repo.batchImported(
      ctx.tenantId,
      OpeningBalancesRepository.batchId(ctx.tenantId, preview, asOn),
    );
  }

  Future<OpeningImportResult> run(
    OpeningPreview preview, {
    required LedgerDate asOn,
    String? fileName,
  }) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const OpeningNotPermitted(Permission.entriesReverse);
    }
    final repo = await _ref.read(openingBalancesRepositoryProvider.future);
    return await repo.import(
      ctx,
      preview,
      asOn: asOn,
      can: member.can,
      fileName: fileName,
    );
  }
}

@Riverpod(keepAlive: true)
OpeningBalanceImporter openingBalanceImporter(Ref ref) =>
    OpeningBalanceImporter(ref);
