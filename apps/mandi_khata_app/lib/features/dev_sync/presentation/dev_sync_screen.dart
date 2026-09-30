// Developer-only screen (not registered in release builds) for testing
// offline writes and sync before the real login (0.5) and parties screen
// (0.8) exist. Text is not localised on purpose; see docs/decisions.md.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/features/dev_sync/presentation/dev_sync_panels.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DevSyncScreen extends ConsumerWidget {
  const DevSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: 'Sync lab',
            subtitle: 'Dev only · offline writes and PowerSync',
            actions: [
              const SyncStatusChip(),
              IconButton(
                tooltip: 'Home',
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home_outlined),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(MkSpacing.xl),
              children: [
                if (!syncConfigured) const _ConfigWarning(),
                if (Env.hasSupabase) const AccountPanel(),
                const SizedBox(height: MkSpacing.lg),
                const SyncControlsPanel(),
                const SizedBox(height: MkSpacing.lg),
                const LocalDataPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigWarning extends StatelessWidget {
  const _ConfigWarning();

  @override
  Widget build(BuildContext context) {
    final missing = [
      if (!Env.hasSupabase) 'SUPABASE_URL / SUPABASE_ANON_KEY',
      if (!Env.hasPowerSync) 'POWERSYNC_URL',
    ].join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: MkSpacing.lg),
      child: MkCard(
        child: Text(
          'Sync is off: $missing missing from .env.dev. Local writes still '
          'work and will upload once it is configured.',
        ),
      ),
    );
  }
}

/// Email/password sign-in for testing only; the real login is step 0.5.
class AccountPanel extends StatefulWidget {
  const AccountPanel({super.key});

  @override
  State<AccountPanel> createState() => _AccountPanelState();
}

class _AccountPanelState extends State<AccountPanel> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  GoTrueClient get _auth => Supabase.instance.client.auth;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) MkToast.show(context, e.message, tone: MkToastTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _auth.onAuthStateChange,
      builder: (context, _) {
        final user = _auth.currentUser;
        return MkCard(
          title: 'Account',
          child: user != null
              ? Row(
                  children: [
                    Expanded(
                      child: Text('Signed in: ${user.email ?? user.id}'),
                    ),
                    MkButton(
                      label: 'Sign out',
                      variant: MkButtonVariant.secondary,
                      busy: _busy,
                      onPressed: () => _run(_auth.signOut),
                    ),
                  ],
                )
              : Wrap(
                  spacing: MkSpacing.md,
                  runSpacing: MkSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    SizedBox(
                      width: 240,
                      child: MkTextField(label: 'Email', controller: _email),
                    ),
                    SizedBox(
                      width: 200,
                      child: MkTextField(
                        label: 'Password',
                        controller: _password,
                        obscureText: true,
                      ),
                    ),
                    MkButton(
                      label: 'Sign in',
                      busy: _busy,
                      onPressed: () => _run(
                        () => _auth.signInWithPassword(
                          email: _email.text.trim(),
                          password: _password.text,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
