import 'professional_model.dart';
import 'user_model.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.userId,
    required this.professionalId,
    required this.fecha,
    required this.hora,
    required this.motivo,
    required this.detalles,
    required this.estado,
    required this.ubicacion,
    required this.instrucciones,
    this.professional,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final int professionalId;
  final String fecha;
  final String hora;
  final String motivo;
  final String detalles;
  final String estado;
  final String ubicacion;
  final String instrucciones;
  final ProfessionalModel? professional;
  final UserModel? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId:
          int.tryParse((json['userId'] ?? json['user_id'])?.toString() ?? '') ??
          0,
      professionalId:
          int.tryParse(
            (json['professionalId'] ?? json['profesional_id'])?.toString() ??
                '',
          ) ??
          0,
      fecha: json['fecha']?.toString() ?? '',
      hora: json['hora']?.toString() ?? '',
      motivo: json['motivo']?.toString() ?? '',
      detalles: json['detalles']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'pendiente',
      ubicacion: json['ubicacion']?.toString() ?? '',
      instrucciones: json['instrucciones']?.toString() ?? '',
      professional: json['professional'] is Map
          ? ProfessionalModel.fromJson(
              Map<String, dynamic>.from(json['professional'] as Map),
            )
          : null,
      user: json['user'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'professionalId': professionalId,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
      'detalles': detalles,
      'estado': estado,
      'ubicacion': ubicacion,
      'instrucciones': instrucciones,
      'professional': professional?.toJson(),
      'user': user?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'user_id': userId,
      'professionalId': professionalId,
      'profesional_id': professionalId,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
      'detalles': detalles,
      'estado': _estadoParaUi(estado),
      'ubicacion': ubicacion,
      'instrucciones': instrucciones,
      'professional': professional?.toJson(),
      'user': user?.toJson(),
    };
  }

  String _estadoParaUi(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
      case 'PENDIENTE':
        return 'pendiente';
      case 'CONFIRMED':
      case 'CONFIRMADA':
      case 'CONFIRMADO':
        return 'confirmada';
      case 'CANCELLED':
      case 'CANCELED':
      case 'CANCELADA':
      case 'CANCELADO':
        return 'cancelada';
      default:
        return value.toLowerCase();
    }
  }
}
