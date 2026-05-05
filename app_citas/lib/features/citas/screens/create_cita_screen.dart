import 'package:flutter/material.dart';

import '../../profesionales/models/profesional.dart';
import '../../profesionales/services/profesional_service.dart';

class CreateCitaScreen extends StatefulWidget {
  const CreateCitaScreen({super.key});

  @override
  State<CreateCitaScreen> createState() => _CreateCitaScreenState();
}

class _CreateCitaScreenState extends State<CreateCitaScreen> {
  final _motivoController = TextEditingController();
  final _detallesController = TextEditingController();

  final ProfesionalService _profesionalService = ProfesionalService();

  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 9, minute: 0);
  bool _loadingProfesionales = true;
  bool _loading = false;

  List<Profesional> _profesionalesDisponibles = [];
  Profesional? _profesionalSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarProfesionalesDisponibles();
  }

  Future<void> _cargarProfesionalesDisponibles() async {
    try {
      setState(() => _loadingProfesionales = true);

      final disponibles = await _profesionalService
          .obtenerProfesionalesDisponibles(
            fecha: _formatFecha(_fechaSeleccionada),
            hora: _formatHora(_horaSeleccionada),
          );

      if (!mounted) return;

      setState(() {
        _profesionalesDisponibles = disponibles;
        if (_profesionalSeleccionado != null &&
            !_profesionalesDisponibles.any(
              (p) => p.id == _profesionalSeleccionado!.id,
            )) {
          _profesionalSeleccionado = null;
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _profesionalesDisponibles = [];
        _profesionalSeleccionado = null;
      });
    }

    if (!mounted) return;
    setState(() => _loadingProfesionales = false);
  }

  String _formatFecha(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatHora(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _continuarAConfirmacion() async {
    if (_motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes escribir el motivo de la cita.')),
      );
      return;
    }

    if (_profesionalSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un profesional disponible.')),
      );
      return;
    }

    setState(() => _loading = true);

    await Navigator.pushNamed(
      context,
      '/confirmar-cita',
      arguments: {
        'fecha': _formatFecha(_fechaSeleccionada),
        'hora': _formatHora(_horaSeleccionada),
        'motivo': _motivoController.text.trim(),
        'detalles': _detallesController.text.trim(),
        'profesionalId': _profesionalSeleccionado!.id,
        'profesionalNombre': _profesionalSeleccionado!.nombre,
        'ubicacion': 'Sede principal, consultorio 203',
        'instrucciones': 'Llegar 10 minutos antes con documento de identidad.',
      },
    );

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _detallesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programacion de citas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Selecciona fecha y hora',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: CalendarDatePicker(
              initialDate: _fechaSeleccionada,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (value) {
                setState(() => _fechaSeleccionada = value);
                _cargarProfesionalesDisponibles();
              },
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('Hora de la cita'),
            subtitle: Text(_horaSeleccionada.format(context)),
            onTap: () async {
              final seleccion = await showTimePicker(
                context: context,
                initialTime: _horaSeleccionada,
              );

              if (seleccion == null) return;
              setState(() => _horaSeleccionada = seleccion);
              _cargarProfesionalesDisponibles();
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Profesionales disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_loadingProfesionales)
            const Center(child: CircularProgressIndicator())
          else if (_profesionalesDisponibles.isEmpty)
            const Text(
              'No hay profesionales disponibles para la fecha seleccionada.',
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _profesionalSeleccionado?.id,
              decoration: const InputDecoration(
                labelText: 'Selecciona un profesional',
              ),
              items: _profesionalesDisponibles
                  .map(
                    (prof) => DropdownMenuItem<String>(
                      value: prof.id,
                      child: Text(
                        prof.especialidad == null || prof.especialidad!.isEmpty
                            ? prof.nombre
                            : '${prof.nombre} - ${prof.especialidad}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _profesionalSeleccionado = _profesionalesDisponibles
                      .firstWhere((p) => p.id == value);
                });
              },
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _motivoController,
            decoration: const InputDecoration(
              labelText: 'Motivo de la cita',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detallesController,
            decoration: const InputDecoration(
              labelText: 'Detalles adicionales',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _continuarAConfirmacion,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuar a confirmacion'),
                ),
        ],
      ),
    );
  }
}
