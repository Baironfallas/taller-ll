import '../core/network/api_client.dart';
import '../models/notification_preference_model.dart';

class NotificationPreferenceService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<NotificationPreferenceModel> createPreference({
    required int userId,
    required bool emailEnabled,
    required bool smsEnabled,
    required bool pushEnabled,
    required int reminderMinutesBefore,
  }) async {
    final response = await _apiClient.post(
      '/notification-preferences',
      data: {
        'userId': userId,
        'emailEnabled': emailEnabled,
        'smsEnabled': smsEnabled,
        'pushEnabled': pushEnabled,
        'reminderMinutesBefore': reminderMinutesBefore,
      },
    );
    return NotificationPreferenceModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<NotificationPreferenceModel?> getPreferenceByUser(int userId) async {
    final response = await _apiClient.get(
      '/notification-preferences/user/$userId',
    );
    if (response.data == null) return null;
    return NotificationPreferenceModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<NotificationPreferenceModel> updatePreference({
    required int id,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? pushEnabled,
    int? reminderMinutesBefore,
  }) async {
    final data = <String, dynamic>{
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'pushEnabled': pushEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
    data.removeWhere((_, v) => v == null);

    final response = await _apiClient.patch(
      '/notification-preferences/$id',
      data: data,
    );
    return NotificationPreferenceModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
