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

  Future<void> _confirmarCita(Map<String, String> cita) async {
    setState(() => _loading = true);

    try {
      await _citaService.crearCita(
        fecha: cita['fecha']!,
        hora: cita['hora']!,
        motivo: cita['motivo']!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.citaConfirmed)),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar: $e')),
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cita = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar cita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Resumen de la cita',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Fecha'),
                  subtitle: Text(cita['fecha']!),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Hora'),
                  subtitle: Text(cita['hora']!),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Motivo'),
                  subtitle: Text(cita['motivo']!),
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
