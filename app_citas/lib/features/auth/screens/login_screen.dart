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

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerLastNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoginMode = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerLastNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_loginFormKey.currentState!.validate()) {
      setState(() {
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppMessages.loginSuccess)));

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _normalizeError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_registerFormKey.currentState!.validate()) {
      setState(() {
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.register(
        nombre: _registerNameController.text.trim(),
        apellido: _registerLastNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppMessages.userRegistered)));

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _normalizeError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _recoverPassword() async {
    final email = _currentEmailValue;

    if (_requiredValidator(email, 'correo') != null ||
        _emailValidator(email) != null) {
      setState(() {
        _error = 'Ingresa un correo valido para recuperar tu contrasena.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

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
      if (!mounted) return;

      setState(() {
        _error = _normalizeError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ayuda de acceso'),
          content: const Text(
            'Verifica tu correo y contrasena antes de intentar otra vez. '
            'Si no recuerdas tu acceso, usa la opcion de recuperacion.',
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

  void _switchMode(bool isLoginMode) {
    if (_isLoginMode == isLoginMode) return;

    setState(() {
      _isLoginMode = isLoginMode;
      _error = null;
    });
  }

  String get _currentEmailValue {
    return (_isLoginMode
            ? _loginEmailController.text
            : _registerEmailController.text)
        .trim();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'El $fieldName es obligatorio.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredMessage = _requiredValidator(value, 'correo');
    if (requiredMessage != null) return requiredMessage;

    final email = value!.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo valido.';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final requiredMessage = _requiredValidator(value, 'contrasena');
    if (requiredMessage != null) return requiredMessage;

    if (value!.trim().length < 6) {
      return 'La contrasena debe tener al menos 6 caracteres.';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final requiredMessage = _requiredValidator(value, 'confirmacion');
    if (requiredMessage != null) return requiredMessage;

    if (value!.trim() != _registerPasswordController.text.trim()) {
      return 'Las contrasenas no coinciden.';
    }

    return null;
  }

  String _normalizeError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final horizontalPadding = isMobile ? 20.0 : 32.0;
    final verticalPadding = isMobile ? 18.0 : 24.0;
    final maxCardWidth = isMobile ? 520.0 : 540.0;

    return Scaffold(
      backgroundColor: _clinicWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minContentHeight =
                (constraints.maxHeight - (verticalPadding * 2))
                    .clamp(0.0, double.infinity)
                    .toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minContentHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxCardWidth),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A004B87),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 20 : 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LoginHeader(isLoginMode: _isLoginMode),
                            SizedBox(height: isMobile ? 22 : 26),
                            _AuthModeToggle(
                              isLoginMode: _isLoginMode,
                              onChanged: _switchMode,
                            ),
                            const SizedBox(height: 20),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: _isLoginMode
                                  ? _buildLoginForm()
                                  : _buildRegisterForm(isMobile),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        key: const ValueKey('login-form'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.dmSans(color: _darkText),
            decoration: _inputDecoration(
              label: 'Correo electronico',
              icon: Icons.email_outlined,
            ),
            validator: _emailValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: true,
            style: GoogleFonts.dmSans(color: _darkText),
            decoration: _inputDecoration(
              label: 'Contrasena',
              icon: Icons.lock_outline,
            ),
            validator: (value) => _requiredValidator(value, 'contrasena'),
          ),
          const SizedBox(height: 16),
          if (_error != null) _ErrorBanner(message: _error!),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _handleLogin,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_white),
                      ),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(
                'Iniciar sesion',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: _white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading ? null : () => _switchMode(false),
            child: Text(
              'No tienes cuenta? Registrate',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: _secondaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(child: Divider(color: _borderBlue)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'o continua con',
                  style: GoogleFonts.dmSans(fontSize: 13, color: _lightText),
                ),
              ),
              const Expanded(child: Divider(color: _borderBlue)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: _loading ? null : _recoverPassword,
                icon: const Icon(Icons.key_rounded, size: 18),
                label: const Text('Recuperar contrasena'),
                style: _linkStyle(),
              ),
              TextButton.icon(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/reset-password');
                      },
                icon: const Icon(Icons.password_rounded, size: 18),
                label: const Text('Cambiar contrasena'),
                style: _linkStyle(),
              ),
              TextButton.icon(
                onPressed: _loading ? null : _showHelp,
                icon: const Icon(Icons.help_outline_rounded, size: 18),
                label: const Text('Necesitas ayuda?'),
                style: _linkStyle(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(bool isMobile) {
    final nameFields = isMobile
        ? Column(
            children: [
              TextFormField(
                controller: _registerNameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.dmSans(color: _darkText),
                decoration: _inputDecoration(
                  label: 'Nombre',
                  icon: Icons.person_outline,
                ),
                validator: (value) => _requiredValidator(value, 'nombre'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _registerLastNameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.dmSans(color: _darkText),
                decoration: _inputDecoration(
                  label: 'Apellidos',
                  icon: Icons.badge_outlined,
                ),
                validator: (value) => _requiredValidator(value, 'apellido'),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _registerNameController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.dmSans(color: _darkText),
                  decoration: _inputDecoration(
                    label: 'Nombre',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) => _requiredValidator(value, 'nombre'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _registerLastNameController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.dmSans(color: _darkText),
                  decoration: _inputDecoration(
                    label: 'Apellidos',
                    icon: Icons.badge_outlined,
                  ),
                  validator: (value) => _requiredValidator(value, 'apellido'),
                ),
              ),
            ],
          );

    return Form(
      key: _registerFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        key: const ValueKey('register-form'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          nameFields,
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.dmSans(color: _darkText),
            decoration: _inputDecoration(
              label: 'Correo electronico',
              icon: Icons.email_outlined,
            ),
            validator: _emailValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: true,
            style: GoogleFonts.dmSans(color: _darkText),
            decoration: _inputDecoration(
              label: 'Contrasena',
              icon: Icons.lock_outline,
            ),
            validator: _passwordValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerConfirmPasswordController,
            obscureText: true,
            style: GoogleFonts.dmSans(color: _darkText),
            decoration: _inputDecoration(
              label: 'Confirmar contrasena',
              icon: Icons.verified_user_outlined,
            ),
            validator: _confirmPasswordValidator,
          ),
          const SizedBox(height: 16),
          if (_error != null) _ErrorBanner(message: _error!),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _handleRegister,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_white),
                      ),
                    )
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: Text(
                'Registrarse',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: _white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading ? null : () => _switchMode(true),
            child: Text(
              'Ya tienes cuenta? Inicia sesion',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: _secondaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.dmSans(fontSize: 14, color: _lightText),
      errorStyle: GoogleFonts.dmSans(
        fontSize: 12,
        color: _errorRed,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: _secondaryBlue),
      filled: true,
      fillColor: _white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _secondaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorRed, width: 1.5),
      ),
    );
  }

  static ButtonStyle _linkStyle() {
    return TextButton.styleFrom(
      foregroundColor: _secondaryBlue,
      textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}

class _AuthModeToggle extends StatelessWidget {
  const _AuthModeToggle({
    required this.isLoginMode,
    required this.onChanged,
  });

  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _LoginScreenState._clinicWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _LoginScreenState._borderBlue),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthModeButton(
              label: 'Iniciar sesion',
              icon: Icons.login_rounded,
              selected: isLoginMode,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _AuthModeButton(
              label: 'Registrarse',
              icon: Icons.person_add_alt_1_rounded,
              selected: !isLoginMode,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? _LoginScreenState._white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x12004B87),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? _LoginScreenState._primaryBlue
                      : _LoginScreenState._lightText,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? _LoginScreenState._primaryBlue
                          : _LoginScreenState._lightText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.isLoginMode});

  final bool isLoginMode;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          isLoginMode ? 'Bienvenido de nuevo' : 'Crea tu cuenta',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _LoginScreenState._primaryBlue,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isLoginMode
              ? 'Accede a tus citas y datos personales desde un mismo lugar.'
              : 'Registrate para gestionar tus citas con la misma experiencia del resto del sistema.',
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
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
