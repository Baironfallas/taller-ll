class Servicio {
  const Servicio({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.precio,
    this.duracionMinutos,
    this.activo,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final num? precio;
  final int? duracionMinutos;
  final bool? activo;

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'].toString(),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion'] as String?,
      precio: json['precio'] as num?,
      duracionMinutos: json['duracion_minutos'] as int?,
      activo: json['activo'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'duracion_minutos': duracionMinutos,
      'activo': activo,
    };
  }
}
