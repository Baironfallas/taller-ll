class UserModel {
  const UserModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.rol,
    this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String rol;
  final bool? activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get nombreCompleto {
    final fullName = '$nombre $apellido'.trim();
    return fullName.isEmpty ? email : fullName;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      rol: json['rol']?.toString() ?? 'USER',
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
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'activo': activo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
