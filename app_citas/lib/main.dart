import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_cita_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/confirm_cita_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zqwjrojzhpiqocaelbbk.supabase.co',
    anonKey: 'sb_publishable_3Ci8o3ZQKpZ33yz6Zp3dMw_OnU6i5W_',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: session == null ? '/' : '/home',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/confirmar-cita': (context) => const ConfirmCitaScreen(),
        '/crear-cita': (context) => const CreateCitaScreen(),
      },
    );
  }
}