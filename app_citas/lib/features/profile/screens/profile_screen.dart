// UI REFINED — visual only
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/app_messages.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _primary = Color(0xFF004B87);
  static const Color _secondary = Color(0xFF0073B7);
  static const Color _background = Color(0xFFF0F5FA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF333333);
  static const Color _textLight = Color(0xFF666666);
  static const Color _border = Color(0xFFD4E5F0);
  static const Color _error = Color(0xFFB42318);

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
      backgroundColor: _background,
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

          final displayName =
              '${profile?.nombre ?? ''} ${profile?.apellido ?? ''}'.trim();

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 28),
                decoration: const BoxDecoration(color: _primary),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 48,
                        backgroundColor: Color(0xFFE8F4FD),
                        child: Icon(
                          Icons.person_outline,
                          color: _secondary,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName.isEmpty ? 'Mi perfil' : displayName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? 'Usuario',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _SettingsField(
                        controller: _nombreController,
                        label: 'Nombre',
                        icon: Icons.person_outline,
                      ),
                      const Divider(height: 1, color: _border),
                      _SettingsField(
                        controller: _apellidoController,
                        label: 'Apellido',
                        icon: Icons.badge_outlined,
                      ),
                      const Divider(height: 1, color: _border),
                      _SettingsField(
                        controller: _emailController,
                        label: 'Correo electronico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const Divider(height: 1, color: _border),
                      _SettingsField(
                        controller: _currentPasswordController,
                        label: 'Contrasena actual (solo si cambias clave)',
                        icon: Icons.lock_open_outlined,
                        obscureText: true,
                      ),
                      const Divider(height: 1, color: _border),
                      _SettingsField(
                        controller: _telefonoController,
                        label: 'Telefono',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const Divider(height: 1, color: _border),
                      _SettingsField(
                        controller: _passwordController,
                        label: 'Nueva contrasena (opcional)',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _guardando
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _guardarPerfil,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar cambios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            textStyle: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(
                  Icons.notifications_outlined,
                  color: _secondary,
                ),
                title: Text(
                  'Configurar notificaciones y recordatorios',
                  style: GoogleFonts.dmSans(fontSize: 14, color: _textDark),
                ),
                trailing: const Icon(Icons.chevron_right, color: _textLight),
                onTap: () => Navigator.pushNamed(context, '/notificaciones'),
              ),
              const Divider(indent: 24, endIndent: 24, color: _border),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Cerrar sesion',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _error,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
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
}

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        color: _ProfileScreenState._textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: _ProfileScreenState._textLight,
        ),
        prefixIcon: Icon(icon, color: _ProfileScreenState._secondary),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
