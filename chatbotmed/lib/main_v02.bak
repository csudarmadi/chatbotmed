// lib/main.dart
import 'package:flutter/material.dart';
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
      home: const LoginPage(),
      routes: {
        '/obat-list': (context) => const ObatListPage(),
      },
    );
  }
}
