import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_messages.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;

  Future<void> _recuperarContrasena() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _error = 'Ingresa tu correo para recuperar la contraseña';
      });
      return;
    }

    try {
      await _authService.recuperarContrasena(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te enviamos instrucciones para restablecer tu contraseña.'),
        ),
      );
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Error inesperado: $e';
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
            'Si no puedes entrar, verifica tu correo y contraseña. '
            'Tambien puedes registrarte con un correo nuevo o usar "Recuperar contraseña".',
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.loginSuccess)),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Error inesperado: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.userRegistered)),
      );
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Error inesperado: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro / Inicio de sesion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Accede o crea tu cuenta',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: _login,
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesion'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _register,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Registrarse'),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _recuperarContrasena,
                child: const Text('Recuperar contraseña'),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _mostrarAyuda,
                child: const Text('Necesitas ayuda?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
