import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../../core/utils/app_messages.dart';
import '../models/notificacion.dart';

class NotificacionService {
  final SupabaseClient _client = SupabaseConfig.client;

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
}
