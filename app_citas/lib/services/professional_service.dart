import '../core/network/api_client.dart';
import '../models/professional_model.dart';

class ProfessionalService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<ProfessionalModel>> getProfessionals() async {
    final response = await _apiClient.get('/professionals');
    return List<Map<String, dynamic>>.from(
      response.data as List,
    ).map(ProfessionalModel.fromJson).toList();
  }

  Future<ProfessionalModel> getProfessionalById(int id) async {
    final response = await _apiClient.get('/professionals/$id');
    return ProfessionalModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<ProfessionalModel>> getAvailableProfessionals({
    required String fecha,
    required String hora,
  }) async {
    final response = await _apiClient.get(
      '/professionals/available',
      queryParameters: {'fecha': fecha, 'hora': hora},
    );

    return List<Map<String, dynamic>>.from(
      response.data as List,
    ).map(ProfessionalModel.fromJson).toList();
  }
}
