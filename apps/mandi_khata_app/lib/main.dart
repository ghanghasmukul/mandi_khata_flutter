import 'package:flutter/material.dart';
import 'package:mandi_khata_app/app/env.dart';

void main() {
  runApp(const MandiKhataApp());
}

class MandiKhataApp extends StatelessWidget {
  const MandiKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mandi Khata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2F7A56),
        scaffoldBackgroundColor: const Color(0xFFF4F2EA),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mandi Khata',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              Env.hasSupabase ? 'Configuration loaded' : 'No configuration',
              style: const TextStyle(color: Color(0xFF6A6F62)),
            ),
          ],
        ),
      ),
    );
  }
}
