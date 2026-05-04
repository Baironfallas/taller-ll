import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../../core/utils/app_messages.dart';
import '../models/cita.dart';

class CitaService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<void> crearCita({
    required String fecha,
    required String hora,
    required String motivo,
    String? profesionalId,
    String? servicioId,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    final payload = <String, dynamic>{
      'user_id': user.id,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
      if (profesionalId != null && profesionalId.isNotEmpty)
        'profesional_id': profesionalId,
      if (servicioId != null && servicioId.isNotEmpty) 'servicio_id': servicioId,
      'estado': 'pendiente',
    };

    await _client.from('citas').insert(payload);
  }

  Future<List<Map<String, dynamic>>> obtenerMisCitas() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    final response = await _client
        .from('citas')
        .select()
        .eq('user_id', user.id)
      .order('fecha', ascending: true)
      .order('hora', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Cita>> obtenerMisCitasModel() async {
    final rows = await obtenerMisCitas();
    return rows.map(Cita.fromJson).toList();
  }

  Future<void> eliminarCita(String id) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    await _client.from('citas').delete().eq('id', id).eq('user_id', user.id);
  }

  Future<void> actualizarCita({
    required String id,
    required String fecha,
    required String hora,
    required String motivo,
    String? profesionalId,
    String? servicioId,
    String? estado,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    final payload = <String, dynamic>{
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
      if (profesionalId != null && profesionalId.isNotEmpty)
        'profesional_id': profesionalId,
      if (servicioId != null && servicioId.isNotEmpty) 'servicio_id': servicioId,
      if (estado != null && estado.isNotEmpty) 'estado': estado,
    };

    await _client
        .from('citas')
        .update(payload)
        .eq('id', id)
        .eq('user_id', user.id);
  }
}
