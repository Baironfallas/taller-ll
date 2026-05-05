import '../../../core/utils/app_messages.dart';
import '../../../models/notification_preference_model.dart';
import '../../../services/notification_preference_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/session_service.dart';
import '../models/notificacion.dart';

class NotificacionService {
  final NotificationService _notificationService = NotificationService();
  final NotificationPreferenceService _preferenceService =
      NotificationPreferenceService();
  final SessionService _sessionService = SessionService.instance;

  int get _currentUserId {
    final userId = _sessionService.currentUserId;
    if (userId == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }
    return userId;
  }

  NotificationPreferenceModel? _preference;

  Future<List<Notificacion>> obtenerMisNotificaciones() async {
    final notifications = await _notificationService.getNotificationsByUser(
      _currentUserId,
    );
    return notifications
        .map((notification) => Notificacion.fromJson(notification.toJson()))
        .toList();
  }

  Future<void> marcarComoLeida(String id) async {
    final notificationId = int.tryParse(id);
    if (notificationId == null) throw Exception('Id de notificacion invalido.');
    await _notificationService.markAsRead(notificationId);
  }

  Future<Map<String, dynamic>> obtenerPreferencias() async {
    try {
      _preference = await _preferenceService.getPreferenceByUser(
        _currentUserId,
      );
    } catch (_) {
      _preference = null;
    }

    final preference = _preference;
    return {
      'email': preference?.emailEnabled ?? true,
      'sms': preference?.smsEnabled ?? false,
      'push': preference?.pushEnabled ?? true,
      'recordatorioMinutos': preference?.reminderMinutesBefore ?? 60,
    };
  }

  Future<void> guardarPreferencias({
    required bool email,
    required bool sms,
    required bool push,
    required int recordatorioMinutos,
  }) async {
    final preference = _preference;

    if (preference == null || preference.id == 0) {
      _preference = await _preferenceService.createPreference(
        userId: _currentUserId,
        emailEnabled: email,
        smsEnabled: sms,
        pushEnabled: push,
        reminderMinutesBefore: recordatorioMinutos,
      );
      return;
    }

    _preference = await _preferenceService.updatePreference(
      id: preference.id,
      emailEnabled: email,
      smsEnabled: sms,
      pushEnabled: push,
      reminderMinutesBefore: recordatorioMinutos,
    );
  }
}
