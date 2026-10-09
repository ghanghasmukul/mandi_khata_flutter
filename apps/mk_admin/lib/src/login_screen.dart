import 'package:flutter/material.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.message});

  /// Why the previous attempt ended (for example "not a platform admin").
  final String? message;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _error = widget.message;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(MkSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: MkSidebarBrand(appName: 'Mandi Khata', compact: true),
              ),
              const SizedBox(height: MkSpacing.sm),
              Text(
                'Admin console',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: MkSpacing.xl),
              MkTextField(
                key: const ValueKey('admin-email'),
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: MkSpacing.md),
              MkTextField(
                key: const ValueKey('admin-password'),
                controller: _password,
                label: 'Password',
                obscureText: true,
                onSubmitted: (_) => _signIn(),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: MkSpacing.md),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: MkSpacing.lg),
              MkButton(
                key: const ValueKey('admin-sign-in'),
                label: 'Sign in',
                busy: _busy,
                expand: true,
                onPressed: _busy ? null : _signIn,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
