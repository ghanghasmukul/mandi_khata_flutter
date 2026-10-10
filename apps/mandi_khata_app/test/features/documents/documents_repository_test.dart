import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/documents/data/document_uploader.dart';
import 'package:mandi_khata_app/features/documents/data/documents_repository.dart';
import 'package:mandi_khata_app/features/documents/domain/party_document.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const party = 'p-1';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

DocumentFile file({bool thumb = true}) => DocumentFile(
  fileName: 'scan 1.jpg',
  bytes: Uint8List.fromList([1, 2, 3, 4]),
  contentType: 'image/jpeg',
  thumb: thumb ? Uint8List.fromList([9, 9]) : null,
);

// A valid Aadhaar: first 11 digits plus the Verhoeff check digit.
String get aadhaar {
  const p = '23456789012';
  return '$p${DocumentRules.verhoeffCheckDigit(p)}';
}

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late DocumentsRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_docs_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = DocumentsRepository(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<int> count(String sql) async =>
      (await db.get('SELECT COUNT(*) AS n FROM $sql'))['n']! as int;

  DocumentDraft draft(PartyDocumentType type, {String? number}) =>
      DocumentDraft(
        partyId: party,
        type: type,
        file: file(),
        idNumber: number,
        title: ' SBI ',
      );

  test(
    'adds a document, queues file + thumbnail and audits, in one go',
    () async {
      final r = await repo.add(
        ctx,
        draft(PartyDocumentType.passbook),
        isOwner: false,
        can: munshi,
      );
      expect(r, isA<DocumentAdded>());
      final row = await db.get('SELECT * FROM party_documents');
      expect(row['tenant_id'], t1);
      expect(row['title'], 'SBI');
      expect(row['file_path'], startsWith('$t1/$party/'));
      expect(row['thumb_path'], '${row['file_path']}.thumb.jpg');
      expect(row['size_bytes'], 4);
      final q = await db.getAll('SELECT bucket FROM document_uploads');
      expect(q.map((e) => e['bucket']), ['party-docs', 'party-docs']);
      expect(await count("audit_log WHERE table_name = 'party_documents'"), 1);
    },
  );

  test('Aadhaar: owner only, stored masked, number never saved', () async {
    final refused = await repo.add(
      ctx,
      draft(PartyDocumentType.aadhaar, number: aadhaar),
      isOwner: false,
      can: owner,
    );
    expect((refused as DocumentRefused).reason, DocumentRefusal.notAllowed);
    expect(await count('party_documents'), 0);

    final ok = await repo.add(
      ctx,
      draft(PartyDocumentType.aadhaar, number: aadhaar),
      isOwner: true,
      can: owner,
    );
    expect(ok, isA<DocumentAdded>());
    final row = await db.get('SELECT * FROM party_documents');
    expect(row['id_masked'], 'XXXX XXXX ${aadhaar.substring(8)}');
    final all = [
      ...(await db.getAll('SELECT * FROM party_documents')),
      ...(await db.getAll('SELECT * FROM audit_log')),
    ].map((r) => r.toString()).join();
    expect(all.contains(aadhaar), isFalse);
    expect(
      (await db.get('SELECT bucket FROM document_uploads'))['bucket'],
      'kyc-docs',
    );
  });

  test('a wrong Aadhaar number is refused and nothing is written', () async {
    final r = await repo.add(
      ctx,
      draft(PartyDocumentType.aadhaar, number: '234567890123'),
      isOwner: true,
      can: owner,
    );
    expect((r as DocumentRefused).reason, DocumentRefusal.badIdNumber);
    expect(await count('party_documents'), 0);
    expect(await count('document_uploads'), 0);
  });

  test('a file over the limit is refused', () async {
    final big = DocumentFile(
      fileName: 'a.jpg',
      bytes: Uint8List(DocumentRules.maxBytes + 1),
      contentType: 'image/jpeg',
    );
    final r = await repo.add(
      ctx,
      DocumentDraft(partyId: party, type: PartyDocumentType.cheque, file: big),
      isOwner: true,
      can: owner,
    );
    expect((r as DocumentRefused).reason, DocumentRefusal.tooLarge);
  });

  test('a munshi never sees identity documents; tenant filter holds', () async {
    await repo.add(
      ctx,
      draft(PartyDocumentType.aadhaar, number: aadhaar),
      isOwner: true,
      can: owner,
    );
    await repo.add(
      ctx,
      draft(PartyDocumentType.jForm),
      isOwner: true,
      can: owner,
    );
    final asOwner = await repo.watchForParty(t1, party, isOwner: true).first;
    final asMunshi = await repo.watchForParty(t1, party, isOwner: false).first;
    final otherBusiness = await repo
        .watchForParty(t2, party, isOwner: true)
        .first;
    expect(asOwner, hasLength(2));
    expect(asMunshi.map((d) => d.type), [PartyDocumentType.jForm]);
    expect(otherBusiness, isEmpty);
  });

  test('delete needs master.delete, soft-deletes and audits', () async {
    await repo.add(
      ctx,
      draft(PartyDocumentType.cheque),
      isOwner: false,
      can: munshi,
    );
    final id =
        (await db.get('SELECT id FROM party_documents'))['id']! as String;
    expect(await repo.delete(ctx, id, isOwner: false, can: munshi), isFalse);
    expect(await repo.delete(ctx, id, isOwner: true, can: owner), isTrue);
    expect(
      (await db.get('SELECT deleted_at FROM party_documents'))['deleted_at'],
      isNotNull,
    );
    expect(await repo.watchForParty(t1, party, isOwner: true).first, isEmpty);
    expect(await count("audit_log WHERE action = 'soft_delete'"), 1);
  });

  test(
    'uploader sends queued files, keeps failures, drops sent bytes',
    () async {
      await repo.add(
        ctx,
        draft(PartyDocumentType.cheque),
        isOwner: true,
        can: owner,
      );
      var fail = true;
      final sent = <String>[];
      final up = DocumentUploader(db, (bucket, path, bytes, type) async {
        if (fail) throw Exception('offline');
        sent.add('$bucket:$path');
      });
      expect(await up.uploadPending(), 0);
      expect(await count('document_uploads WHERE attempts = 1'), 2);
      fail = false;
      expect(await up.uploadPending(), 2);
      expect(sent, hasLength(2));
      expect(await count('document_uploads WHERE uploaded_at IS NULL'), 0);
      expect(await count("document_uploads WHERE data <> ''"), 0);
    },
  );
}
