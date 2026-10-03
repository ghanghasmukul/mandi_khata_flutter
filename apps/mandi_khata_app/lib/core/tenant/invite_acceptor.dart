import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'invite_acceptor.g.dart';

final _log = Logger('invites');

/// Turns open invitations for the signed-in phone number into memberships
/// (`accept_member_invites()`). Needs the server, so it runs when online;
/// the new membership then arrives through sync like any other change.
abstract interface class InviteAcceptor {
  /// Business ids joined (empty when nothing was waiting). Throws when the
  /// server cannot be reached.
  Future<List<String>> accept();
}

class SupabaseInviteAcceptor implements InviteAcceptor {
  SupabaseInviteAcceptor(this._client);

  final SupabaseClient _client;

  @override
  Future<List<String>> accept() async {
    final result = await _client.rpc<List<dynamic>>('accept_member_invites');
    return [for (final id in result) id as String];
  }
}

class _NoAcceptor implements InviteAcceptor {
  const _NoAcceptor();

  @override
  Future<List<String>> accept() async => const [];
}

@Riverpod(keepAlive: true)
InviteAcceptor inviteAcceptor(Ref ref) {
  if (!Env.hasSupabase) return const _NoAcceptor();
  try {
    return SupabaseInviteAcceptor(Supabase.instance.client);
  } on Object {
    return const _NoAcceptor();
  }
}

/// Accepts invitations right after sign-in (once per sign-in, best effort:
/// offline simply tries again at the next sign-in or when the person taps
/// "Check again" on the empty business picker).
@Riverpod(keepAlive: true)
class InviteSync extends _$InviteSync {
  @override
  void build() {
    ref.listen(sessionProvider, (previous, session) {
      if (session is! SignedIn) return;
      if (previous is SignedIn && previous.user.id == session.user.id) return;
      unawaited(check());
    }, fireImmediately: true);
  }

  /// Tries to accept now. Returns the businesses joined, or null when the
  /// server could not be reached.
  Future<List<String>?> check() async {
    if (ref.read(sessionProvider) is! SignedIn) return const [];
    try {
      final joined = await ref.read(inviteAcceptorProvider).accept();
      if (joined.isNotEmpty) _log.info('Joined ${joined.length} business(es)');
      return joined;
    } on Object catch (e) {
      _log.fine('Invite check skipped: $e');
      return null;
    }
  }
}
