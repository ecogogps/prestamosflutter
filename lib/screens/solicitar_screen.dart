
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';

class SolicitarScreen extends StatefulWidget {
  const SolicitarScreen({super.key});

  @override
  State<SolicitarScreen> createState() => _SolicitarScreenState();
}

class _SolicitarScreenState extends State<SolicitarScreen> {
  double _montoSolicitado = 0;
  String _plazoPago = '7 días';
  String _formaPago = 'Pago semanal';
  bool _isLoading = false;

  final List<String> _plazos = ['7 días', '15 días', '30 días'];
  final List<String> _formas = ['Pago semanal', 'Pago quincenal', 'Pago único'];

  Future<void> _enviarSolicitud() async {
    if (_montoSolicitado <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un monto válido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client.from('loans').insert({
        'user_id': userId,
        'amount': _montoSolicitado,
        'payment_term': _plazoPago,
        'payment_method': _formaPago,
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Préstamos rápidos y seguros',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '¡Hola!',
              style: TextStyle(color: AppColors.text, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '¿Cuánto dinero necesitas?',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            
            // Widget de Monto
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '\$${_montoSolicitado.toInt()} MXN',
                    style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _montoSolicitado.clamp(0, 50500),
                      min: 0,
                      max: 50500,
                      divisions: 101, // 50500 / 500 = 101 pasos exactos de 500
                      onChanged: (val) {
                        setState(() {
                          // Limitamos a 50300 visualmente si es necesario, o dejamos 50500 para redondear
                          _montoSolicitado = val > 50300 ? 50300 : val;
                        });
                      },
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$0', style: TextStyle(color: Colors.white30)),
                      Text('hasta \$50,300 MXN', style: TextStyle(color: Colors.white30)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            const Text('Plazo de pago', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            _buildDropdown(_plazoPago, _plazos, (val) => setState(() => _plazoPago = val!)),
            
            const SizedBox(height: 20),
            
            const Text('Forma de pago', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            _buildDropdown(_formaPago, _formas, (val) => setState(() => _formaPago = val!)),
            
            const SizedBox(height: 50),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enviarSolicitud,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Solicitar préstamo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.background,
          style: const TextStyle(color: AppColors.text, fontSize: 16),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
