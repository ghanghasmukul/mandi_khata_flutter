import 'dart:io';

import 'package:mandi_khata_app/features/backup/data/backup_codec.dart';
import 'package:mandi_khata_app/features/backup/data/backup_service.dart';

/// Writes encrypted backup files to a folder (a PC folder or a USB stick)
/// and keeps the newest few.
class BackupRunner {
  BackupRunner(this._service);

  final BackupService _service;

  static const extension = 'mkbak';

  /// A backup older than this is due.
  static const interval = Duration(hours: 24);

  /// How many files stay in the folder.
  static const keep = 14;

  static bool isDue(DateTime? last, DateTime now) =>
      last == null || now.difference(last) >= interval;

  /// `MandiKhata-<business>-<yyyyMMdd-HHmm>.mkbak` (UTC, safe on FAT/NTFS).
  static String fileName(String tenantName, DateTime now) {
    final slug = tenantName
        .replaceAll(RegExp('[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final t = now.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'MandiKhata-${slug.isEmpty ? 'business' : slug}-'
        '${t.year}${two(t.month)}${two(t.day)}-${two(t.hour)}${two(t.minute)}'
        '.$extension';
  }

  /// Writes one backup into [folder] and prunes old ones of the same
  /// business. Returns the file path. The file is written under a temporary
  /// name and renamed, so a stick pulled out half way never leaves a broken
  /// `.mkbak`.
  Future<String> run({
    required String tenantId,
    required String tenantName,
    required String folder,
    required String passphrase,
    String appVersion = '',
    DateTime? now,
    int iterations = BackupCodec.defaultIterations,
  }) async {
    final when = now ?? DateTime.now();
    final snapshot = await _service.snapshot(
      tenantId,
      tenantName: tenantName,
      appVersion: appVersion,
      now: when,
    );
    final bytes = await BackupCodec.encrypt(
      snapshot,
      passphrase,
      iterations: iterations,
    );
    final dir = Directory(folder);
    if (!dir.existsSync()) await dir.create(recursive: true);
    final target = File('$folder/${fileName(tenantName, when)}');
    final temp = File('${target.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(target.path);
    await _prune(dir, tenantName);
    return target.path;
  }

  Future<void> _prune(Directory dir, String tenantName) async {
    final prefix = fileName(tenantName, DateTime.utc(2000)).split('-20').first;
    final files = [
      for (final e in dir.listSync())
        if (e is File &&
            e.uri.pathSegments.last.startsWith(prefix) &&
            e.path.endsWith('.$extension'))
          e,
    ]..sort((a, b) => b.path.compareTo(a.path));
    for (final old in files.skip(keep)) {
      await old.delete();
    }
  }
}
