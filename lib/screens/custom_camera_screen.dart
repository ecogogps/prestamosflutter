// custom_camera_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart'; // Ajusta la ruta a tus colores

class CustomCameraScreen extends StatefulWidget {
  final CameraLensDirection requiredLensDirection;
  final bool isSquareGuide;

  const CustomCameraScreen({
    super.key,
    required this.requiredLensDirection,
    required this.isSquareGuide,
  });

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      // Obtener todas las cámaras del dispositivo
      final cameras = await availableCameras();
      
      // Filtrar estricamente por la dirección requerida (Frontal o Trasera)
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == widget.requiredLensDirection,
        orElse: () => cameras.first, // Fallback por seguridad
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
      if (mounted) Navigator.pop(context); // Salir si hay error
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized || _controller!.value.isTakingPicture) {
      return;
    }
    try {
      final XFile picture = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, picture.path); // Devuelve la ruta de la foto
      }
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Calcular el aspecto de la máscara
    final screenSize = MediaQuery.of(context).size;
    final maskWidth = screenSize.width * 0.8;
    final maskHeight = widget.isSquareGuide ? maskWidth : maskWidth * 0.63; // 0.63 es prop. de ID

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Preview de la cámara a pantalla completa
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_controller!),
          ),

          // 2. Máscara oscura con recorte transparente (Guía visual)
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black54,
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: maskWidth,
                      height: maskHeight,
                      decoration: BoxDecoration(
                        color: Colors.black, // Se volverá transparente por el blend mode
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bordes guía verdes
          Center(
            child: Container(
              width: maskWidth,
              height: maskHeight,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // 4. Controles (Arriba: Atrás | Abajo: Tomar Foto)
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
