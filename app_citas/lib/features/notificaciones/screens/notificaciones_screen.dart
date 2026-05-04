import 'package:flutter/material.dart';

import '../models/notificacion.dart';
import '../services/notificacion_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final NotificacionService _notificacionService = NotificacionService();

  Future<List<Notificacion>> _cargarNotificaciones() {
    return _notificacionService.obtenerMisNotificaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
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

          if (notificaciones.isEmpty) {
            return const Center(child: Text('No tienes notificaciones.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final notificacion = notificaciones[index];

              return Card(
                child: ListTile(
                  leading: Icon(
                    notificacion.leida == true
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                  ),
                  title: Text(notificacion.titulo),
                  subtitle: Text(notificacion.mensaje),
                  onTap: () async {
                    await _notificacionService.marcarComoLeida(
                      notificacion.id,
                    );

                    if (!mounted) return;

                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
