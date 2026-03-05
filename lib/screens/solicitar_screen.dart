
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/loan_service.dart';

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

  final LoanService _loanService = LoanService();

  final List<String> _plazos = ['7 días', '14 días', '30 días'];
  final List<String> _formasPago = ['Pago semanal', 'Pago quincenal', 'Pago mensual'];

  Future<void> _submitRequest() async {
    setState(() => _isLoading = true);
    try {
      await _loanService.requestLoan(
        amount: _monto,
        term: _plazo,
        method: _formaPago,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada correctamente')),
        );
        context.go('/home');
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
    const brandColor = Color(0xFF71AF57);
    
    return Scaffold(
      backgroundColor: const Color(0xFF212529),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                'https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png',
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Préstamos rápidos y seguros',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              '¡Hola!',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              '¿Cuánto dinero necesitas?',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: brandColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '\$${_monto.toInt()} MXN',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _monto,
                    min: 0,
                    max: 50300,
                    divisions: 50300 ~/ 500,
                    activeColor: brandColor,
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      setState(() => _monto = value);
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$0', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text('(desde \$0 hasta \$50,300 MXN)', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            _buildLabel('Plazo de pago'),
            _buildDropdown(_plazo, _plazos, (val) => setState(() => _plazo = val!)),
            const SizedBox(height: 20),
            _buildLabel('Forma de pago'),
            _buildDropdown(_formaPago, _formasPago, (val) => setState(() => _formaPago = val!)),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Solicitar préstamo',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF212529),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(color: Colors.white)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
