import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  Future<Profile?> _cargarPerfil() {
    return _profileService.obtenerMiPerfil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<Profile?>(
        future: _cargarPerfil(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profile = snapshot.data;

          if (profile == null) {
            return const Center(child: Text('No hay perfil registrado.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Nombre'),
                subtitle: Text(profile.nombre ?? 'Sin nombre'),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Correo'),
                subtitle: Text(profile.email ?? 'Sin correo'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Telefono'),
                subtitle: Text(profile.telefono ?? 'Sin telefono'),
              ),
            ],
          );
        },
      ),
    );
  }
}
