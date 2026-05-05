class Notificacion {
  const Notificacion({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.mensaje,
    this.leida,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String titulo;
  final String mensaje;
  final bool? leida;
  final DateTime? createdAt;

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'].toString(),
      userId: (json['userId'] ?? json['user_id']).toString(),
      titulo: json['titulo']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
      leida: json['leida'] as bool?,
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'titulo': titulo,
      'mensaje': mensaje,
      'leida': leida,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
