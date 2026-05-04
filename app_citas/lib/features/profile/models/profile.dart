class Profile {
  const Profile({
    required this.id,
    this.email,
    this.nombre,
    this.telefono,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? email;
  final String? nombre;
  final String? telefono;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String?,
      nombre: json['nombre'] as String?,
      telefono: json['telefono'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
