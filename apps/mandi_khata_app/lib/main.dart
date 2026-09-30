import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _log = Logger('app');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.onRecord.listen(
    (r) => debugPrint('${r.level.name} ${r.loggerName}: ${r.message}'),
  );
  if (Env.hasSupabase) {
    try {
      // Restores a cached session from disk, so an offline launch stays
      // signed in; a failed token refresh is retried later by the SDK.
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
    } on Object catch (e) {
      _log.warning('Supabase init failed, continuing offline: $e');
    }
  }
  runApp(const ProviderScope(child: MandiKhataApp()));
}

class MandiKhataApp extends ConsumerStatefulWidget {
  const MandiKhataApp({super.key});

  @override
  ConsumerState<MandiKhataApp> createState() => _MandiKhataAppState();
}

class _MandiKhataAppState extends ConsumerState<MandiKhataApp> {
  final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keeps sync running (connect while signed in) for the app's lifetime.
    ref.watch(syncControllerProvider);
    return MaterialApp.router(
      title: 'Mandi Khata',
      debugShowCheckedModeBanner: false,
      theme: MkTheme.light(),
      // Dark theme is a stub; ship light only until it is designed.
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
