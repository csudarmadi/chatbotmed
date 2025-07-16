import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_page.dart';
import 'screens/obat_list_page.dart';
import 'screens/chatbot_page.dart';
import 'screens/obat_history_page.dart';
import 'services/reminder_service.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // ⬅️ Tambahkan baris ini
  await ReminderService.initialize(); // Just this
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFDEFDE0), // 🌱 background soft green
        primaryColor: const Color(0xFFA8D5BA), // 🌿 pastel green
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFA8D5BA),   // 🌿 pastel green
          secondary: const Color(0xFFB9FBC0), // 🍃 mint green
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF388E3C), // 🌿 pastel green
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA8D5BA),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
      //await prefs.clear();
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