import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../models/horario_profesional.dart';

class HorarioProfesionalService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<HorarioProfesional>> obtenerHorariosPorProfesional(
    String profesionalId,
  ) async {
    final response = await _client
        .from('horarios_profesional')
        .select()
        .eq('profesional_id', profesionalId)
        .order('dia_semana')
        .order('hora_inicio');

    return List<Map<String, dynamic>>.from(response)
        .map(HorarioProfesional.fromJson)
        .toList();
  }
}
