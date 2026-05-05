import 'package:flutter/material.dart';

import '../../../core/utils/app_messages.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _guardando = false;
  bool _initialized = false;

  Future<Profile?> _cargarPerfil() {
    return _profileService.obtenerMiPerfil();
  }

  Future<void> _guardarPerfil() async {
    setState(() => _guardando = true);

    try {
      await _profileService.actualizarMiPerfil(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
      );

      final contrasenaActual = _currentPasswordController.text.trim();
      final nuevaContrasena = _passwordController.text.trim();

      if (nuevaContrasena.isNotEmpty) {
        if (contrasenaActual.isEmpty) {
          throw Exception('Ingresa la contrasena actual para cambiarla.');
        }
        await _profileService.cambiarContrasena(
          currentPassword: contrasenaActual,
          newPassword: nuevaContrasena,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppMessages.profileUpdated)));
      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible actualizar el perfil: $e')),
      );
    }

    if (!mounted) return;
    setState(() => _guardando = false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
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

          if (!_initialized) {
            _nombreController.text = profile?.nombre ?? '';
            _apellidoController.text = profile?.apellido ?? '';
            _telefonoController.text = profile?.telefono ?? '';
            _emailController.text = profile?.email ?? '';
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Editar informacion del perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electronico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contrasena actual (solo si cambias clave)',
                  prefixIcon: Icon(Icons.lock_open_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña (opcional)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 18),
              _guardando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _guardarPerfil,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar cambios'),
                    ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/notificaciones'),
                icon: const Icon(Icons.notifications_outlined),
                label: const Text('Configurar notificaciones y recordatorios'),
              ),
            ],
          );
        },
      ),
    );
  }
}
