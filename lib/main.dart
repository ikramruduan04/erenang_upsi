import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_theme.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables first
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  // Initialize Supabase
  await Supabase.initialize(
    url:
        dotenv.env['SUPABASE_URL'] ??
        'https://wxzklwhlqnzucnhhyfij.supabase.co',
    publishableKey:
        dotenv.env['SUPABASE_KEY'] ??
        'sb_publishable_XUnK5gdRc-kEmBEf50komQ_TciqPQt9',
  );

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
      home: const AuthScreen(),
    );
  }
}
