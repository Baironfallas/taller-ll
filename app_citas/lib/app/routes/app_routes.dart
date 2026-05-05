import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/citas/screens/confirm_cita_screen.dart';
import '../../features/citas/screens/create_cita_screen.dart';
import '../../features/citas/screens/agenda_screen.dart';
import '../../features/citas/screens/home_screen.dart';
import '../../features/notificaciones/screens/notificaciones_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/';
  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String agenda = '/agenda';
  static const String crearCita = '/crear-cita';
  static const String confirmarCita = '/confirmar-cita';
  static const String profile = '/profile';
  static const String notificaciones = '/notificaciones';

  static String get initialRoute => splash;

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomeScreen(),
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      resetPassword: (context) => const ResetPasswordScreen(),
      home: (context) => HomeScreen(),
      agenda: (context) => const AgendaScreen(),
      crearCita: (context) => const CreateCitaScreen(),
      confirmarCita: (context) => const ConfirmCitaScreen(),
      profile: (context) => const ProfileScreen(),
      notificaciones: (context) => const NotificacionesScreen(),
    };
  }
}
