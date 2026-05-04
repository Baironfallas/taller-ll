import 'package:flutter/material.dart';

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppMessages.logoutGoodbye)),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<List<Map<String, dynamic>>> _cargarCitas() async {
    return await widget.citaService.obtenerMisCitas();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de usuario'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarCitas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${user?.email ?? 'usuario'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Citas programadas: $total'),
                        Text('Pendientes por confirmar: $pendientes'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Acciones rapidas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/agenda');
                        if (!mounted) return;
                        setState(() {});
                      },
                      icon: const Icon(Icons.event_note),
                      label: const Text('Gestionar agenda'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Perfil'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/notificaciones',
                      ),
                      icon: const Icon(Icons.notifications_none),
                      label: const Text('Notificaciones'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Proximas citas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (proximas.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Todavia no tienes citas programadas.'),
                    ),
                  )
                else
                  ...proximas.map(
                    (cita) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: Text('${cita['fecha']} - ${cita['hora']}'),
                        subtitle: Text(cita['motivo']?.toString() ?? 'Sin motivo'),
                        trailing: Text(cita['estado']?.toString() ?? 'pendiente'),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/crear-cita');

          if (!mounted) return;

          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
