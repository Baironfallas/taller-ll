import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _primaryBlue = Color(0xFF004B87);
  static const Color _secondaryBlue = Color(0xFF0073B7);
  static const Color _clinicWhite = Color(0xFFF0F5FA);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _darkText = Color(0xFF333333);
  static const Color _lightText = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 600;

    return Scaffold(
      backgroundColor: _clinicWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSection(isMobile: isMobile),
                  SizedBox(height: isMobile ? 28 : 36),
                  _ServicesList(isMobile: isMobile),
                  SizedBox(height: isMobile ? 28 : 36),
                  const _CtaButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: isMobile ? 64 : 76,
            height: isMobile ? 64 : 76,
            decoration: BoxDecoration(
              color: WelcomeScreen._secondaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: isMobile ? 34 : 40,
              color: WelcomeScreen._white,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 24 : 30),
        Text(
          'Gestiona tus citas facilmente',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 34 : 42,
            fontWeight: FontWeight.w700,
            color: WelcomeScreen._primaryBlue,
            height: 1.15,
          ),
        ),
        SizedBox(height: isMobile ? 14 : 18),
        Text(
          'Una plataforma simple para reservar, consultar y organizar tus citas en pocos pasos.',
          style: GoogleFonts.dmSans(
            fontSize: isMobile ? 15 : 17,
            color: WelcomeScreen._lightText,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final services = [
      (Icons.event_available_rounded, 'Reserva de citas'),
      (Icons.notifications_none_rounded, 'Recordatorios'),
      (Icons.person_outline_rounded, 'Gestion de perfil'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: services.map((service) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: WelcomeScreen._white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4E5F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(service.$1, size: 18, color: WelcomeScreen._secondaryBlue),
              const SizedBox(width: 8),
              Text(
                service.$2,
                style: GoogleFonts.dmSans(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: WelcomeScreen._darkText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: double.infinity,
      height: isMobile ? 52 : 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(
          'Iniciar sesion o registrarse',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 15 : 16,
          ),
        ),
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(
            WelcomeScreen._primaryBlue,
          ),
          foregroundColor: const WidgetStatePropertyAll(WelcomeScreen._white),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          overlayColor: WidgetStatePropertyAll(
            Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}
