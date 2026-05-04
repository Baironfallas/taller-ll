import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../models/servicio.dart';

class ServicioService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<Servicio>> obtenerServicios() async {
    final response = await _client.from('servicios').select().order('nombre');
    return List<Map<String, dynamic>>.from(response)
        .map(Servicio.fromJson)
        .toList();
  }

  Future<Servicio?> obtenerServicioPorId(String id) async {
    final response = await _client
        .from('servicios')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return Servicio.fromJson(response);
  }
}
