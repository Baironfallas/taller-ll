import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import 'session_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;
  final TokenStorage _tokenStorage = TokenStorage.instance;
  final SessionService _session = SessionService.instance;

  UserModel? get currentUser => _session.currentUser;

  Future<UserModel> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String telefono,
  }) async {
    await _apiClient.post(
      '/auth/register',
      data: {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
        'telefono': telefono,
      },
    );

    return login(email: email, password: password);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final authResponse = AuthResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );

    await _tokenStorage.saveToken(authResponse.accessToken);
    _session.setUser(authResponse.user);

    return authResponse.user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {
      // El logout local debe ejecutarse aunque el backend no responda.
    }

    await _tokenStorage.deleteToken();
    _session.clear();
  }

  Future<UserModel> getMe() async {
    final response = await _apiClient.get('/auth/me');
    final user = UserModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
    _session.setUser(user);
    return user;
  }

  Future<bool> restoreSession() async {
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) return false;

    try {
      await getMe();
      return true;
    } catch (_) {
      await _tokenStorage.deleteToken();
      _session.clear();
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      data: {'email': email, 'newPassword': newPassword},
    );
  }
}
