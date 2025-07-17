import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'screens/obat_list_page.dart';
import 'screens/chatbot_page.dart';
import 'screens/obat_history_page_v00.dart';

// Constants
const String appTitle = 'Pendamping Obat';
const Color primaryColor = Colors.teal;

// Route names
class AppRoutes {
  static const login = '/login';
  static const obatList = '/obat-list';
  static const chatbot = '/chatbot';
  static const obatHistory = '/obat-history';
}

// Add this helper function
Future<void> _initializeTimeZones() async {
  tz.initializeTimeZones();
}

// Notification service initialization
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  
  try {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await Future.wait([
    _initializeTimeZones(),
    _initializeNotifications(),
  ]);

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SessionChecker(),
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.obatList: (context) => const ObatListPage(),
        AppRoutes.chatbot: (context) => const ChatbotPage(),
        AppRoutes.obatHistory: (context) => const ObatHistoryPage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}

class SessionChecker extends StatefulWidget {
  const SessionChecker({super.key});

  @override
  State<SessionChecker> createState() => _SessionCheckerState();
}

class _SessionCheckerState extends State<SessionChecker> {
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('nama');

      if (!mounted) return;

      if (nama != null && nama.trim().isNotEmpty) {
        Navigator.pushReplacementNamed(context, AppRoutes.obatList);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorOccurred = true);
      debugPrint('Session check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _errorOccurred
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat data', style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkSession,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memeriksa sesi...'),
                ],
              ),
      ),
    );
  }
}