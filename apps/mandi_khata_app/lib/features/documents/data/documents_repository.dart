import 'dart:convert';
import 'dart:typed_data';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/documents/domain/party_document.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Party documents in the local database (step 6.3,
/// docs/domain/documents-kyc.md).
///
/// Adding one writes, in ONE local transaction: the `party_documents` row,
/// its audit row and the upload jobs for the file and its thumbnail. The
/// files go to Storage later, online. The full Aadhaar / PAN number a person
/// typed is used to build the masked text and then dropped.
class DocumentsRepository {
  DocumentsRepository(this._db);

  final PowerSyncDatabase _db;

  /// Documents of [partyId] this member may see. Identity documents are only
  /// ever on an owner's device (sync streams + RLS), but the filter here makes
  /// the rule hold for a stale local copy too.
  Stream<List<PartyDocument>> watchForParty(
    String tenantId,
    String partyId, {
    required bool isOwner,
  }) => _db
      .watch(
        'SELECT * FROM party_documents WHERE tenant_id = ? AND party_id = ? '
        'AND deleted_at IS NULL '
        "AND (? = 1 OR doc_type NOT IN ('aadhaar', 'pan')) "
        'ORDER BY created_at DESC',
        parameters: [tenantId, partyId, if (isOwner) 1 else 0],
        triggerOnTables: const {'party_documents'},
      )
      .map((rows) => [for (final r in rows) PartyDocument.fromRow(r)]);

  /// Adds a document. [isOwner] and [can] come from the membership.
  Future<DocumentResult> add(
    WriteContext ctx,
    DocumentDraft draft, {
    required bool isOwner,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final type = draft.type;
    final allowed = type.isIdentity ? isOwner : can(Permission.partiesManage);
    if (!allowed) return const DocumentRefused(DocumentRefusal.notAllowed);
    final file = draft.file;
    if (file.bytes.length > DocumentRules.maxBytes) {
      return const DocumentRefused(DocumentRefusal.tooLarge);
    }
    if (DocumentRules.contentTypeOf(file.fileName) == null) {
      return const DocumentRefused(DocumentRefusal.unsupportedType);
    }
    String? masked;
    final number = draft.idNumber?.trim() ?? '';
    if (type.isIdentity && number.isNotEmpty) {
      masked = DocumentRules.maskIdentity(type, number);
      if (masked == null) {
        return const DocumentRefused(DocumentRefusal.badIdNumber);
      }
    }

    final when = (now ?? DateTime.now()).toUtc();
    final at = when.toIso8601String();
    final id = const Uuid().v4();
    final path = DocumentRules.storagePath(
      tenantId: ctx.tenantId,
      partyId: draft.partyId,
      documentId: id,
      fileName: file.fileName,
    );
    final thumbPath = file.thumb == null ? null : DocumentRules.thumbPath(path);
    final bucket = DocumentBuckets.of(type);
    final title = _clean(draft.title);
    final notes = _clean(draft.notes);

    await _db.writeTransaction((tx) async {
      await tx.execute(
        'INSERT INTO party_documents (id, tenant_id, party_id, doc_type, '
        'title, id_masked, file_path, thumb_path, content_type, size_bytes, '
        'notes, created_by, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          id,
          ctx.tenantId,
          draft.partyId,
          type.code,
          title,
          masked,
          path,
          thumbPath,
          file.contentType,
          file.bytes.length,
          notes,
          ctx.userId,
          at,
          at,
        ],
      );
      await _enqueue(
        tx,
        ctx,
        id,
        bucket,
        path,
        file.contentType,
        file.bytes,
        at,
      );
      if (thumbPath != null) {
        await _enqueue(
          tx,
          ctx,
          id,
          bucket,
          thumbPath,
          'image/jpeg',
          file.thumb!,
          at,
        );
      }
      await AuditWriter.record(
        tx,
        ctx,
        table: 'party_documents',
        rowId: id,
        action: AuditAction.insert,
        after: {
          'party_id': draft.partyId,
          'doc_type': type.code,
          'title': title,
          'id_masked': masked,
          'file_path': path,
          'size_bytes': file.bytes.length,
        },
        at: when,
      );
    });
    return DocumentAdded(id);
  }

  /// Soft-deletes a document (`master.delete`). The file stays in Storage so
  /// an owner can recover it; false when refused or not found.
  Future<bool> delete(
    WriteContext ctx,
    String id, {
    required bool isOwner,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.masterDelete)) return false;
    final when = (now ?? DateTime.now()).toUtc();
    final at = when.toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT doc_type, title, file_path FROM party_documents '
        'WHERE id = ? AND tenant_id = ? AND deleted_at IS NULL',
        [id, ctx.tenantId],
      );
      if (row == null) return false;
      final type = PartyDocumentType.fromCode(row['doc_type'] as String?);
      if ((type?.isIdentity ?? false) && !isOwner) return false;
      await tx.execute(
        'UPDATE party_documents SET deleted_at = ?, updated_at = ? '
        'WHERE id = ? AND tenant_id = ?',
        [at, at, id, ctx.tenantId],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'party_documents',
        rowId: id,
        action: AuditAction.softDelete,
        before: {'title': row['title'], 'file_path': row['file_path']},
        at: when,
      );
      return true;
    });
  }

  /// Changes title / notes of a document.
  Future<bool> rename(
    WriteContext ctx,
    String id,
    String? title, {
    required bool isOwner,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.partiesManage)) return false;
    final when = (now ?? DateTime.now()).toUtc();
    final at = when.toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT doc_type, title FROM party_documents '
        'WHERE id = ? AND tenant_id = ? AND deleted_at IS NULL',
        [id, ctx.tenantId],
      );
      if (row == null) return false;
      final type = PartyDocumentType.fromCode(row['doc_type'] as String?);
      if ((type?.isIdentity ?? false) && !isOwner) return false;
      final next = _clean(title);
      await tx.execute(
        'UPDATE party_documents SET title = ?, updated_at = ? '
        'WHERE id = ? AND tenant_id = ?',
        [next, at, id, ctx.tenantId],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'party_documents',
        rowId: id,
        action: AuditAction.update,
        before: {'title': row['title']},
        after: {'title': next},
        at: when,
      );
      return true;
    });
  }

  Future<void> _enqueue(
    SqliteWriteContext tx,
    WriteContext ctx,
    String documentId,
    String bucket,
    String path,
    String contentType,
    Uint8List bytes,
    String at,
  ) => tx.execute(
    'INSERT INTO document_uploads (id, tenant_id, document_id, bucket, path, '
    'content_type, data, created_at, attempts) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)',
    [
      const Uuid().v4(),
      ctx.tenantId,
      documentId,
      bucket,
      path,
      contentType,
      base64Encode(bytes),
      at,
    ],
  );

  static String? _clean(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
