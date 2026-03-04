import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF212529),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.network(
              'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // Widget de Límite de Préstamo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3136),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Tu límite de préstamo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '8,851.67 MXN',
                    style: TextStyle(
                      color: Color(0xFF71AF57),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF71AF57),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Solicitar ahora',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Iconos rápidos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickInfo(FontAwesomeIcons.bolt, 'rápido'),
                _buildDivider(),
                _buildQuickInfo(FontAwesomeIcons.handHoldingHeart, 'conveniente'),
                _buildDivider(),
                _buildQuickInfo(FontAwesomeIcons.shieldHalved, 'seguro'),
              ],
            ),

            const SizedBox(height: 40),

            // Sección de Pasos
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
            const SizedBox(height: 24),

            _buildStep(1, 'Complete la información', FontAwesomeIcons.fileLines),
            _buildStep(2, 'Acceso a los préstamos', FontAwesomeIcons.moneyBillTransfer),
            _buildStep(3, 'Presentar la solicitud', FontAwesomeIcons.paperPlane),

            const SizedBox(height: 30),

            // Footer
            const Text(
              'Plataforma de préstamos en linea segura y confiable',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, color: const Color(0xFF71AF57), size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('|', style: TextStyle(color: Colors.white24)),
    );
  }

  Widget _buildStep(int step, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF71AF57).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Color(0xFF71AF57),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El paso $step',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          FaIcon(icon, color: Colors.white24, size: 22),
        ],
      ),
    );
  }
}