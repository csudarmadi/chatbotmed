import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'screens/obat_list_page.dart';
import 'screens/chatbot_page.dart';
import 'screens/obat_history_page.dart';

// Add notification initialization
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezones
  tz.initializeTimeZones();
  
  // Configure notification plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

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
        '/chatbot': (context) => const ChatbotPage(),
        '/obat-history': (context) => const ObatHistoryPage(),
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