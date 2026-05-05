import '../core/network/api_client.dart';
import '../models/user_model.dart';

class UserService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<UserModel>> getUsers() async {
    final response = await _apiClient.get('/users');
    return List<Map<String, dynamic>>.from(
      response.data as List,
    ).map(UserModel.fromJson).toList();
  }

  Future<UserModel> getUserById(int id) async {
    final response = await _apiClient.get('/users/$id');
    return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<UserModel> updateProfile({
    required int id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
  }) async {
    final data = <String, dynamic>{
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
    };
    data.removeWhere((_, v) => v == null);

    final response = await _apiClient.patch('/users/$id', data: data);
    return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> changePassword({
    required int id,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.patch(
      '/users/$id/password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<void> deactivateUser(int id) async {
    await _apiClient.patch('/users/$id/deactivate');
  }
}
