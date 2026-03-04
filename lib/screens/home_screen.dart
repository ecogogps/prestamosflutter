
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    const brandColor = Color(0xFF71AF57);
    const bgColor = Color(0xFF212529);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo central grande
              Image.network(
                'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              // Widget de Límite de Préstamo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [brandColor, Color(0xFF5A8E45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tu límite de préstamo',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'MXN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: brandColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Solicitar ahora',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Beneficios rápidos con capitalización
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BenefitItem(icon: Icons.flash_on, label: 'Rápido'),
                  _BenefitItem(icon: Icons.thumb_up, label: 'Conveniente'),
                  _BenefitItem(icon: Icons.security, label: 'Seguro'),
                ],
              ),
              const SizedBox(height: 40),

              // Título de la sección de pasos
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Préstamo en solo 3 pasos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sección de pasos con contenedores blancos
              _StepCard(
                icon: FontAwesomeIcons.fileLines,
                title: 'El paso 1',
                subtitle: 'Complete la información',
                brandColor: brandColor,
              ),
              const SizedBox(height: 12),
              _StepCard(
                icon: FontAwesomeIcons.stamp,
                title: 'El paso 2',
                subtitle: 'Acceso a los préstamos',
                brandColor: brandColor,
              ),
              const SizedBox(height: 12),
              _StepCard(
                icon: FontAwesomeIcons.paperPlane,
                title: 'El paso 3',
                subtitle: 'Presentar la solicitud',
                brandColor: brandColor,
              ),

              const SizedBox(height: 40),

              // Footer de confianza con icono
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, color: brandColor, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Plataforma de préstamos en linea segura y confiable',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF71AF57), size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color brandColor;

  const _StepCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: brandColor, size: 28),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
