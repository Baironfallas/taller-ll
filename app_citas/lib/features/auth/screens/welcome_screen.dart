import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _matchaMist = Color(0xFFC2D8C4);
  static const Color _dustyCoal = Color(0xFF222222);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF2EB),
              _matchaMist,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _dustyCoal,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        size: 40,
                        color: _matchaMist,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Gestiona tus citas con calma y claridad',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: _dustyCoal,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'App Citas te ayuda a organizar tus reservas desde el celular de forma intuitiva, segura y sin complicaciones.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF2E2E2E),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0x26000000),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Servicios que encontrarás',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _dustyCoal,
                            ),
                          ),
                          SizedBox(height: 14),
                          _ServiceItem(
                            icon: Icons.event_available_rounded,
                            title: 'Reserva rápida',
                            description:
                                'Agenda citas en pocos pasos según tu disponibilidad.',
                          ),
                          SizedBox(height: 12),
                          _ServiceItem(
                            icon: Icons.notifications_active_rounded,
                            title: 'Recordatorios útiles',
                            description:
                                'Recibe alertas para no olvidar tus próximas citas.',
                          ),
                          SizedBox(height: 12),
                          _ServiceItem(
                            icon: Icons.manage_accounts_rounded,
                            title: 'Gestión sencilla',
                            description:
                                'Consulta, confirma o reprograma tus reservas fácilmente.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Iniciar sesión o registrarse'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _dustyCoal,
                          foregroundColor: _matchaMist,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0x1A222222),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: WelcomeScreen._dustyCoal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: WelcomeScreen._dustyCoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Color(0xFF383838),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
