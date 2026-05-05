// UI REFINED — visual only
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/app_messages.dart';
import '../models/notificacion.dart';
import '../services/notificacion_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  static const Color _primary = Color(0xFF004B87);
  static const Color _secondary = Color(0xFF0073B7);
  static const Color _background = Color(0xFFF0F5FA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textLight = Color(0xFF666666);
  static const Color _border = Color(0xFFD4E5F0);

  final NotificacionService _notificacionService = NotificacionService();

  bool _prefEmail = true;
  bool _prefSms = false;
  bool _prefPush = true;
  int _recordatorioMinutos = 60;
  bool _guardandoPreferencias = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<List<Notificacion>> _cargarNotificaciones() {
    return _notificacionService.obtenerMisNotificaciones();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await _notificacionService.obtenerPreferencias();

    if (!mounted) return;

    setState(() {
      _prefEmail = prefs['email'] as bool;
      _prefSms = prefs['sms'] as bool;
      _prefPush = prefs['push'] as bool;
      _recordatorioMinutos = prefs['recordatorioMinutos'] as int;
    });
  }

  Future<void> _guardarPreferencias() async {
    setState(() => _guardandoPreferencias = true);

    await _notificacionService.guardarPreferencias(
      email: _prefEmail,
      sms: _prefSms,
      push: _prefPush,
      recordatorioMinutos: _recordatorioMinutos,
    );

    if (!mounted) return;

    setState(() => _guardandoPreferencias = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppMessages.preferencesSaved)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Notificaciones',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Notificacion>>(
        future: _cargarNotificaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notificaciones = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(label: 'Preferencias de notificacion'),
              const SizedBox(height: 8),
              Container(
                decoration: _cardDecoration(radius: 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeThumbColor: _secondary,
                      value: _prefEmail,
                      onChanged: (value) => setState(() => _prefEmail = value),
                      title: Text(
                        'Correo electronico',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: _textDark,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: _border),
                    SwitchListTile(
                      activeThumbColor: _secondary,
                      value: _prefSms,
                      onChanged: (value) => setState(() => _prefSms = value),
                      title: Text(
                        'SMS',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: _textDark,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: _border),
                    SwitchListTile(
                      activeThumbColor: _secondary,
                      value: _prefPush,
                      onChanged: (value) => setState(() => _prefPush = value),
                      title: Text(
                        'Push en la app',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: _textDark,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Recordatorio previo',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                      ),
                      subtitle: Text(
                        '$_recordatorioMinutos minutos antes',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: _textLight,
                        ),
                      ),
                    ),
                    Slider(
                      activeColor: _primary,
                      inactiveColor: _border,
                      value: _recordatorioMinutos.toDouble(),
                      min: 15,
                      max: 1440,
                      divisions: 95,
                      label: '$_recordatorioMinutos min',
                      onChanged: (value) {
                        setState(() => _recordatorioMinutos = value.round());
                      },
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _guardandoPreferencias
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _guardarPreferencias,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Guardar preferencias'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                textStyle: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(label: 'Bandeja de notificaciones'),
              const SizedBox(height: 8),
              if (notificaciones.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: _cardDecoration(radius: 12),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        color: _secondary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No tienes notificaciones.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: _textLight,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...notificaciones.map(
                  (notificacion) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: notificacion.leida == true
                          ? _surface
                          : _background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: notificacion.leida == true
                              ? Colors.transparent
                              : _secondary,
                          width: 3,
                        ),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE8F4FD),
                        child: Icon(
                          notificacion.leida == true
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                          color: _secondary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        notificacion.titulo,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          notificacion.mensaje,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: _textLight,
                            height: 1.35,
                          ),
                        ),
                      ),
                      onTap: () async {
                        await _notificacionService.marcarComoLeida(
                          notificacion.id,
                        );

                        if (!mounted) return;

                        setState(() {});
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static BoxDecoration _cardDecoration({required double radius}) {
    return BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A004B87),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _NotificacionesScreenState._textLight,
        letterSpacing: 0.8,
      ),
    );
  }
}
