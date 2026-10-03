// Two real devices against a real (local) Supabase: lots made offline on a
// counter PC (W1, owner) and a gate phone (A1, munshi) upload without number
// collisions, nothing is lost, a rejected change does not block the queue,
// the owner sees the munshi's edits in the audit log, and another business
// sees none of it.
//
// Needs the local stack (Docker): scripts/hardening/two_device_sync.sh starts
// from `supabase status` and sets the variables below. Skipped otherwise, so
// plain `flutter test` stays offline.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/sync/supabase_connector.dart';
import 'package:mandi_khata_app/core/sync/upload_policy.dart';
import 'package:mandi_khata_app/features/arrivals/data/lots_repository.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../integration_test/support/khata_flow.dart';

final Map<String, String> _env = Platform.environment;
final String? _url = _env['MK_LOCAL_API_URL'];
final String? _anon = _env['MK_LOCAL_ANON_KEY'];
final String? _service = _env['MK_LOCAL_SERVICE_KEY'];
const _password = 'Hardening-pass-1!';
const _uuid = Uuid();

bool Function(Permission) _can(MemberRole role) =>
    (p) => role.allows(p);

class _Person {
  _Person(this.id, this.email, this.client);
  final String id;
  final String email;
  final SupabaseClient client;
}

Future<_Person> _signUp(SupabaseClient admin, String label) async {
  final email = '$label-${_uuid.v4().substring(0, 8)}@hardening.test';
  final user = (await admin.auth.admin.createUser(
    AdminUserAttributes(email: email, password: _password, emailConfirm: true),
  )).user!;
  final client = SupabaseClient(_url!, _anon!);
  await client.auth.signInWithPassword(email: email, password: _password);
  return _Person(user.id, email, client);
}

Future<String> _newBusiness(
  SupabaseClient admin,
  List<(_Person, String)> members,
) async {
  final tenant = _uuid.v4();
  await admin.from('tenants').insert({
    'id': tenant,
    'name': 'Hardening ${tenant.substring(0, 6)}',
  });
  await admin.from('tenant_members').insert([
    for (final (p, role) in members)
      {'id': _uuid.v4(), 'tenant_id': tenant, 'user_id': p.id, 'role': role},
  ]);
  return tenant;
}

Future<WriteContext> _register(
  _Person p,
  String tenant,
  String platform,
) async {
  final deviceId = _uuid.v4();
  final row = await p.client.rpc<Map<String, dynamic>>(
    'register_device',
    params: {
      'p_device_id': deviceId,
      'p_tenant_id': tenant,
      'p_platform': platform,
    },
  );
  return WriteContext(
    tenantId: tenant,
    userId: p.id,
    deviceId: deviceId,
    deviceCode: row['device_code'] as String,
  );
}

Future<void> _drain(PowerSyncDatabase db, SupabaseClient client) async {
  final applier = SupabaseCrudApplier(client);
  final backoff = UploadBackoff();
  while (await db.getNextCrudTransaction() != null) {
    await uploadPending(db, applier, backoff, wait: (_) async {});
  }
}

