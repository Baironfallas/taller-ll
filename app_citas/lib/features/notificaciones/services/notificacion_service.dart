import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../../core/utils/app_messages.dart';
import '../models/notificacion.dart';

class NotificacionService {
  final SupabaseClient _client = SupabaseConfig.client;

  String _prefsKey(String suffix) {
    final userId = _client.auth.currentUser?.id ?? 'anon';
    return 'noti_pref_${userId}_$suffix';
  }

  Future<List<Notificacion>> obtenerMisNotificaciones() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    final response = await _client
        .from('notificaciones')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .map(Notificacion.fromJson)
        .toList();
  }

  Future<void> marcarComoLeida(String id) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    await _client
        .from('notificaciones')
        .update({'leida': true})
        .eq('id', id)
        .eq('user_id', user.id);
  }

  Future<Map<String, dynamic>> obtenerPreferencias() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'email': prefs.getBool(_prefsKey('email')) ?? true,
      'sms': prefs.getBool(_prefsKey('sms')) ?? false,
      'push': prefs.getBool(_prefsKey('push')) ?? true,
      'recordatorioMinutos': prefs.getInt(_prefsKey('recordatorio_minutos')) ?? 60,
    };
  }

  Future<void> guardarPreferencias({
    required bool email,
    required bool sms,
    required bool push,
    required int recordatorioMinutos,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_prefsKey('email'), email);
    await prefs.setBool(_prefsKey('sms'), sms);
    await prefs.setBool(_prefsKey('push'), push);
    await prefs.setInt(_prefsKey('recordatorio_minutos'), recordatorioMinutos);
  }
}
