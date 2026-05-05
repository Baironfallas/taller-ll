import '../../../services/professional_service.dart';
import '../models/profesional.dart';

class ProfesionalService {
  final ProfessionalService _professionalService = ProfessionalService();

  Future<List<Profesional>> obtenerProfesionales({String? servicioId}) async {
    final profesionales = await _professionalService.getProfessionals();
    return profesionales.map(Profesional.fromProfessionalModel).toList();
  }

  Future<Profesional?> obtenerProfesionalPorId(String id) async {
    final professionalId = int.tryParse(id);
    if (professionalId == null) return null;

    final profesional = await _professionalService.getProfessionalById(
      professionalId,
    );
    return Profesional.fromProfessionalModel(profesional);
  }

  Future<List<Profesional>> obtenerProfesionalesDisponibles({
    required String fecha,
    required String hora,
  }) async {
    final profesionales = await _professionalService.getAvailableProfessionals(
      fecha: fecha,
      hora: hora,
    );
    return profesionales.map(Profesional.fromProfessionalModel).toList();
  }
}
