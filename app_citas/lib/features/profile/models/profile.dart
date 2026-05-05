class Profile {
  const Profile({
    required this.id,
    this.email,
    this.nombre,
    this.apellido,
    this.telefono,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? email;
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'].toString(),
      email: json['email'] as String?,
      nombre: json['nombre'] as String?,
      apellido: json['apellido'] as String?,
      telefono: json['telefono'] as String?,
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
      ),
      updatedAt: DateTime.tryParse(
        (json['updatedAt'] ?? json['updated_at'])?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
