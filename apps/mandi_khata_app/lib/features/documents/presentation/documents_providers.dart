import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/documents/data/document_compressor.dart';
import 'package:mandi_khata_app/features/documents/data/document_storage.dart';
import 'package:mandi_khata_app/features/documents/data/document_uploader.dart';
import 'package:mandi_khata_app/features/documents/data/documents_repository.dart';
import 'package:mandi_khata_app/features/documents/domain/party_document.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'documents_providers.g.dart';

@Riverpod(keepAlive: true)
Future<DocumentsRepository> documentsRepository(Ref ref) async =>
    DocumentsRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Sends a file to Supabase Storage. A provider so tests replace it.
@Riverpod(keepAlive: true)
DocumentUploadFn documentUploadFn(Ref ref) => DocumentStorage.upload;

@Riverpod(keepAlive: true)
Future<DocumentUploader> documentUploader(Ref ref) async => DocumentUploader(
  await ref.watch(powerSyncDatabaseProvider.future),
  ref.watch(documentUploadFnProvider),
);

/// Runs the document uploads whenever sync is connected and a file waits.
/// Watched for the app's lifetime (main.dart).
@Riverpod(keepAlive: true)
Future<void> documentUploadRunner(Ref ref) async {
  if (!syncConfigured) return;
  final uploader = await ref.watch(documentUploaderProvider.future);
  var pending = 0;
  var connected = false;
  Future<void> tryNow() async {
    if (connected && pending > 0) await uploader.uploadPending();
  }

  ref.listen(syncStatusProvider, (_, next) {
    connected = next.value?.connected ?? false;
    unawaited(tryNow());
  });
  final sub = uploader.watchPending().listen((n) {
    pending = n;
    unawaited(tryNow());
  });
  ref.onDispose(sub.cancel);
}

/// Files of the active business waiting for upload on this device. Live.
@riverpod
Stream<int> pendingDocuments(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  final uploader = await ref.watch(documentUploaderProvider.future);
  yield* uploader.watchPending(tenantId: tenantId);
}

/// Documents of one party that the signed-in member may see. Live.
@riverpod
Stream<List<PartyDocument>> partyDocuments(Ref ref, String partyId) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final isOwner = ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
  final repo = await ref.watch(documentsRepositoryProvider.future);
  yield* repo.watchForParty(tenantId, partyId, isOwner: isOwner);
}

/// The file (or its thumbnail) at [path]: from this device if it is still
/// waiting to upload, else a short signed link (online only); null when
/// neither.
@riverpod
Future<({Uint8List? bytes, String? url})?> documentImage(
  Ref ref,
  String bucket,
  String path,
) async {
  final uploader = await ref.watch(documentUploaderProvider.future);
  final local = await uploader.localBytes(path);
  if (local != null) return (bytes: local, url: null);
  if (!syncConfigured) return null;
  try {
    return (bytes: null, url: await DocumentStorage.signedUrl(bucket, path));
  } on Object {
    return null;
  }
}

/// Opens the camera (Android / iOS) or the file picker; null when cancelled.
typedef DocumentPickerFn =
    Future<DocumentFile?> Function({required bool camera});

/// Why picking failed.
class DocumentPickFailed implements Exception {
  const DocumentPickFailed(this.reason);
  final DocumentRefusal reason;
}

bool get cameraAvailable =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

@Riverpod(keepAlive: true)
DocumentPickerFn documentPicker(Ref ref) => ({required camera}) async {
  final String name;
  final Uint8List bytes;
  if (camera && cameraAvailable) {
    final shot = await ImagePicker().pickImage(source: ImageSource.camera);
    if (shot == null) return null;
    name = shot.name;
    bytes = await shot.readAsBytes();
  } else {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: DocumentRules.allowedExtensions,
    );
    if (file == null) return null;
    name = file.name;
    bytes = await file.readAsBytes();
  }
  final out = await DocumentCompressor.compress(name, bytes);
  if (out == null) {
    throw DocumentPickFailed(
      DocumentRules.contentTypeOf(name) == null
          ? DocumentRefusal.unsupportedType
          : DocumentRefusal.tooLarge,
    );
  }
  return out;
};

/// Adds / removes documents as the signed-in member of the active business.
class DocumentWriter {
  DocumentWriter(this._ref);

  final Ref _ref;

  Future<DocumentResult> add(DocumentDraft draft) async {
    final ctx = _ref.read(writeContextProvider);
    final membership = _ref.read(activeMembershipProvider);
    if (ctx == null || membership == null) {
      return const DocumentRefused(DocumentRefusal.notAllowed);
    }
    final repo = await _ref.read(documentsRepositoryProvider.future);
    return await repo.add(
      ctx,
      draft,
      isOwner: membership.role == MemberRole.owner,
      can: membership.can,
    );
  }

  Future<bool> delete(String id) async {
    final ctx = _ref.read(writeContextProvider);
    final membership = _ref.read(activeMembershipProvider);
    if (ctx == null || membership == null) return false;
    final repo = await _ref.read(documentsRepositoryProvider.future);
    return await repo.delete(
      ctx,
      id,
      isOwner: membership.role == MemberRole.owner,
      can: membership.can,
    );
  }
}

@riverpod
DocumentWriter documentWriter(Ref ref) => DocumentWriter(ref);
