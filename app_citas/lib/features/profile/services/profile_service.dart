import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../../core/utils/app_messages.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<Profile?> obtenerMiPerfil() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return Profile.fromJson(response);
  }

  Future<void> actualizarMiPerfil({
    String? nombre,
    String? telefono,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'nombre': nombre,
      'telefono': telefono,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
