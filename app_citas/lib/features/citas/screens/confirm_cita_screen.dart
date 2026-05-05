import 'package:flutter/material.dart';

import '../../../core/utils/app_messages.dart';
import '../services/cita_service.dart';

class ConfirmCitaScreen extends StatefulWidget {
  const ConfirmCitaScreen({super.key});

  @override
  State<ConfirmCitaScreen> createState() => _ConfirmCitaScreenState();
}

class _ConfirmCitaScreenState extends State<ConfirmCitaScreen> {
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
      appBar: AppBar(title: const Text('Confirmar cita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  'Resumen de la cita',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Fecha'),
                  subtitle: Text(cita['fecha'].toString()),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Hora'),
                  subtitle: Text(cita['hora'].toString()),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Motivo'),
                  subtitle: Text(cita['motivo'].toString()),
                ),
                ListTile(
                  leading: const Icon(Icons.medical_services_outlined),
                  title: const Text('Profesional'),
                  subtitle: Text(
                    cita['profesionalNombre']?.toString() ?? 'No especificado',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notes_outlined),
                  title: const Text('Detalles adicionales'),
                  subtitle: Text(
                    cita['detalles']?.toString().isNotEmpty == true
                        ? cita['detalles'].toString()
                        : 'Sin detalles adicionales',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: const Text('Ubicacion'),
                  subtitle: Text(
                    cita['ubicacion']?.toString() ?? 'Sede por confirmar',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Instrucciones'),
                  subtitle: Text(
                    cita['instrucciones']?.toString() ??
                        'No hay instrucciones adicionales.',
                  ),
                ),
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator()
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _confirmarCita(cita),
                              child: const Text('Confirmar'),
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
