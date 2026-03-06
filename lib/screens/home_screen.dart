
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF71AF57);
    const bgColorDark = Color(0xFF181B1F); // Fondo aún más oscuro para contrastar el brillo
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: bgColorDark,
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
      body: Stack(
        children: [
          // 1. LUZ AMBIENTAL DE FONDO (Resplandor radial central)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withOpacity(0.12),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          
          // CONTENIDO PRINCIPAL
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Logo
                Image.network(
                  'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                
                // 2. TARJETA PRINCIPAL CON EFECTO BRILLANTE (GLOW & REFLEJO)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.8), // Reflejo de luz fuerte arriba
                        brandColor.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.15, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: brandColor.withOpacity(0.35),
                        blurRadius: 40,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.5),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF5A9E40),
                          Color(0xFF386629),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tu límite de préstamo',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9), 
                            fontSize: 16,
                            shadows: const [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))]
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '8,851.67 MXN',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 34, 
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () => context.push('/solicitar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: brandColor,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 5,
                              shadowColor: Colors.black45,
                            ),
                            child: const Text(
                              'Solicitar ahora', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 28),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMiniIcon(Icons.bolt, 'Rápido', brandColor),
                    _buildMiniIcon(Icons.thumb_up_alt_rounded, 'Conveniente', brandColor),
                    _buildMiniIcon(Icons.security, 'Seguro', brandColor),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Préstamo en solo 3 pasos',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildStep(
                  num: 1, 
                  icon: Icons.edit_document, 
                  title: 'Complete la información', 
                  subtitle: 'Proporcione sus datos personales',
                  brandColor: brandColor,
                ),
                _buildStep(
                  num: 2, 
                  icon: Icons.assignment_ind_rounded, 
                  title: 'Acceso a los préstamos', 
                  subtitle: 'Revise y elija la mejor opción',
                  brandColor: brandColor,
                ),
                _buildStep(
                  num: 3, 
                  icon: Icons.checklist_rtl_rounded, 
                  title: 'Presentar la solicitud', 
                  subtitle: 'Envíe el formulario completado',
                  brandColor: brandColor,
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, color: brandColor.withOpacity(0.8), size: 14),
                    const SizedBox(width: 8),
                    const Text(
                      'Plataforma de préstamos en línea segura y confiable.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniIcon(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18, shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 8)]),
        const SizedBox(width: 6),
        Text(
          label, 
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)
        ),
      ],
    );
  }

  Widget _buildStep({
    required int num, 
    required IconData icon, 
    required String title, 
    required String subtitle,
    required Color brandColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF33383D),
            Color(0xFF23272B),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  brandColor.withOpacity(0.9),
                  const Color(0xFF4A8035),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: brandColor.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El Paso $num', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle, 
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          
          const Icon(
            Icons.chevron_right_rounded, 
            color: Colors.white38, 
            size: 28
          ),
        ],
      ),
    );
  }
}
