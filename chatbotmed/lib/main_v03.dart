// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'screens/obat_list_page.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pendamping Obat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SessionChecker(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/obat-list': (context) => const ObatListPage(),
      },
    );
  }
}

class SessionChecker extends StatefulWidget {
  const SessionChecker({super.key});

  @override
  State<SessionChecker> createState() => _SessionCheckerState();
}

class _SessionCheckerState extends State<SessionChecker> {
  @override
  void initState() {
    super.initState();
    _checkNama();
  }

  Future<void> _checkNama() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('nama');

    if (!mounted) return;

    if (nama != null && nama.trim().isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/obat-list');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}