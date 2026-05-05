import '../../../core/utils/app_messages.dart';
import '../../../services/auth_service.dart';
import '../../../services/session_service.dart';
import '../../../services/user_service.dart';
import '../models/profile.dart';

class ProfileService {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final SessionService _sessionService = SessionService.instance;

  Future<Profile?> obtenerMiPerfil() async {
    final user = await _authService.getMe();
    return Profile.fromJson(user.toJson());
  }

  Future<void> actualizarMiPerfil({
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
  }) async {
    final userId = _sessionService.currentUserId;
    if (userId == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    final updated = await _userService.updateProfile(
      id: userId,
      nombre: nombre,
      apellido: apellido,
      email: email,
      telefono: telefono,
    );
    _sessionService.setUser(updated);
  }

  Future<void> cambiarContrasena({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = _sessionService.currentUserId;
    if (userId == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }

    await _userService.changePassword(
      id: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
