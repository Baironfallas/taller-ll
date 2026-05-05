// UI REFINED — visual only
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../profesionales/models/profesional.dart';
import '../../profesionales/services/profesional_service.dart';

class CreateCitaScreen extends StatefulWidget {
  const CreateCitaScreen({super.key});

  @override
  State<CreateCitaScreen> createState() => _CreateCitaScreenState();
}

class _CreateCitaScreenState extends State<CreateCitaScreen> {
  static const Color _primary = Color(0xFF004B87);
  static const Color _secondary = Color(0xFF0073B7);
  static const Color _background = Color(0xFFF0F5FA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textLight = Color(0xFF666666);
  static const Color _border = Color(0xFFD4E5F0);

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
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Programacion de citas',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressBar(value: 0.62),
          const SizedBox(height: 24),
          Text(
            'Selecciona fecha y hora',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: _cardDecoration(),
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
          const SizedBox(height: 16),
          _PickerField(
            icon: Icons.access_time,
            label: 'Hora de la cita',
            value: _horaSeleccionada.format(context),
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
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5, color: _border),
          const SizedBox(height: 16),
          Text(
            'Profesionales disponibles',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          if (_loadingProfesionales)
            const Center(child: CircularProgressIndicator())
          else if (_profesionalesDisponibles.isEmpty)
            Text(
              'No hay profesionales disponibles para la fecha seleccionada.',
              style: GoogleFonts.dmSans(fontSize: 14, color: _textLight),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _profesionalSeleccionado?.id,
              decoration: _inputDecoration('Selecciona un profesional'),
              items: _profesionalesDisponibles
                  .map(
                    (prof) => DropdownMenuItem<String>(
                      value: prof.id,
                      child: Text(
                        prof.especialidad == null || prof.especialidad!.isEmpty
                            ? prof.nombre
                            : '${prof.nombre} - ${prof.especialidad}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: _textDark,
                        ),
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
            style: GoogleFonts.dmSans(fontSize: 14, color: _textDark),
            decoration: _inputDecoration('Motivo de la cita'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detallesController,
            style: GoogleFonts.dmSans(fontSize: 14, color: _textDark),
            decoration: _inputDecoration('Detalles adicionales'),
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _continuarAConfirmacion,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      'Continuar a confirmacion',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
        ],
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

  static InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.dmSans(fontSize: 14, color: _textLight),
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
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        minHeight: 4,
        value: value,
        backgroundColor: _CreateCitaScreenState._border,
        valueColor: const AlwaysStoppedAnimation<Color>(
          _CreateCitaScreenState._primary,
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: _CreateCitaScreenState._inputDecoration(label).copyWith(
          prefixIcon: Icon(icon, color: _CreateCitaScreenState._secondary),
        ),
        child: Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: _CreateCitaScreenState._textDark,
          ),
        ),
      ),
    );
  }
}
