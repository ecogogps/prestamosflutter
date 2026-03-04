import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    const Color primaryColor = Color(0xFF71AF57);
    const Color backgroundColor = Color(0xFF121212);

    return Scaffold(
      backgroundColor: backgroundColor,
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo mediano
              Image.network(
                'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, size: 80, color: primaryColor),
              ),
              const SizedBox(height: 30),

              // Widget: Tu límite de préstamo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tu límite de préstamo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '8,851.67',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'MXN',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Solicitar ahora',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Fila de confianza
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTrustItem(Icons.flash_on, 'rápido'),
                  _buildSeparator(),
                  _buildTrustItem(Icons.thumb_up, 'conveniente'),
                  _buildSeparator(),
                  _buildTrustItem(Icons.shield, 'seguro'),
                ],
              ),

              const SizedBox(height: 40),

              // Sección 3 Pasos
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
              const SizedBox(height: 20),
              _buildStepItem('1', 'Complete la información', Icons.edit_document),
              _buildStepItem('2', 'Acceso a los préstamos', Icons.account_balance_wallet),
              _buildStepItem('3', 'Presentar la solicitud', Icons.send),

              const SizedBox(height: 40),

              // Texto de confianza inferior
              const Text(
                'Plataforma de préstamos en linea segura y confiable',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF71AF57)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('|', style: TextStyle(color: Colors.white24)),
    );
  }

  Widget _buildStepItem(String number, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF71AF57),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Icon(icon, color: const Color(0xFF71AF57), size: 24),
        ],
      ),
    );
  }
}