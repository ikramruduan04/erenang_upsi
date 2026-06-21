import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'user/user_booking_screen.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables first
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  final supabaseUrl =
      dotenv.env['SUPABASE_URL']?.trim() ??
      'https://wxzklwhlqnzucnhhyfij.supabase.co';
  final supabaseKey =
      dotenv.env['SUPABASE_KEY']?.trim() ??
      'sb_publishable_XUnK5gdRc-kEmBEf50komQ_TciqPQt9';

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  runApp(const ERenangApp());
}

class ERenangApp extends StatelessWidget {
  const ERenangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-renangUPSI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRoleAndNavigate();
    });
  }

  Future<void> _checkRoleAndNavigate() async {
    if (DatabaseService.currentUser != null) {
      final isAdmin = await DatabaseService.isAdmin();
      if (!mounted) return;
      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserBookingScreen()),
        );
      }
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      ),
    );
  }
}
