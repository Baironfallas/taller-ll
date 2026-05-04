class HorarioProfesional {
  const HorarioProfesional({
    required this.id,
    required this.profesionalId,
    this.diaSemana,
    this.horaInicio,
    this.horaFin,
    this.activo,
  });

  final String id;
  final String profesionalId;
  final int? diaSemana;
  final String? horaInicio;
  final String? horaFin;
  final bool? activo;

  factory HorarioProfesional.fromJson(Map<String, dynamic> json) {
    return HorarioProfesional(
      id: json['id'].toString(),
      profesionalId: json['profesional_id'].toString(),
      diaSemana: json['dia_semana'] as int?,
      horaInicio: json['hora_inicio']?.toString(),
      horaFin: json['hora_fin']?.toString(),
      activo: json['activo'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profesional_id': profesionalId,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'activo': activo,
    };
  }
}
