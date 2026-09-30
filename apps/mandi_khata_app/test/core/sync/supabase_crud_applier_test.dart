import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mandi_khata_app/core/sync/supabase_connector.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _tenant = '11111111-1111-4111-8111-111111111111';
const _row = '22222222-2222-4222-8222-222222222222';

CrudEntry _put(String table, Map<String, Object?> data) =>
    CrudEntry(1, UpdateType.put, table, _row, 1, data);

http.Response _error(http.Request request, String code) => http.Response(
  jsonEncode({'code': code, 'message': 'rejected', 'details': null}),
  code == '23505' ? 409 : 403,
  headers: {'content-type': 'application/json'},
  request: request,
);

void main() {
  late List<http.Request> requests;
  late http.Response Function(http.Request) respond;

  SupabaseCrudApplier applier() => SupabaseCrudApplier(
    SupabaseClient(
      'https://test.supabase.co',
      'anon',
      httpClient: MockClient((request) async {
        requests.add(request);
        return respond(request);
      }),
    ),
  );

  setUp(() {
    requests = [];
    respond = (request) => http.Response('', 201, request: request);
  });

  group('append-only tables', () {
    final audit = _put('audit_log', {
      'tenant_id': _tenant,
      'table_name': 'parties',
      'row_id': _row,
      'action': 'insert',
      'after': '{"name":"Gurpreet"}',
    });

    test('upload as a plain insert, never an upsert', () async {
      await applier().apply(audit);

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/rest/v1/audit_log');
      expect(request.headers['Prefer'] ?? '', isNot(contains('resolution')));
      expect(jsonDecode(request.body), containsPair('id', _row));
    });

    test('a duplicate on retry means the row already landed', () async {
      respond = (request) => _error(request, '23505');

      await expectLater(applier().apply(audit), completes);
    });

    test('other rejections still fail the upload', () async {
      respond = (request) => _error(request, '42501');

      await expectLater(
        applier().apply(audit),
        throwsA(isA<UploadException>().having((e) => e.code, 'code', '42501')),
      );
    });
  });

  test('mutable tables upload as an upsert', () async {
    await applier().apply(
      _put('parties', {'tenant_id': _tenant, 'name': 'Gurpreet'}),
    );

    expect(
      requests.single.headers['Prefer'],
      contains('resolution=merge-duplicates'),
    );
  });

  group('patch', () {
    final patch = CrudEntry(1, UpdateType.patch, 'parties', _row, 1, {
      'village': 'Mansa',
    });

    test('asks for the changed row back', () async {
      respond = (request) => http.Response(
        jsonEncode([
          {'id': _row},
        ]),
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );

      await applier().apply(patch);

      final request = requests.single;
      expect(request.method, 'PATCH');
      expect(request.url.queryParameters['select'], 'id');
    });

    test(
      'no row changed (hidden by RLS) is a rejection, not a success',
      () async {
        respond = (request) => http.Response(
          '[]',
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );

        await expectLater(
          applier().apply(patch),
          throwsA(
            isA<UploadException>().having((e) => e.code, 'code', '42501'),
          ),
        );
      },
    );
  });
}
