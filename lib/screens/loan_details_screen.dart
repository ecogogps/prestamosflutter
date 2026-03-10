import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';

class LoanDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> loan;

  const LoanDetailsScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final requestedAmount = (loan['amount'] as num).toDouble();
    final termDays = loan['payment_term'] as int;
    
    // Cálculos según reglas del usuario
    final amountReceived = requestedAmount * 0.6;
    final totalInterest = requestedAmount * 0.4;
    final initialTotal = amountReceived + totalInterest;

    // Fechas
    final disbursedAtStr = loan['disbursed_at'];
    final DateTime disbursementDate = disbursedAtStr != null 
        ? DateTime.parse(disbursedAtStr) 
        : DateTime.now();
    final DateTime expirationDate = disbursementDate.add(Duration(days: termDays));
    
    // Cálculo de mora (5% diario)
    final now = DateTime.now();
    int delayDays = 0;
    double lateInterest = 0;
    if (now.isAfter(expirationDate)) {
      delayDays = now.difference(expirationDate).inDays;
      if (delayDays > 0) {
        lateInterest = initialTotal * 0.05 * delayDays;
      }
    }

    final totalToPay = initialTotal + lateInterest;
    final loanAmountDisplay = requestedAmount + lateInterest;

    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat("#,##0.00", "es_MX");

    return Scaffold(
      backgroundColor: const Color(0xFFFDBB2D).withOpacity(0.1), // Fondo amarillento suave como la imagen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Fondo naranja/amarillo superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFFFDBB2D),
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Cabecera estilo imagen
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.savings, color: Colors.green, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text('Préstamo', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderItem(currencyFormat.format(loanAmountDisplay), 'Monto de préstamo'),
                          _buildHeaderItem(dateFormat.format(disbursementDate), 'Fecha de desembolso'),
                          _buildHeaderItem(dateFormat.format(expirationDate), 'Fecha de vencimiento'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Card de Detalles
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCF8F1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1E4D1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Detalles', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _buildDetailRow('Plazo del préstamo', '$termDays días'),
                      _buildDetailRow('Monto recibido', currencyFormat.format(amountReceived)),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFF1E4D1)),
                      const SizedBox(height: 16),
                      _buildDetailRow('Interés total', currencyFormat.format(totalInterest)),
                      if (lateInterest > 0)
                        _buildDetailRow('Interés por mora ($delayDays días)', currencyFormat.format(lateInterest), isNegative: true),
                      _buildDetailRow('Monto a pagar', currencyFormat.format(totalToPay), isBold: true),
                      _buildDetailRow('Fecha de desembolso', dateFormat.format(disbursementDate)),
                      _buildDetailRow('Fecha de vencimiento', dateFormat.format(expirationDate)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Botón Reembolso
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    width: 160,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _showRefundModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reembolso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFDBB2D), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 15)),
          Text(
            isNegative ? '+\$$value' : '\$$value', 
            style: TextStyle(
              color: isNegative ? Colors.red : Colors.black87, 
              fontSize: 15, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal
            )
          ),
        ],
      ),
    );
  }

  void _showRefundModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información de Pago', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '646168200484848484820',
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppColors.primary),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: '646168200484848484820'));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clave copiada al portapapeles')));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Banco MERCADO PAGO (STP)', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('¿Cómo realizar la transferencia?', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInstructionItem('1. Copia la clave de pago'),
            _buildInstructionItem('2. Dirige a cualquier banca móvil de tu preferencia'),
            _buildInstructionItem('3. Realiza una transferencia normal con la clave que te corresponde'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(color: Colors.black54, fontSize: 14)),
    );
  }
}