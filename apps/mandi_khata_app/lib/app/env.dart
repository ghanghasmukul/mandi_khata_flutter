/// Compile-time configuration, supplied with
/// `--dart-define-from-file=.env.dev`.
///
/// Only non-secret values belong here: the app ships with whatever is baked in,
/// so the Supabase service-role key must never appear.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const powersyncUrl = String.fromEnvironment('POWERSYNC_URL');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Which backend this build targets: `dev` or `prod` (empty when built with
  /// no env file, e.g. in CI). Comes from `APP_ENV` in the env file.
  static const appEnv = String.fromEnvironment('APP_ENV');

  /// True for a build made with the dev config; shows the DEV ribbon.
  static bool get isDev => appEnv == 'dev';

  /// Whether the backend values needed to reach Supabase are present.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Whether sync can be started. PowerSync is wired up in step 0.4.
  static bool get hasPowerSync => powersyncUrl.isNotEmpty;
}
