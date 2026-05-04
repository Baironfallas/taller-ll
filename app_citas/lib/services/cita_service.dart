import 'package:supabase_flutter/supabase_flutter.dart';

class CitaService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> crearCita({
    required String fecha,
    required String hora,
    required String motivo,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    await _client.from('citas').insert({
      'user_id': user.id,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
    });
  }

  Future<List<Map<String, dynamic>>> obtenerMisCitas() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client
        .from('citas')
        .select()
        .eq('user_id', user.id)
        .order('fecha', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> eliminarCita(String id) async {
    await _client.from('citas').delete().eq('id', id);
  }
}