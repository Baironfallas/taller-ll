import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../models/profesional.dart';

class ProfesionalService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<Profesional>> obtenerProfesionales({String? servicioId}) async {
    var query = _client.from('profesionales').select();

    if (servicioId != null && servicioId.isNotEmpty) {
      query = query.eq('servicio_id', servicioId);
    }

    final response = await query.order('nombre');

    return List<Map<String, dynamic>>.from(response)
        .map(Profesional.fromJson)
        .toList();
  }

  Future<Profesional?> obtenerProfesionalPorId(String id) async {
    final response = await _client
        .from('profesionales')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return Profesional.fromJson(response);
  }
}