void main() {
  final enabled = _url != null && _anon != null && _service != null;
  late Directory dir;
  late PowerSyncDatabase ownerDb;
  late PowerSyncDatabase munshiDb;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_two_device');
    ownerDb = PowerSyncDatabase(
      schema: powerSyncSchema,
      path: '${dir.path}/owner.db',
    );
    munshiDb = PowerSyncDatabase(
      schema: powerSyncSchema,
      path: '${dir.path}/munshi.db',
    );
    await ownerDb.initialize();
    await munshiDb.initialize();
  });

  tearDown(() async {
    await ownerDb.close();
    await munshiDb.close();
    await dir.delete(recursive: true);
  });

  test(
    'two devices create lots offline: no number collisions, both sync, '
    'rejections do not block, audit and isolation hold',
    () async {
      final admin = SupabaseClient(_url!, _service!);
      final owner = await _signUp(admin, 'owner');
      final munshi = await _signUp(admin, 'munshi');
      final stranger = await _signUp(admin, 'stranger');
      final tenant = await _newBusiness(admin, [
        (owner, 'owner'),
        (munshi, 'munshi'),
      ]);
      await _newBusiness(admin, [(stranger, 'owner')]);

      final w1 = await _register(owner, tenant, 'windows');
      final a1 = await _register(munshi, tenant, 'android');
      expect(w1.deviceCode, 'W1');
      expect(a1.deviceCode, 'A1');

      // Day starts online: the owner sets the business up and it syncs; the
      // munshi's phone receives the same master data (as a download would).
      await seedBusiness(ownerDb, tenant);
      // The server seeds every business's Cash account itself; do not send it.
      await ownerDb.execute('DELETE FROM ps_crud WHERE data LIKE ?', [
        '%"type":"bank_accounts"%',
      ]);
      final ownerParties = PartiesRepository(ownerDb);
      final farmer = await ownerParties.create(
        w1,
        const PartyInput(
          code: '',
          name: 'Gurmeet Singh',
          roles: {PartyRole.farmer},
        ),
        can: _can(MemberRole.owner),
      );
      final farmerId = (farmer as PartySaved).id;
      await _drain(ownerDb, owner.client);
      await seedBusiness(munshiDb, tenant);
      await munshiDb.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [farmerId, tenant, farmer.code, 'Gurmeet Singh'],
      );
      await munshiDb.execute('DELETE FROM ps_crud');

      // ---- Offline: both devices work without a connection.
      final wheat = CropsRepository.idFor(tenant, 'wheat');
      LotDraft draft(int bags) => LotDraft(
        entryDate: LedgerDate.fromDateTime(DateTime.now()),
        farmerId: farmerId,
        cropId: wheat,
        bags: bags,
        qtlMilli: bags * 480,
        rate: const Money.rupees(2425),
      );
      final ownerLots = LotsRepository(ownerDb);
      final munshiLots = LotsRepository(munshiDb);
      final lotNos = <String>[];
      Future<void> make(
        LotsRepository repo,
        WriteContext ctx,
        MemberRole role,
        int bags,
      ) async {
        final r = await repo.save(ctx, draft(bags), can: _can(role));
        expect(r, isA<LotSaved>(), reason: '${ctx.deviceCode} lot');
        lotNos.add((r as LotSaved).lotNo);
      }

      for (var i = 1; i <= 3; i++) {
        await make(ownerLots, w1, MemberRole.owner, 10 + i);
      }
      await make(munshiLots, a1, MemberRole.munshi, 20);
      // A change the server will refuse (a munshi may not add a bank
      // account): it must land in sync_errors and not block what follows.
      await munshiDb.execute(
        'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
        "sort_order) VALUES (?, ?, 'bank', 'Sneaky bank', 1, 5)",
        [_uuid.v4(), tenant],
      );
      await make(munshiLots, a1, MemberRole.munshi, 21);
      await make(munshiLots, a1, MemberRole.munshi, 22);
      final pay = await PaymentsRepository(munshiDb).save(
        a1,
        PaymentDraft(
          entryDate: LedgerDate.fromDateTime(DateTime.now()),
          partyId: farmerId,
          direction: PaymentDirection.toParty,
          mode: PaymentMode.cash,
          amount: const Money.rupees(2000),
        ),
        can: _can(MemberRole.munshi),
      );
      expect(pay, isA<PaymentSaved>());
      // Both devices edit the same farmer, different fields.
      expect(
        await ownerParties.update(
          w1,
          farmerId,
          const PartyInput(
            code: 'F-1',
            name: 'Gurmeet Singh',
            roles: {PartyRole.farmer},
            village: 'Bhikhi',
          ),
          can: _can(MemberRole.owner),
        ),
        isA<PartySaved>(),
      );
      expect(
        await PartiesRepository(munshiDb).update(
          a1,
          farmerId,
          PartyInput(
            code: farmer.code,
            name: 'Gurmeet Singh',
            roles: const {PartyRole.farmer},
            mobile: '9814022110',
          ),
          can: _can(MemberRole.munshi),
        ),
        isA<PartySaved>(),
      );

      // ---- Nothing was sent yet.
      final before = await admin
          .from('lots')
          .select('id')
          .eq('tenant_id', tenant);
      expect(before, isEmpty);

      // ---- Back online: both upload (munshi first, owner second).
      await _drain(munshiDb, munshi.client);
      await _drain(ownerDb, owner.client);

      // No number collisions: six distinct lot numbers, two device series.
      expect(lotNos.toSet(), hasLength(6));
      final lots = await admin
          .from('lots')
          .select('lot_no, status')
          .eq('tenant_id', tenant);
      expect(
        [for (final l in lots) l['lot_no']],
        unorderedEquals([
          'L-W1-0001',
          'L-W1-0002',
          'L-W1-0003',
          'L-A1-0001',
          'L-A1-0002',
          'L-A1-0003',
        ]),
      );
      expect(lots.every((l) => l['status'] == 'posted'), isTrue);

      // Nothing lost: 6 arrival credits + 1 payment debit; the baki on the
      // server equals the two devices' local sums added up.
      final entries = await admin
          .from('ledger_entries')
          .select('side, amount_paise')
          .eq('tenant_id', tenant)
          .eq('party_id', farmerId);
      expect(entries, hasLength(7));
      int net(List<Map<String, Object?>> rows) => rows.fold(
        0,
        (s, r) =>
            s + (r['side'] == 'jama' ? 1 : -1) * (r['amount_paise']! as int),
      );
      Future<int> local(PowerSyncDatabase db) async => net(
        await db.getAll(
          'SELECT side, amount_paise FROM ledger_entries WHERE party_id = ?',
          [farmerId],
        ),
      );
      expect(
        net([
          for (final e in entries) {...e},
        ]),
        await local(ownerDb) + await local(munshiDb),
      );

      // Master data last-write-wins per field: both edits survive.
      final party = await admin
          .from('parties')
          .select('village, mobile')
          .eq('id', farmerId)
          .single();
      expect(party['village'], 'Bhikhi');
      expect(party['mobile'], '9814022110');

      // The rejected change is in the munshi's sync_errors; the queue moved.
      final errors = await munshiDb.getAll('SELECT * FROM sync_errors');
      expect(
        errors.where((e) => e['table_name'] == 'bank_accounts'),
        hasLength(1),
      );
      expect(await ownerDb.getAll('SELECT * FROM sync_errors'), isEmpty);
      expect(await munshiDb.getAll('SELECT * FROM ps_crud'), isEmpty);
      final banks = await admin
          .from('bank_accounts')
          .select('name')
          .eq('tenant_id', tenant)
          .eq('kind', 'bank');
      expect(banks, isEmpty, reason: 'the munshi added no bank account');

      // Audit: both users' writes are there, with the server-set role, and
      // the owner can read them; the munshi cannot.
      final seen = await owner.client
          .from('audit_log')
          .select('user_id, role, table_name, action')
          .eq('tenant_id', tenant);
      final byMunshi = seen.where((r) => r['user_id'] == munshi.id).toList();
      expect(byMunshi, isNotEmpty);
      expect(byMunshi.every((r) => r['role'] == 'munshi'), isTrue);
      expect(
        byMunshi.any(
          (r) => r['table_name'] == 'parties' && r['action'] == 'update',
        ),
        isTrue,
        reason: 'the munshi party edit is in the owner audit log',
      );
      expect(
        seen.any((r) => r['user_id'] == owner.id && r['role'] == 'owner'),
        isTrue,
      );
      final ownLog = await munshi.client
          .from('audit_log')
          .select('user_id')
          .eq('tenant_id', tenant);
      expect(ownLog, isNotEmpty);
      expect(
        ownLog.every((r) => r['user_id'] == munshi.id),
        isTrue,
        reason: 'the munshi sees only the rows they wrote',
      );

      // Another business sees none of it.
      for (final table in ['lots', 'ledger_entries', 'parties', 'audit_log']) {
        expect(
          await stranger.client
              .from(table)
              .select('id')
              .eq('tenant_id', tenant),
          isEmpty,
          reason: 'stranger reads $table',
        );
      }
    },
    skip: enabled
        ? false
        : 'needs the local Supabase stack: scripts/hardening/two_device_sync.sh',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
