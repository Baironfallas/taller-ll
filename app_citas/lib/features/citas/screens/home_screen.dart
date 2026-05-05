// UI REFINED — visual only
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/app_messages.dart';
import '../../auth/services/auth_service.dart';
import '../services/cita_service.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  final AuthService authService = AuthService();
  final CitaService citaService = CitaService();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primary = Color(0xFF004B87);
  static const Color _secondary = Color(0xFF0073B7);
  static const Color _background = Color(0xFFF0F5FA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textLight = Color(0xFF666666);
  static const Color _border = Color(0xFFD4E5F0);
  static const Color _error = Color(0xFFB42318);

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesion'),
          content: const Text('Deseas cerrar sesion ahora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Si, cerrar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await widget.authService.logout();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppMessages.logoutGoodbye)));

    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<List<Map<String, dynamic>>> _cargarCitas() async {
    return await widget.citaService.obtenerMisCitas();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Panel de usuario',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarCitas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final citas = snapshot.data ?? [];
          final total = citas.length;
          final pendientes = citas
              .where((c) => (c['estado'] ?? 'pendiente') == 'pendiente')
              .length;
          final proximas = citas.take(3).toList();

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${user?.email ?? 'usuario'}',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tienes $total citas programadas y $pendientes pendientes por confirmar.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: _textLight,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(label: 'Acciones rapidas'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/crear-cita');
                        if (!mounted) return;
                        setState(() {});
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Programar nueva cita'),
                      style: _primaryButtonStyle(),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/agenda');
                        if (!mounted) return;
                        setState(() {});
                      },
                      icon: const Icon(Icons.event_note),
                      label: const Text('Gestionar agenda'),
                      style: _outlineButtonStyle(),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Perfil'),
                      style: _outlineButtonStyle(),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/notificaciones'),
                      icon: const Icon(Icons.notifications_none),
                      label: const Text('Notificaciones'),
                      style: _outlineButtonStyle(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(label: 'Proximas citas'),
                const SizedBox(height: 8),
                if (proximas.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Text(
                      'Todavia no tienes citas programadas.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: _textLight,
                      ),
                    ),
                  )
                else
                  ...proximas.map(
                    (cita) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AppointmentCard(cita: cita),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () async {
          await Navigator.pushNamed(context, '/crear-cita');

          if (!mounted) return;

          setState(() {});
        },
        child: const Icon(Icons.add),
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

  static ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
      textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static ButtonStyle _outlineButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: _primary,
      side: const BorderSide(color: _border),
      textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        color: _HomeScreenState._textLight,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.cita});

  final Map<String, dynamic> cita;

  @override
  Widget build(BuildContext context) {
    final estado = cita['estado']?.toString() ?? 'pendiente';

    return Container(
      decoration: _HomeScreenState._cardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: _HomeScreenState._secondary,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: _HomeScreenState._secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cita['fecha']} - ${cita['hora']}',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _HomeScreenState._textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cita['motivo']?.toString() ?? 'Sin motivo',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: _HomeScreenState._textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(estado: estado),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      foreground = _HomeScreenState._secondary;
    } else if (normalized == 'cancelada' || normalized == 'cancelled') {
      background = const Color(0xFFFFEBEB);
      foreground = _HomeScreenState._error;
    } else {
      background = const Color(0xFFFFF8E1);
      foreground = Color(0xFFB07D00);
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
