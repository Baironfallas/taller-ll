import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<void> recuperarContrasena(String email) async {
    final redirectTo = kIsWeb
        ? '${Uri.base.origin}/#/reset-password'
        : 'appcitas://reset-password';

    await _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  Future<UserResponse> actualizarCredenciales({
    String? email,
    String? password,
  }) async {
    return await _client.auth.updateUser(
      UserAttributes(email: email, password: password),
    );
  }

  User? get currentUser => _client.auth.currentUser;
}
