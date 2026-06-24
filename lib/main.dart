import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/chat_provider.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

import 'screens/home/dashboard_screen.dart';
import 'screens/chat/chatbot_screen.dart';
import 'screens/chat/chat_history_screen.dart';
import 'screens/profile/profile_form_screen.dart';

/// Titik masuk utama (Entry Point) aplikasi StuntingCare.
/// 
/// Bertanggung jawab atas inisialisasi Firebase, pemuatan variabel lingkungan,
/// pendaftaran provider global, dan konfigurasi rute navigasi.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase dan Plugin
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const StuntingCareApp(),
    ),
  );
}

/// Root widget aplikasi yang mengatur tema dan sistem navigasi.
class StuntingCareApp extends StatelessWidget {
  /// Membuat instance [StuntingCareApp] baru.
  const StuntingCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StuntingCare',
      debugShowCheckedModeBanner: false,
      
      // Konfigurasi Tema Aplikasi (Modern & Cyan/Teal)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0891B2),
          primary: const Color(0xFF0891B2),
          secondary: const Color(0xFFF59E0B), // Warm Amber
          surface: Colors.white,
          error: Colors.redAccent,
        ),
        fontFamily: 'Inter', // Memerlukan konfigurasi di pubspec.yaml jika ingin eksplisit
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      // Definisi Rute Navigasi Global
      initialRoute: '/',
      routes: {
        // Rute Autentikasi
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),

        // Rute Fitur Utama
        '/dashboard': (context) => const DashboardScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/chat-history': (context) => const ChatHistoryScreen(),
        '/profile-form': (context) => const ProfileFormScreen(),
      },
    );
  }
}
