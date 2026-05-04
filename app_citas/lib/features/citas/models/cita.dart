class Cita {
  const Cita({
    required this.id,
    required this.userId,
    required this.fecha,
    required this.hora,
    this.motivo,
    this.estado,
    this.servicioId,
    this.profesionalId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String fecha;
  final String hora;
  final String? motivo;
  final String? estado;
  final String? servicioId;
  final String? profesionalId;
  final DateTime? createdAt;

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      fecha: json['fecha'].toString(),
      hora: json['hora'].toString(),
      motivo: json['motivo'] as String?,
      estado: json['estado'] as String?,
      servicioId: json['servicio_id']?.toString(),
      profesionalId: json['profesional_id']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
      'estado': estado,
      'servicio_id': servicioId,
      'profesional_id': profesionalId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
