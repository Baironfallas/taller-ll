import '../core/network/api_client.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<AppointmentModel> createAppointment({
    required int userId,
    required int professionalId,
    required String fecha,
    required String hora,
    required String motivo,
    required String detalles,
    required String ubicacion,
    required String instrucciones,
  }) async {
    final response = await _apiClient.post(
      '/appointments',
      data: {
        'userId': userId,
        'professionalId': professionalId,
        'fecha': fecha,
        'hora': hora,
        'motivo': motivo,
        'detalles': detalles,
        'ubicacion': ubicacion,
        'instrucciones': instrucciones,
      },
    );

    return AppointmentModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<AppointmentModel>> getAppointments() async {
    final response = await _apiClient.get('/appointments');
    return List<Map<String, dynamic>>.from(
      response.data as List,
    ).map(AppointmentModel.fromJson).toList();
  }

  Future<AppointmentModel> getAppointmentById(int id) async {
    final response = await _apiClient.get('/appointments/$id');
    return AppointmentModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<AppointmentModel>> getAppointmentsByUser(int userId) async {
    final response = await _apiClient.get('/appointments/user/$userId');
    return List<Map<String, dynamic>>.from(
      response.data as List,
    ).map(AppointmentModel.fromJson).toList();
  }

  Future<List<AppointmentModel>> getAppointmentsByProfessional(
    int professionalId,
  ) async {
    final response = await _apiClient.get(
      '/appointments/professional/$professionalId',
    );
    return List<Map<String, dynamic>>.from(
      response.data as List,
    ).map(AppointmentModel.fromJson).toList();
  }

  Future<AppointmentModel> updateAppointment({
    required int id,
    String? fecha,
    String? hora,
    String? motivo,
    String? detalles,
    String? ubicacion,
    String? instrucciones,
    int? professionalId,
    String? estado,
  }) async {
    final data = <String, dynamic>{
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
      'detalles': detalles,
      'ubicacion': ubicacion,
      'instrucciones': instrucciones,
      'professionalId': professionalId,
    };
    data.removeWhere((_, v) => v == null);

    final response = await _apiClient.patch('/appointments/$id', data: data);
    return AppointmentModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AppointmentModel> confirmAppointment(int id) async {
    final response = await _apiClient.patch('/appointments/$id/confirm');
    return AppointmentModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AppointmentModel> cancelAppointment(int id) async {
    final response = await _apiClient.patch('/appointments/$id/cancel');
    return AppointmentModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> deleteAppointment(int id) async {
    await _apiClient.delete('/appointments/$id');
  }
}
