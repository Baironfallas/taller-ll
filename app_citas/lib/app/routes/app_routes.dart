import 'package:flutter/material.dart';

import '../../core/supabase/supabase_config.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/citas/screens/confirm_cita_screen.dart';
import '../../features/citas/screens/create_cita_screen.dart';
import '../../features/citas/screens/agenda_screen.dart';
import '../../features/citas/screens/home_screen.dart';
import '../../features/notificaciones/screens/notificaciones_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String agenda = '/agenda';
  static const String crearCita = '/crear-cita';
  static const String confirmarCita = '/confirmar-cita';
  static const String profile = '/profile';
  static const String notificaciones = '/notificaciones';

  static String get initialRoute {
    final session = SupabaseConfig.client.auth.currentSession;
    return session == null ? welcome : home;
  }

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => HomeScreen(),
      agenda: (context) => const AgendaScreen(),
      crearCita: (context) => const CreateCitaScreen(),
      confirmarCita: (context) => const ConfirmCitaScreen(),
      profile: (context) => const ProfileScreen(),
      notificaciones: (context) => const NotificacionesScreen(),
    };
  }
}
