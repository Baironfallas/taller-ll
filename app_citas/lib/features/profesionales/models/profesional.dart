class Profesional {
  const Profesional({
    required this.id,
    required this.nombre,
    this.profileId,
    this.servicioId,
    this.especialidad,
    this.activo,
  });

  final String id;
  final String nombre;
  final String? profileId;
  final String? servicioId;
  final String? especialidad;
  final bool? activo;

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: json['id'].toString(),
      nombre: json['nombre']?.toString() ?? '',
      profileId: json['profile_id']?.toString(),
      servicioId: json['servicio_id']?.toString(),
      especialidad: json['especialidad'] as String?,
      activo: json['activo'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'profile_id': profileId,
      'servicio_id': servicioId,
      'especialidad': especialidad,
      'activo': activo,
    };
  }
}
