import 'package:flutter/foundation.dart';

class ApiConstants {
  // Para navegador o escritorio: http://localhost:3000
  // Para emulador Android: http://10.0.2.2:3000
  // Para celular fisico: http://IP_LOCAL_DE_LA_PC:3000
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      // Android: 10.0.2.2 es la dirección del host desde emulador
      // iOS: localhost para simulador
      // Desktop: localhost
      return 'http://10.0.2.2:3000';
    }
  }
}
