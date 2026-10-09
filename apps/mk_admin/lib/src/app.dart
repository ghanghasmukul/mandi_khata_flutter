import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/login_screen.dart';
import 'package:mk_admin/src/shell.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mandi Khata Admin',
    debugShowCheckedModeBanner: false,
    theme: MkTheme.light(),
    home: const AuthGate(),
  );
}

/// Who is signed in, and whether they are a platform admin.
final FutureProvider<Map<String, Object?>?> adminIdentityProvider =
    FutureProvider.autoDispose<Map<String, Object?>?>((ref) async {
      final session = ref.watch(sessionProvider).value;
      if (session == null) return null;
      return asMap(await ref.watch(adminApiProvider).call('me'));
    });

final sessionProvider = StreamProvider<Session?>((ref) async* {
  final auth = Supabase.instance.client.auth;
  yield auth.currentSession;
  await for (final change in auth.onAuthStateChange) {
    yield change.session;
  }
});

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (session.value == null) return const LoginScreen();
    final me = ref.watch(adminIdentityProvider);
    return me.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => LoginScreen(message: e.toString()),
      data: (identity) => identity == null
          ? const LoginScreen()
          : AdminShell(email: identity['email']?.toString() ?? ''),
    );
  }
}
