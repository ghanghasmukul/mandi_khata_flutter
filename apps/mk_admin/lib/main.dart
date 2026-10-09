import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mk_admin/src/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Build with
/// `flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// (the same dev project as the app; the anon key is public by design: what
/// an admin may do is decided by `platform_admins` in the `admin-api` function).
const _url = String.fromEnvironment('SUPABASE_URL');
const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_url.isNotEmpty && _anonKey.isNotEmpty) {
    await Supabase.initialize(url: _url, publishableKey: _anonKey);
  }
  runApp(const ProviderScope(child: AdminApp()));
}
