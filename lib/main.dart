import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobgenfest/faq_screen.dart';
import 'package:mobgenfest/home_screen.dart';
import 'package:mobgenfest/admin_dashboard.dart';
import 'package:mobgenfest/registration_success_screen.dart';
import 'package:mobgenfest/legal_screen.dart';
import 'package:mobgenfest/ticket_form_screen.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hfpyimdevvjofjhvzhev.supabase.co',
    anonKey: 'sb_publishable_7VGFhOeIXi9VzfZqfKYr_Q_uh_lG_Xo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobgen Fest 2026',
      routes: {
        '/faq': (context) => const FAQScreen(),
        '/org': (context) => const AdminDashboard(),
        '/success': (context) => const RegistrationSuccessScreen(),
        '/privacy': (context) => const LegalScreen(showPrivacy: true),
        '/terms': (context) => const LegalScreen(showPrivacy: false),
        '/registro': (context) {
          final settings = ModalRoute.of(context)!.settings;
          final args = settings.arguments as Map<String, String>?;

          // Try to get from arguments first (internal navigation)
          String? type = args?['type'];
          String? price = args?['price'];

          // If not found and on web, try query parameters (after external redirect)
          if (kIsWeb && type == null) {
            type = Uri.base.queryParameters['type'];
            price = Uri.base.queryParameters['price'];
          }

          return TicketFormScreen(
            initialTicketType: type ?? 'GENERAL PASS',
            ticketPrice: price ?? '65€',
          );
        },
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFFFF6600),
        fontFamily: 'Lab',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6600),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            elevation: 8,
            shadowColor: const Color(0xFFFF6600).withOpacity(0.5),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0),
          displayMedium: TextStyle(
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
          titleLarge: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
          bodyLarge: TextStyle(
              color: Colors.white70, fontSize: 20, letterSpacing: 0.5),
          bodyMedium: TextStyle(
              color: Colors.white60, fontSize: 18, letterSpacing: 0.5),
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFFF6600),
          primary: const Color(0xFFFF6600),
          onPrimary: Colors.white,
          secondary: const Color(0xFFFFCC00),
          background: const Color(0xFF0A0A0A),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
