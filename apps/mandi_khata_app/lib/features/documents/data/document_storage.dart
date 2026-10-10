import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Party documents in Supabase Storage (private buckets `kyc-docs` and
/// `party-docs`, folder per business). File upload is one of the few online
/// calls CLAUDE.md allows; both degrade offline (the file stays queued).
abstract final class DocumentStorage {
  static Future<void> upload(
    String bucket,
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    await Supabase.instance.client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        )
        // A retry after a lost response finds the file already there.
        .onError<StorageException>((e, _) {
          if (e.statusCode == '409' || e.statusCode == '400') {
            if (e.message.toLowerCase().contains('exist')) return '';
          }
          throw e;
        });
  }

  /// A link valid for ten minutes.
  static Future<String> signedUrl(String bucket, String path) =>
      Supabase.instance.client.storage.from(bucket).createSignedUrl(path, 600);
}
