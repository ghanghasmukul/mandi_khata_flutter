import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mk_ui/mk_ui.dart';

void main() {
  runApp(const MandiKhataApp());
}

class MandiKhataApp extends StatefulWidget {
  const MandiKhataApp({super.key});

  @override
  State<MandiKhataApp> createState() => _MandiKhataAppState();
}

class _MandiKhataAppState extends State<MandiKhataApp> {
  final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mandi Khata',
      debugShowCheckedModeBanner: false,
      theme: MkTheme.light(),
      // Dark theme is a stub; ship light only until it is designed.
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}
