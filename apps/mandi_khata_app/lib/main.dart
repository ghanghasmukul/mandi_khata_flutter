import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mandi_khata_app/app/command_palette.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/app/env_ribbon.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/errors/error_reporting.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/invite_acceptor.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _log = Logger('app');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.onRecord.listen((r) {
    debugPrint('${r.level.name} ${r.loggerName}: ${r.message}');
    ErrorReporting.captureLog(r);
  });
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
  final prefs = AppPrefs(await SharedPreferences.getInstance());
  await ErrorReporting.run(
    () => runApp(
      ProviderScope(
        overrides: [appPrefsProvider.overrideWithValue(prefs)],
        child: const MandiKhataApp(),
      ),
    ),
  );
}

class MandiKhataApp extends ConsumerStatefulWidget {
  const MandiKhataApp({super.key});

  @override
  ConsumerState<MandiKhataApp> createState() => _MandiKhataAppState();
}

class _MandiKhataAppState extends ConsumerState<MandiKhataApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Feeds the app lock's "locked again after 2 min away" rule.
    _lifecycle = AppLifecycleListener(
      onHide: () => ref.read(appLockProvider.notifier).onBackgrounded(),
      onShow: () => ref.read(appLockProvider.notifier).onResumed(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keeps sync running (connect while signed in) for the app's lifetime.
    ref
      ..watch(syncControllerProvider)
      // Joins businesses that invited this phone number (once per sign-in).
      ..watch(inviteSyncProvider)
      // Tags error reports with the business id and device code.
      ..watch(errorReportingTagsProvider);
    final language = ref.watch(appLanguageProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Mandi Khata',
      debugShowCheckedModeBanner: false,
      theme: MkTheme.light(),
      // Dark theme is a stub; ship light only until it is designed.
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Null follows the device, falling back to English.
      locale: language == null ? null : Locale(language),
      routerConfig: router,
      builder: (context, child) => CommandPaletteShortcut(
        navigatorKey: ref.read(rootNavigatorKeyProvider),
        child: EnvRibbon(
          show: Env.isDev,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
