import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<NotificationModel>> getNotificationsByUser(int userId) async {
    final response = await _apiClient.get('/notifications/user/$userId');
    return List<Map<String, dynamic>>.from(
      response.data as List,
    ).map(NotificationModel.fromJson).toList();
  }

  Future<void> markAsRead(int id) async {
    await _apiClient.patch('/notifications/$id/read');
  }

  Future<void> deleteNotification(int id) async {
    await _apiClient.delete('/notifications/$id');
  }
}
