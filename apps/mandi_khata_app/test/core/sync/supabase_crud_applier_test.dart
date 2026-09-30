import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mandi_khata_app/core/sync/supabase_connector.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _tenant = '11111111-1111-4111-8111-111111111111';
const _party = '22222222-2222-4222-8222-222222222222';
const _audit = '33333333-3333-4333-8333-333333333333';

/// What the server does with these is covered by pgTAP
/// (supabase/tests/04_ledger.test.sql); here: what the app sends and how it
/// reads a rejection.
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

  http.Response error(http.Request request, String code, String? hint) =>
      http.Response(
        jsonEncode({
          'code': code,
          'message': 'rejected',
          'details': null,
          'hint': hint,
        }),
        400,
        headers: {'content-type': 'application/json'},
        request: request,
      );

  final transaction = [
    CrudEntry(1, UpdateType.put, 'parties', _party, 7, {
      'tenant_id': _tenant,
      'name': 'Gurpreet',
    }),
    CrudEntry(2, UpdateType.patch, 'parties', _party, 7, {'village': 'Mansa'}),
    CrudEntry(3, UpdateType.put, 'audit_log', _audit, 7, {
      'tenant_id': _tenant,
      'after': '{"name":"Gurpreet"}',
    }),
  ];

  setUp(() {
    requests = [];
    respond = (request) => http.Response('', 204, request: request);
  });

  test('sends the whole transaction in one call, in order', () async {
    await applier().applyTransaction(transaction);

    final request = requests.single;
    expect(request.method, 'POST');
    expect(request.url.path, '/rest/v1/rpc/apply_crud_transaction');
    final ops = (jsonDecode(request.body) as Map)['ops'] as List;
    expect(ops, [
      {
        'op': 'PUT',
        'table': 'parties',
        'id': _party,
        'data': {'tenant_id': _tenant, 'name': 'Gurpreet'},
      },
      {
        'op': 'PATCH',
        'table': 'parties',
        'id': _party,
        'data': {'village': 'Mansa'},
      },
      {
        'op': 'PUT',
        'table': 'audit_log',
        'id': _audit,
        // JSON text stored locally goes up as JSON.
        'data': {
          'tenant_id': _tenant,
          'after': {'name': 'Gurpreet'},
        },
      },
    ]);
  });

  test('a rejection says which change failed', () async {
    respond = (request) => error(request, '23505', 'op 2');

    await expectLater(
      applier().applyTransaction(transaction),
      throwsA(
        isA<UploadException>()
            .having((e) => e.code, 'code', '23505')
            .having((e) => e.failedIndex, 'failedIndex', 1),
      ),
    );
  });

  test('a rejection without a position still carries the code', () async {
    respond = (request) => error(request, '42501', null);

    await expectLater(
      applier().applyTransaction(transaction),
      throwsA(
        isA<UploadException>()
            .having((e) => e.code, 'code', '42501')
            .having((e) => e.failedIndex, 'failedIndex', isNull),
      ),
    );
  });
}
