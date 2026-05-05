// UI REFINED — visual only
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/app_messages.dart';
import '../services/cita_service.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  static const Color _primary = Color(0xFF004B87);
  static const Color _secondary = Color(0xFF0073B7);
  static const Color _background = Color(0xFFF0F5FA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textLight = Color(0xFF666666);
  static const Color _border = Color(0xFFD4E5F0);
  static const Color _error = Color(0xFFB42318);

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
      final coincideEstado =
          _estadoFiltro == 'todos' || estado == _estadoFiltro;

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
    await _citaService.cancelarCita(cita['id'].toString());

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cita cancelada')));

    setState(() {});
  }

  Future<void> _mostrarEditor(Map<String, dynamic> cita) async {
    DateTime fecha =
        DateTime.tryParse(cita['fecha']?.toString() ?? '') ?? DateTime.now();
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
      hora: _formatHora(hora),
      motivo: motivoController.text.trim(),
      profesionalId: cita['profesional_id']?.toString(),
      servicioId: cita['servicio_id']?.toString(),
      estado: cita['estado']?.toString() ?? 'pendiente',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cita actualizada')));

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

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Gestion de agenda',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _busquedaController,
                  style: GoogleFonts.dmSans(fontSize: 14, color: _textDark),
                  decoration: _inputDecoration(
                    labelText: 'Buscar por fecha, hora, motivo o estado',
                    prefixIcon: const Icon(Icons.search, color: _secondary),
                    suffixIcon: _busquedaController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close, color: _textLight),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _estadoFiltro,
                  decoration: _inputDecoration(labelText: 'Filtrar por estado'),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(
                      value: 'pendiente',
                      child: Text('Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: 'confirmada',
                      child: Text('Confirmada'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelada',
                      child: Text('Cancelada'),
                    ),
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
                  return Center(
                    child: Text(
                      'No hay citas con los filtros actuales.',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: _textLight,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Color(0xFFE8F4FD),
                                  child: Icon(
                                    Icons.event_note,
                                    color: _secondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${cita['fecha']} - ${cita['hora']}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cita['motivo']?.toString() ??
                                            'Sin motivo',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: _textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _StatusChip(
                                  estado: (cita['estado'] ?? 'pendiente')
                                      .toString(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _mostrarEditor(cita),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Editar'),
                                  style: _slotButtonStyle(),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _marcarCancelada(cita),
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Cancelar'),
                                  style: _slotButtonStyle(),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () async {
                                    await _citaService.eliminarCita(
                                      cita['id'].toString(),
                                    );

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cita eliminada'),
                                      ),
                                    );

                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: _error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              AppMessages.citaConfirmed,
              style: GoogleFonts.dmSans(fontSize: 12, color: _textLight),
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration({
    required String labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.dmSans(fontSize: 14, color: _textLight),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _secondary, width: 1.5),
      ),
    );
  }

  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A004B87),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static ButtonStyle _slotButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: _primary,
      side: const BorderSide(color: _border),
      textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final normalized = estado.toLowerCase();
    final Color background;
    final Color foreground;

    if (normalized == 'confirmada' || normalized == 'confirmed') {
      background = const Color(0xFFE8F4FD);
      foreground = _AgendaScreenState._secondary;
    } else if (normalized == 'cancelada' || normalized == 'cancelled') {
      background = const Color(0xFFFFEBEB);
      foreground = _AgendaScreenState._error;
    } else {
      background = const Color(0xFFFFF8E1);
      foreground = const Color(0xFFB07D00);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        estado,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
