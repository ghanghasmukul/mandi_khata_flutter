import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Bill photos in Supabase Storage (private bucket `bills`, folder per
/// business). File upload is one of the few online calls CLAUDE.md allows;
/// both degrade offline (the caller keeps the photo queued / shows a note).
abstract final class BillStorage {
  static const bucket = 'bills';

  static Future<void> upload(
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    await Supabase.instance.client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
  }

  /// A link valid for ten minutes.
  static Future<String> signedUrl(String path) =>
      Supabase.instance.client.storage.from(bucket).createSignedUrl(path, 600);
}
