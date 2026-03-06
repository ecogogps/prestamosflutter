import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF71AF57);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF212529),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Image.network(
              'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
              height: 120,
            ),
            const SizedBox(height: 30),
            
            // Widget de Límite
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [brandColor, brandColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Tu límite de préstamo',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '8,851.67 MXN',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.push('/solicitar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: brandColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Solicitar ahora', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniIcon(Icons.bolt, 'Rápido'),
                _buildMiniIcon(Icons.thumb_up, 'Conveniente'),
                _buildMiniIcon(Icons.security, 'Seguro'),
              ],
            ),
            
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Préstamo en solo 3 pasos',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            
            // Pasamos el brandColor a los pasos para mantener la coherencia de la marca
            _buildStep(1, Icons.edit_document, 'Complete la información', brandColor),
            _buildStep(2, Icons.assignment_ind, 'Acceso a los préstamos', brandColor),
            _buildStep(3, Icons.credit_card, 'Presentar la solicitud', brandColor),
            
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, color: brandColor, size: 16),
                SizedBox(width: 8),
                Text(
                  'Plataforma de préstamos en línea segura y confiable',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF71AF57), size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // Se modificó la estructura para que sea igual a la captura
  Widget _buildStep(int num, IconData icon, String title, Color iconBgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Contenedor del icono estilo captura (cuadro redondeado con fondo de color)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor, // Utiliza tu color de marca
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'El Paso $num', 
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                title, 
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
