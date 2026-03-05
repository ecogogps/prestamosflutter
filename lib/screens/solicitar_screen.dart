import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';

class SolicitarScreen extends StatefulWidget {
  const SolicitarScreen({super.key});

  @override
  State<SolicitarScreen> createState() => _SolicitarScreenState();
}

class _SolicitarScreenState extends State<SolicitarScreen> {
  double _amount = 0;
  String _plazo = '7 días';
  String _formaPago = 'Pago semanal';
  bool _isLoading = false;

  final List<String> _plazos = ['7 días', '15 días', '30 días'];
  final List<String> _formasPago = ['Pago semanal', 'Pago quincenal', 'Pago mensual'];

  Future<void> _enviarSolicitud() async {
    if (_amount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto mínimo es de \$500')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('loans').insert({
        'user_id': user.id,
        'amount': _amount,
        'payment_term': _plazo,
        'payment_method': _formaPago,
        'status': 'pending',
      });

      if (mounted) {
        context.push('/prestamos');
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
          onPressed: () => context.pop(),
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
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Préstamos rápidos y seguros',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              '¡Hola!',
              style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '¿Cuánto dinero necesitas?',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 50),
            
            // Widget de monto seleccionado
            Center(
              child: Text(
                '\$${_amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white12,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.2),
                valueIndicatorBackgroundColor: AppColors.primary,
              ),
              child: Slider(
                value: _amount,
                min: 0,
                max: 50500, // Ajustado para permitir incrementos exactos
                divisions: 101, // 50500 / 500 = 101
                onChanged: (value) {
                  setState(() {
                    // Limitamos visualmente a 50300 pero el slider permite el rango para divisiones limpias
                    _amount = value > 50300 ? 50300 : value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('\$0', style: TextStyle(color: Colors.white30)),
                  Text('hasta \$50,300 MXN', style: TextStyle(color: Colors.white30)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Plazo de pago
            const Text('Plazo de pago', style: TextStyle(color: AppColors.text, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _plazo,
                  isExpanded: true,
                  dropdownColor: AppColors.background,
                  style: const TextStyle(color: Colors.white),
                  items: _plazos.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _plazo = value!),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Forma de pago
            const Text('Forma de pago', style: TextStyle(color: AppColors.text, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _formaPago,
                  isExpanded: true,
                  dropdownColor: AppColors.background,
                  style: const TextStyle(color: Colors.white),
                  items: _formasPago.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _formaPago = value!),
                ),
              ),
            ),
            
            const SizedBox(height: 50),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enviarSolicitud,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      'Solicitar préstamo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
