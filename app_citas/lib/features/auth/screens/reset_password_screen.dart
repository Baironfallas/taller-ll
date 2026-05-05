import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color _primaryBlue = Color(0xFF004B87);
  static const Color _secondaryBlue = Color(0xFF0073B7);
  static const Color _clinicWhite = Color(0xFFF0F5FA);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _darkText = Color(0xFF333333);
  static const Color _lightText = Color(0xFF666666);
  static const Color _borderBlue = Color(0xFFD4E5F0);
  static const Color _errorRed = Color(0xFFB42318);

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guardarNuevaContrasena() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final email = _emailController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _error = 'Completa el correo y los dos campos de contrasena';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = 'La contrasena debe tener al menos 6 caracteres';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _error = 'Las contrasenas no coinciden';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.resetPassword(email: email, newPassword: password);
      await _authService.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contrasena actualizada. Vuelve a iniciar sesion.'),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudo actualizar la contrasena: $e';
      });
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: _clinicWhite,
      appBar: AppBar(
        title: Text(
          'Cambiar contrasena',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: _clinicWhite,
        foregroundColor: _primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 32,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _borderBlue),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 22 : 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: isMobile ? 62 : 70,
                        height: isMobile ? 62 : 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _secondaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: _white,
                          size: 36,
                        ),
                      ),
                      SizedBox(height: isMobile ? 18 : 22),
                      Text(
                        'Define tu nueva contrasena',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 28 : 32,
                          fontWeight: FontWeight.w700,
                          color: _primaryBlue,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Primero abre el enlace del correo de recuperacion. Luego escribe tu nueva contrasena para actualizar tu acceso.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: isMobile ? 14 : 15,
                          color: _lightText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.dmSans(color: _darkText),
                        decoration: _inputDecoration(
                          label: 'Correo electronico',
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: GoogleFonts.dmSans(color: _darkText),
                        decoration: _inputDecoration(
                          label: 'Nueva contrasena',
                          icon: Icons.lock_outline,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: GoogleFonts.dmSans(color: _darkText),
                        decoration: _inputDecoration(
                          label: 'Confirmar contrasena',
                          icon: Icons.verified_user_outlined,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_error != null) _ErrorBanner(message: _error!),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _guardarNuevaContrasena,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            'Actualizar contrasena',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: _white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Volver al inicio de sesion',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            color: _secondaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.dmSans(color: _lightText),
      prefixIcon: Icon(icon, color: _secondaryBlue),
      filled: true,
      fillColor: _clinicWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _secondaryBlue, width: 1.5),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ResetPasswordScreenState._errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _ResetPasswordScreenState._errorRed.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _ResetPasswordScreenState._errorRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                color: _ResetPasswordScreenState._errorRed,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
