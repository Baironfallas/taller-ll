class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.appointmentId,
    this.leida,
    this.createdAt,
  });

  final int id;
  final int userId;
  final int? appointmentId;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool? leida;
  final DateTime? createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId:
          int.tryParse((json['userId'] ?? json['user_id'])?.toString() ?? '') ??
          0,
      appointmentId: int.tryParse(json['appointmentId']?.toString() ?? ''),
      titulo: json['titulo']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      leida: json['leida'] as bool?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'appointmentId': appointmentId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'leida': leida,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
