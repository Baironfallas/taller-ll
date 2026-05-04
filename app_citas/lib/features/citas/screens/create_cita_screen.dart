import 'package:flutter/material.dart';

import '../../../core/utils/app_messages.dart';
import '../services/cita_service.dart';

class CreateCitaScreen extends StatefulWidget {
  const CreateCitaScreen({super.key});

  @override
  State<CreateCitaScreen> createState() => _CreateCitaScreenState();
}

class _CreateCitaScreenState extends State<CreateCitaScreen> {
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _motivoController = TextEditingController();

  final CitaService _citaService = CitaService();

  bool _loading = false;

  Future<void> _crearCita() async {
    setState(() => _loading = true);

    try {
      await _citaService.crearCita(
        fecha: _fechaController.text.trim(),
        hora: _horaController.text.trim(),
        motivo: _motivoController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.citaCreated)),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Cita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _fechaController,
              decoration: const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _horaController,
              decoration: const InputDecoration(labelText: 'Hora'),
            ),
            TextField(
              controller: _motivoController,
              decoration: const InputDecoration(labelText: 'Motivo'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/confirmar-cita',
                        arguments: {
                          'fecha': _fechaController.text.trim(),
                          'hora': _horaController.text.trim(),
                          'motivo': _motivoController.text.trim(),
                        },
                      );
                    },
                    child: const Text('Guardar cita'),
                  ),
          ],
        ),
      ),
    );
  }
}
