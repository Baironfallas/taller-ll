import '../../../core/utils/app_messages.dart';
import '../../../services/appointment_service.dart';
import '../../../services/session_service.dart';
import '../models/cita.dart';

class CitaService {
  final AppointmentService _appointmentService = AppointmentService();
  final SessionService _sessionService = SessionService.instance;

  int get _currentUserId {
    final userId = _sessionService.currentUserId;
    if (userId == null) {
      throw Exception(AppMessages.unauthenticatedUser);
    }
    return userId;
  }

  Future<void> crearCita({
    required String fecha,
    required String hora,
    required String motivo,
    String? profesionalId,
    String? servicioId,
    String? detalles,
    String? ubicacion,
    String? instrucciones,
  }) async {
    final professionalId = int.tryParse(profesionalId ?? '');
    if (professionalId == null) {
      throw Exception('Selecciona un profesional valido.');
    }

    await _appointmentService.createAppointment(
      userId: _currentUserId,
      professionalId: professionalId,
      fecha: fecha,
      hora: _normalizeHora(hora),
      motivo: motivo,
      detalles: detalles ?? '',
      ubicacion: ubicacion ?? '',
      instrucciones: instrucciones ?? '',
    );
  }

  Future<List<Map<String, dynamic>>> obtenerMisCitas() async {
    final citas = await _appointmentService.getAppointmentsByUser(
      _currentUserId,
    );
    return citas.map((cita) => cita.toLegacyMap()).toList();
  }

  Future<List<Cita>> obtenerMisCitasModel() async {
    final rows = await obtenerMisCitas();
    return rows.map(Cita.fromJson).toList();
  }

  Future<void> eliminarCita(String id) async {
    final citaId = int.tryParse(id);
    if (citaId == null) throw Exception('Id de cita invalido.');
    await _appointmentService.deleteAppointment(citaId);
  }

  Future<void> actualizarCita({
    required String id,
    required String fecha,
    required String hora,
    required String motivo,
    String? profesionalId,
    String? servicioId,
    String? estado,
    String? detalles,
    String? ubicacion,
    String? instrucciones,
  }) async {
    final citaId = int.tryParse(id);
    if (citaId == null) throw Exception('Id de cita invalido.');

    await _appointmentService.updateAppointment(
      id: citaId,
      fecha: fecha,
      hora: _normalizeHora(hora),
      motivo: motivo,
      professionalId: int.tryParse(profesionalId ?? ''),
      estado: estado,
      detalles: detalles,
      ubicacion: ubicacion,
      instrucciones: instrucciones,
    );
  }

  Future<void> confirmarCita(String id) async {
    final citaId = int.tryParse(id);
    if (citaId == null) throw Exception('Id de cita invalido.');
    await _appointmentService.confirmAppointment(citaId);
  }

  Future<void> cancelarCita(String id) async {
    final citaId = int.tryParse(id);
    if (citaId == null) throw Exception('Id de cita invalido.');
    await _appointmentService.cancelAppointment(citaId);
  }

  String _normalizeHora(String value) {
    final parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return value;
  }
}
