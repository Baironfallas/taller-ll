class ProfessionalModel {
  const ProfessionalModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.especialidad,
    required this.descripcion,
    required this.email,
    required this.telefono,
    this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String nombre;
  final String apellido;
  final String especialidad;
  final String descripcion;
  final String email;
  final String telefono;
  final bool? activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      especialidad: json['especialidad']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      activo: json['activo'] as bool?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'especialidad': especialidad,
      'descripcion': descripcion,
      'email': email,
      'telefono': telefono,
      'activo': activo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
