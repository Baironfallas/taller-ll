import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/app_messages.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _primaryBlue = Color(0xFF004B87);
  static const Color _secondaryBlue = Color(0xFF0073B7);
  static const Color _clinicWhite = Color(0xFFF0F5FA);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _darkText = Color(0xFF333333);
  static const Color _lightText = Color(0xFF666666);
  static const Color _borderBlue = Color(0xFFD4E5F0);
  static const Color _errorRed = Color(0xFFB42318);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;

  Future<void> _recuperarContrasena() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _error = 'Ingresa tu correo para recuperar la contrasena';
      });
      return;
    }

    try {
      await _authService.forgotPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Te enviamos instrucciones para restablecer tu contrasena.',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _mostrarAyuda() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ayuda de acceso'),
          content: const Text(
            'Si no puedes entrar, verifica tu correo y contrasena. '
            'Tambien puedes registrarte con un correo nuevo o usar "Recuperar contrasena".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppMessages.loginSuccess)));

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _register() async {
    if (_nombreController.text.trim().isEmpty ||
        _apellidoController.text.trim().isEmpty ||
        _telefonoController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _error = 'Completa nombre, apellido, telefono, correo y contrasena.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.register(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        telefono: _telefonoController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppMessages.userRegistered)));

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 600;

    return Scaffold(
      backgroundColor: _clinicWhite,
      appBar: AppBar(
        title: Text(
          'Registro / Inicio de sesion',
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
                      const _LoginHeader(),
                      SizedBox(height: isMobile ? 26 : 30),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nombreController,
                              textCapitalization: TextCapitalization.words,
                              style: GoogleFonts.dmSans(color: _darkText),
                              decoration: _inputDecoration(
                                label: 'Nombre',
                                icon: Icons.person_outline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _apellidoController,
                              textCapitalization: TextCapitalization.words,
                              style: GoogleFonts.dmSans(color: _darkText),
                              decoration: _inputDecoration(
                                label: 'Apellido',
                                icon: Icons.badge_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.dmSans(color: _darkText),
                        decoration: _inputDecoration(
                          label: 'Telefono',
                          icon: Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.dmSans(color: _darkText),
                        decoration: _inputDecoration(
                          label: 'Correo',
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: GoogleFonts.dmSans(color: _darkText),
                        decoration: _inputDecoration(
                          label: 'Contrasena',
                          icon: Icons.lock_outline,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_error != null) _ErrorBanner(message: _error!),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _login,
                            icon: const Icon(Icons.login_rounded),
                            label: Text(
                              'Iniciar sesion',
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
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _register,
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(
                              'Crear cuenta nueva',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryBlue,
                              side: const BorderSide(color: _secondaryBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Divider(color: _borderBlue),
                      const SizedBox(height: 4),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton.icon(
                            onPressed: _recuperarContrasena,
                            icon: const Icon(Icons.key_rounded, size: 18),
                            label: const Text('Recuperar contrasena'),
                            style: _linkStyle(),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/reset-password');
                            },
                            icon: const Icon(Icons.password_rounded, size: 18),
                            label: const Text('Cambiar contrasena'),
                            style: _linkStyle(),
                          ),
                          TextButton.icon(
                            onPressed: _mostrarAyuda,
                            icon: const Icon(
                              Icons.help_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('Necesitas ayuda?'),
                            style: _linkStyle(),
                          ),
                        ],
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

  static ButtonStyle _linkStyle() {
    return TextButton.styleFrom(
      foregroundColor: _secondaryBlue,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Container(
          width: isMobile ? 62 : 70,
          height: isMobile ? 62 : 70,
          decoration: BoxDecoration(
            color: _LoginScreenState._secondaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: _LoginScreenState._white,
            size: 36,
          ),
        ),
        SizedBox(height: isMobile ? 18 : 22),
        Text(
          'Accede o crea tu cuenta',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 30 : 34,
            fontWeight: FontWeight.w700,
            color: _LoginScreenState._primaryBlue,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Gestiona tus citas y datos personales con una experiencia simple y segura.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: isMobile ? 14 : 15,
            color: _LoginScreenState._lightText,
            height: 1.45,
          ),
        ),
      ],
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
        color: _LoginScreenState._errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _LoginScreenState._errorRed.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _LoginScreenState._errorRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                color: _LoginScreenState._errorRed,
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
