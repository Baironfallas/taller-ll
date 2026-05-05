class NotificationPreferenceModel {
  const NotificationPreferenceModel({
    required this.id,
    required this.userId,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.pushEnabled,
    required this.reminderMinutesBefore,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool pushEnabled;
  final int reminderMinutesBefore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId:
          int.tryParse((json['userId'] ?? json['user_id'])?.toString() ?? '') ??
          0,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      reminderMinutesBefore:
          int.tryParse(json['reminderMinutesBefore']?.toString() ?? '') ?? 60,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'pushEnabled': pushEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
