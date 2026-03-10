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
      backgroundColor: AppColors.background, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // CABECERA 
            // ==========================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.savings, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Préstamo', 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 20
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderItem(currencyFormat.format(loanAmountDisplay), 'Monto de\npréstamo'),
                      _buildHeaderItem(dateFormat.format(disbursementDate), 'Fecha de\ndesembolso'),
                      _buildHeaderItem(dateFormat.format(expirationDate), 'Fecha de\nvencimiento'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // ==========================================
            // TARJETA DE DETALLES
            // ==========================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12), 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detalles', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  _buildDetailRow('Plazo del préstamo', '$termDays días'),
                  _buildDetailRow('Monto recibido', '\$${currencyFormat.format(amountReceived)}'),
                  
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow('Interés total', '\$${currencyFormat.format(totalInterest)}'),
                  if (lateInterest > 0)
                    _buildDetailRow('Interés por mora ($delayDays días)', '+\$${currencyFormat.format(lateInterest)}', isNegative: true),
                  _buildDetailRow('Monto a pagar', '\$${currencyFormat.format(totalToPay)}', isBold: true),
                  
                  const SizedBox(height: 16),
                  _buildDetailRow('Fecha de desembolso', dateFormat.format(disbursementDate)),
                  _buildDetailRow('Fecha de vencimiento', dateFormat.format(expirationDate)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // ==========================================
            // BOTÓN REEMBOLSO 
            // ==========================================
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 40),
                child: SizedBox(
                  width: 160,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _showRefundModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Reembolso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value, 
            textAlign: TextAlign.center, 
            style: const TextStyle(
              color: AppColors.primary, 
              fontSize: 16, 
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            textAlign: TextAlign.center, 
            style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.3)
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          Text(
            value, 
            style: TextStyle(
              color: isNegative ? Colors.redAccent : Colors.white, 
              fontSize: 14, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500
            )
          ),
        ],
      ),
    );
  }

  void _showRefundModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: AppColors.background, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView( 
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información de Pago', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '646168200484848484820',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: AppColors.primary),
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: '646168200484848484820'));
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Clave copiada al portapapeles', style: TextStyle(color: Colors.white)),
                              backgroundColor: AppColors.primary,
                            )
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                const Text('Banco MERCADO PAGO (STP)', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                
                const Text('¿Cómo realizar la transferencia?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                _buildInstructionItem('1. Copia la clave de pago.'),
                _buildInstructionItem('2. Dirige a cualquier banca móvil de tu preferencia.'),
                _buildInstructionItem('3. Realiza una trasferencia normal con la clave que te corresponde.'),
                const SizedBox(height: 10), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
