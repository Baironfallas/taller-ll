import 'package:flutter/material.dart';

import '../../../core/utils/app_messages.dart';
import '../models/notificacion.dart';
import '../services/notificacion_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppMessages.preferencesSaved)),
    );
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Preferencias de notificacion',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _prefEmail,
                      onChanged: (value) => setState(() => _prefEmail = value),
                      title: const Text('Correo electronico'),
                    ),
                    SwitchListTile(
                      value: _prefSms,
                      onChanged: (value) => setState(() => _prefSms = value),
                      title: const Text('SMS'),
                    ),
                    SwitchListTile(
                      value: _prefPush,
                      onChanged: (value) => setState(() => _prefPush = value),
                      title: const Text('Push en la app'),
                    ),
                    ListTile(
                      title: const Text('Recordatorio previo'),
                      subtitle: Text('$_recordatorioMinutos minutos antes'),
                    ),
                    Slider(
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
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bandeja de notificaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (notificaciones.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No tienes notificaciones.'),
                  ),
                )
              else
                ...notificaciones.map(
                  (notificacion) => Card(
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
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
