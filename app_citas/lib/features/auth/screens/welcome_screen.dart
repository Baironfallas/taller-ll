import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Paleta Azul Médico + Blanco Clínico
  static const Color _primaryBlue = Color(0xFF004B87);
  static const Color _secondaryBlue = Color(0xFF0073B7);
  static const Color _softBlue = Color(0xFF66B3E0);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(isMobile: isMobile),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 32 : 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IntroductionSection(isMobile: isMobile),
                  SizedBox(height: isMobile ? 32 : 48),
                  _ServicesDescriptionSection(isMobile: isMobile),
                  SizedBox(height: isMobile ? 40 : 56),
                  _CtaSection(),
                ],
              ),
            ),
          ],
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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WelcomeScreen._primaryBlue,
            WelcomeScreen._secondaryBlue,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 50 : 70,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 70 : 90,
            height: isMobile ? 70 : 90,
            decoration: BoxDecoration(
              color: WelcomeScreen._secondaryBlue,
              borderRadius: BorderRadius.circular(isMobile ? 18 : 28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: isMobile ? 36 : 48,
              color: WelcomeScreen._white,
            ),
          ),
          SizedBox(height: isMobile ? 28 : 40),
          Text(
            'Gestiona tus citas con confianza',
            style: GoogleFonts.playfairDisplay(
              fontSize: isMobile ? 32 : 44,
              fontWeight: FontWeight.w700,
              color: WelcomeScreen._white,
              height: 1.15,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Plataforma segura y profesional para organizar tus reservas.',
            style: GoogleFonts.dmSans(
              fontSize: isMobile ? 15 : 17,
              color: const Color(0xFFB8D4E8),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroductionSection extends StatelessWidget {
  const _IntroductionSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acerca de App Citas',
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 26 : 32,
            fontWeight: FontWeight.w600,
            color: WelcomeScreen._primaryBlue,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Container(
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          decoration: BoxDecoration(
            color: WelcomeScreen._white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4E5F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeScreen._softBlue.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'Somos una plataforma confiable diseñada para conectar profesionales y clientes. Con tecnología segura y una interfaz intuitiva, facilitamos la gestión de citas de forma rápida, clara y eficiente.',
            style: GoogleFonts.dmSans(
              fontSize: isMobile ? 15 : 16,
              height: 1.7,
              color: WelcomeScreen._darkText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServicesDescriptionSection extends StatelessWidget {
  const _ServicesDescriptionSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nuestros servicios',
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 26 : 32,
            fontWeight: FontWeight.w600,
            color: WelcomeScreen._primaryBlue,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Container(
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          decoration: BoxDecoration(
            color: WelcomeScreen._white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4E5F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeScreen._softBlue.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServicePoint(
                icon: Icons.event_available_rounded,
                title: 'Reserva de citas',
                description:
                    'Agenda tus citas en pocos pasos con disponibilidad en tiempo real.',
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Divider(
                color: const Color(0xFFE0E8F0),
                thickness: 1,
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _ServicePoint(
                icon: Icons.notifications_active_rounded,
                title: 'Recordatorios automaticos',
                description:
                    'Recibe notificaciones para no perderte ninguna cita.',
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Divider(
                color: const Color(0xFFE0E8F0),
                thickness: 1,
              ),
              SizedBox(height: isMobile ? 16 : 20),
              _ServicePoint(
                icon: Icons.security_rounded,
                title: 'Seguridad garantizada',
                description:
                    'Tus datos estan protegidos con encriptacion empresarial.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServicePoint extends StatelessWidget {
  const _ServicePoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F0F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: isMobile ? 22 : 26,
            color: WelcomeScreen._secondaryBlue,
          ),
        ),
        SizedBox(width: isMobile ? 14 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: WelcomeScreen._primaryBlue,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.dmSans(
                  fontSize: isMobile ? 13 : 14,
                  height: 1.5,
                  color: WelcomeScreen._lightText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                WelcomeScreen._primaryBlue,
                WelcomeScreen._secondaryBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: WelcomeScreen._primaryBlue.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Listo para empezar?',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.w600,
                  color: WelcomeScreen._white,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'Registrate o inicia sesion para gestionar tus citas de forma segura.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: isMobile ? 14 : 15,
                  height: 1.6,
                  color: const Color(0xFFB8D4E8),
                ),
              ),
              SizedBox(height: isMobile ? 24 : 32),
              SizedBox(
                width: double.infinity,
                height: isMobile ? 52 : 58,
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
                      WelcomeScreen._white,
                    ),
                    foregroundColor: const WidgetStatePropertyAll(
                      WelcomeScreen._primaryBlue,
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    overlayColor: WidgetStatePropertyAll(
                      Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),
        Text(
          'Acceso seguro - Registro gratuito',
          style: GoogleFonts.dmSans(
            fontSize: isMobile ? 12 : 13,
            color: WelcomeScreen._lightText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
