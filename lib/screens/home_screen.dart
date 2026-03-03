
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://i.postimg.cc/tTDNDSfZ/MONEYBIC-SIN-FONDO.png',
          height: 30,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 80),
              const SizedBox(height: 24),
              const Text(
                '¡Bienvenido a MoneyBic!',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sesión iniciada con éxito.',
                style: TextStyle(color: AppColors.text.withOpacity(0.7), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
