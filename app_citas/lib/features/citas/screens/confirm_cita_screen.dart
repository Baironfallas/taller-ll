// UI REFINED — visual only
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/app_messages.dart';
import '../services/cita_service.dart';

class ConfirmCitaScreen extends StatefulWidget {
  const ConfirmCitaScreen({super.key});

  @override
  State<ConfirmCitaScreen> createState() => _ConfirmCitaScreenState();
}

class _ConfirmCitaScreenState extends State<ConfirmCitaScreen> {
  static const Color _primary = Color(0xFF004B87);
  static const Color _secondary = Color(0xFF0073B7);
  static const Color _background = Color(0xFFF0F5FA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textLight = Color(0xFF666666);
  static const Color _border = Color(0xFFD4E5F0);

  final CitaService _citaService = CitaService();
  bool _loading = false;

  Future<void> _confirmarCita(Map<String, dynamic> cita) async {
    setState(() => _loading = true);

    try {
      await _citaService.crearCita(
        fecha: cita['fecha'].toString(),
        hora: cita['hora'].toString(),
        motivo: cita['motivo'].toString(),
        profesionalId: cita['profesionalId']?.toString(),
        detalles: cita['detalles']?.toString() ?? '',
        ubicacion: cita['ubicacion']?.toString() ?? '',
        instrucciones: cita['instrucciones']?.toString() ?? '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppMessages.citaConfirmed} Revisa la ubicacion e instrucciones.',
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al confirmar: $e')));
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cita =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Confirmar cita',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A004B87),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Text(
                  'Resumen de la cita',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Fecha',
                  value: cita['fecha'].toString(),
                ),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Hora',
                  value: cita['hora'].toString(),
                ),
                _DetailRow(
                  icon: Icons.description,
                  label: 'Motivo',
                  value: cita['motivo'].toString(),
                ),
                _DetailRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Profesional',
                  value:
                      cita['profesionalNombre']?.toString() ??
                      'No especificado',
                ),
                _DetailRow(
                  icon: Icons.notes_outlined,
                  label: 'Detalles adicionales',
                  value: cita['detalles']?.toString().isNotEmpty == true
                      ? cita['detalles'].toString()
                      : 'Sin detalles adicionales',
                ),
                _DetailRow(
                  icon: Icons.place_outlined,
                  label: 'Ubicacion',
                  value: cita['ubicacion']?.toString() ?? 'Sede por confirmar',
                ),
                _DetailRow(
                  icon: Icons.info_outline,
                  label: 'Instrucciones',
                  value:
                      cita['instrucciones']?.toString() ??
                      'No hay instrucciones adicionales.',
                  showDivider: false,
                ),
                const SizedBox(height: 20),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => _confirmarCita(cita),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('Confirmar'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancelar o editar',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _ConfirmCitaScreenState._secondary, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: _ConfirmCitaScreenState._textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _ConfirmCitaScreenState._textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            color: _ConfirmCitaScreenState._border,
          ),
      ],
    );
  }
}
