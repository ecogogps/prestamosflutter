
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userPhone = authProvider.session?.user.phone ?? 'No disponible';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Avatar y Nombre
              Center(
                child: Column(
                  children: [
                    Image.network(
                      'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cliente MoneyBic',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userPhone,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Opciones de Perfil
              _buildProfileItem(Icons.history, 'Mis Préstamos', () {}),
              _buildProfileItem(Icons.help_outline, 'Centro de Ayuda', () {}),
              _buildProfileItem(Icons.description, 'Términos y Condiciones', () {}),
              _buildProfileItem(Icons.privacy_tip_outlined, 'Política de Privacidad', () {}),
              
              const SizedBox(height: 24),
              const Divider(color: Colors.white10),
              const SizedBox(height: 24),
              
              // Botón Cerrar Sesión
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => authProvider.signOut(),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.text, fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      ),
    );
  }
}
