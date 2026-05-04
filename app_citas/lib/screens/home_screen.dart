import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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
    await widget.authService.logout();

    if (!mounted) return;

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
        title: const Text('Mis citas'),
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

          if (citas.isEmpty) {
            return Center(
              child: Text(
                'Bienvenido ${user?.email ?? ''}\n\nTodavía no tienes citas.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final cita = citas[index];

              return Card(
                child: ListTile(
                  title: Text('${cita['fecha']} - ${cita['hora']}'),
                  subtitle: Text(cita['motivo'] ?? 'Sin motivo'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cita['estado'] ?? 'pendiente'),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await widget.citaService.eliminarCita(cita['id']);

                          if (!mounted) return;

                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
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