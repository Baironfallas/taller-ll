import '../../../models/professional_model.dart';

class Profesional {
  const Profesional({
    required this.id,
    required this.nombre,
    this.profileId,
    this.servicioId,
    this.especialidad,
    this.apellido,
    this.email,
    this.telefono,
    this.descripcion,
    this.activo,
  });

  final String id;
  final String nombre;
  final String? profileId;
  final String? servicioId;
  final String? especialidad;
  final String? apellido;
  final String? email;
  final String? telefono;
  final String? descripcion;
  final bool? activo;

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: json['id'].toString(),
      nombre: json['nombre']?.toString() ?? '',
      profileId: json['profile_id']?.toString(),
      servicioId: json['servicio_id']?.toString(),
      especialidad: json['especialidad'] as String?,
      apellido: json['apellido']?.toString(),
      email: json['email']?.toString(),
      telefono: json['telefono']?.toString(),
      descripcion: json['descripcion']?.toString(),
      activo: json['activo'] as bool?,
    );
  }

  factory Profesional.fromProfessionalModel(ProfessionalModel model) {
    return Profesional(
      id: model.id.toString(),
      nombre: model.nombreCompleto.isEmpty
          ? model.nombre
          : model.nombreCompleto,
      apellido: model.apellido,
      especialidad: model.especialidad,
      email: model.email,
      telefono: model.telefono,
      descripcion: model.descripcion,
      activo: model.activo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'profile_id': profileId,
      'servicio_id': servicioId,
      'especialidad': especialidad,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
