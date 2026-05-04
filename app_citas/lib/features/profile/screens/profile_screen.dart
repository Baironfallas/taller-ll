import 'package:flutter/material.dart';

import '../../../core/utils/app_messages.dart';
import '../../auth/services/auth_service.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
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
        telefono: _telefonoController.text.trim(),
      );

      final nuevoEmail = _emailController.text.trim();
      final nuevaContrasena = _passwordController.text.trim();
      final emailActual = _authService.currentUser?.email ?? '';

      if (nuevoEmail.isNotEmpty && nuevoEmail != emailActual) {
        await _authService.actualizarCredenciales(email: nuevoEmail);
      }

      if (nuevaContrasena.isNotEmpty) {
        await _authService.actualizarCredenciales(password: nuevaContrasena);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.profileUpdated)),
      );
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
    _telefonoController.dispose();
    _emailController.dispose();
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
            _telefonoController.text = profile?.telefono ?? '';
            _emailController.text = profile?.email ?? _authService.currentUser?.email ?? '';
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electronico',
                  prefixIcon: Icon(Icons.email_outlined),
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
                onPressed: () => Navigator.pushNamed(context, '/notificaciones'),
                icon: const Icon(Icons.notifications_outlined),
                label: const Text(
                  'Configurar notificaciones y recordatorios',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
