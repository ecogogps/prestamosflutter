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
  double _monto = 500.0;
  String _plazo = '7 días';
  String _formaPago = 'Pago semanal';
  bool _isLoading = false;

  final List<String> _plazos = ['7 días', '15 días', '30 días'];
  final List<String> _formasPago = ['Pago semanal', 'Pago quincenal', 'Pago único'];

  Future<void> _solicitarPrestamo() async {
    if (_monto < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto mínimo es de $500')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Usuario no autenticado';

      await Supabase.instance.client.from('loans').insert({
        'user_id': user.id,
        'amount': _monto,
        'payment_term': _plazo,
        'payment_method': _formaPago,
        'status': 'pending',
      });

      if (mounted) {
        context.pushReplacement('/prestamos');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al solicitar: $e')),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Image.network(
              'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Préstamos rápidos y seguros',
              style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('¡Hola!', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('¿Cuánto dinero necesitas?', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ),
            const SizedBox(height: 40),
            
            // Widget de monto
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '\$${_monto.toInt()}',
                    style: const TextStyle(color: AppColors.primary, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _monto,
                    min: 0,
                    max: 50500,
                    divisions: 101,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white10,
                    onChanged: (value) {
                      setState(() {
                        _monto = value > 50300 ? 50300 : value;
                      });
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text('\$0', style: TextStyle(color: Colors.white30)),
                      Text('hasta \$50,300 MXN', style: TextStyle(color: Colors.white30)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Plazo
            _buildSelector('Plazo de pago', _plazo, _plazos, (val) => setState(() => _plazo = val!)),
            
            const SizedBox(height: 20),
            
            // Forma de Pago
            _buildSelector('Forma de pago', _formaPago, _formasPago, (val) => setState(() => _formaPago = val!)),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _solicitarPrestamo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Solicitar préstamo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 10),
        Container(
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
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
