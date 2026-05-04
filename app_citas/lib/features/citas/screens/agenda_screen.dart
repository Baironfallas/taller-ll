import 'package:flutter/material.dart';

import '../../../core/utils/app_messages.dart';
import '../services/cita_service.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final CitaService _citaService = CitaService();
  final TextEditingController _busquedaController = TextEditingController();

  String _estadoFiltro = 'todos';

  Future<List<Map<String, dynamic>>> _cargarCitas() {
    return _citaService.obtenerMisCitas();
  }

  List<Map<String, dynamic>> _filtrarCitas(List<Map<String, dynamic>> citas) {
    final query = _busquedaController.text.trim().toLowerCase();

    return citas.where((cita) {
      final estado = (cita['estado'] ?? 'pendiente').toString().toLowerCase();
      final coincideEstado = _estadoFiltro == 'todos' || estado == _estadoFiltro;

      final texto = [
        cita['fecha']?.toString() ?? '',
        cita['hora']?.toString() ?? '',
        cita['motivo']?.toString() ?? '',
        estado,
      ].join(' ').toLowerCase();

      final coincideBusqueda = query.isEmpty || texto.contains(query);
      return coincideEstado && coincideBusqueda;
    }).toList();
  }

  Future<void> _marcarCancelada(Map<String, dynamic> cita) async {
    await _citaService.actualizarCita(
      id: cita['id'].toString(),
      fecha: cita['fecha'].toString(),
      hora: cita['hora'].toString(),
      motivo: cita['motivo']?.toString() ?? '',
      profesionalId: cita['profesional_id']?.toString(),
      servicioId: cita['servicio_id']?.toString(),
      estado: 'cancelada',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita cancelada')),
    );

    setState(() {});
  }

  Future<void> _mostrarEditor(Map<String, dynamic> cita) async {
    DateTime fecha = DateTime.tryParse(cita['fecha']?.toString() ?? '') ??
        DateTime.now();
    TimeOfDay hora = _parseHora(cita['hora']?.toString()) ?? TimeOfDay.now();
    final motivoController = TextEditingController(
      text: cita['motivo']?.toString() ?? '',
    );

    final confirmo = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar cita'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha'),
                    subtitle: Text(_formatFecha(fecha)),
                    onTap: () async {
                      final seleccion = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 2),
                        ),
                        initialDate: fecha,
                      );

                      if (seleccion == null) return;
                      setDialogState(() => fecha = seleccion);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: const Text('Hora'),
                    subtitle: Text(_formatHora(hora)),
                    onTap: () async {
                      final seleccion = await showTimePicker(
                        context: context,
                        initialTime: hora,
                      );

                      if (seleccion == null) return;
                      setDialogState(() => hora = seleccion);
                    },
                  ),
                  TextField(
                    controller: motivoController,
                    decoration: const InputDecoration(labelText: 'Motivo'),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmo != true) return;

    await _citaService.actualizarCita(
      id: cita['id'].toString(),
      fecha: _formatFecha(fecha),
      hora: _horaSupabase(hora),
      motivo: motivoController.text.trim(),
      profesionalId: cita['profesional_id']?.toString(),
      servicioId: cita['servicio_id']?.toString(),
      estado: cita['estado']?.toString() ?? 'pendiente',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita actualizada')),
    );

    setState(() {});
  }

  TimeOfDay? _parseHora(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
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

  String _horaSupabase(TimeOfDay time) {
    return '${_formatHora(time)}:00';
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion de agenda')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por fecha, hora, motivo o estado',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busquedaController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _estadoFiltro,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por estado',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'confirmada', child: Text('Confirmada')),
                    DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _estadoFiltro = value ?? 'todos';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _cargarCitas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final citas = _filtrarCitas(snapshot.data ?? []);

                if (citas.isEmpty) {
                  return const Center(
                    child: Text('No hay citas con los filtros actuales.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event_note),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${cita['fecha']} - ${cita['hora']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      (cita['estado'] ?? 'pendiente').toString(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(cita['motivo']?.toString() ?? 'Sin motivo'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _mostrarEditor(cita),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Editar'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _marcarCancelada(cita),
                                    icon: const Icon(Icons.cancel_outlined),
                                    label: const Text('Cancelar'),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Eliminar',
                                    onPressed: () async {
                                      await _citaService
                                          .eliminarCita(cita['id'].toString());

                                      if (!mounted) return;

                                      ScaffoldMessenger.of(this.context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Cita eliminada'),
                                        ),
                                      );

                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              AppMessages.citaConfirmed,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
