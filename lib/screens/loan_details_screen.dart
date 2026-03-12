import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';

class LoanDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> loan;

  const LoanDetailsScreen({super.key, required this.loan});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _details;

  @override
  void initState() {
    super.initState();
    _fetchLoanDetails();
  }

  Future<void> _fetchLoanDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _supabase.rpc(
        'get_loan_details',
        params: {'p_loan_id': widget.loan['id']},
      );

      setState(() {
        _details = Map<String, dynamic>.from(response as Map);
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Error del servidor: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
        _isLoading = false;
      });
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Calculando tu préstamo...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: Main => MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchLoanDetails,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildContent(_details!);
  }

  Widget _buildContent(Map<String, dynamic> d) {
    final currencyFormat = NumberFormat("#,##0.00", "es_MX");
    final dateFormat = DateFormat('dd/MM/yyyy');

    final disbursementDate = DateTime.parse(d['disbursement_date']);
    final expirationDate = DateTime.parse(d['expiration_date']);

    final bool isOverdue = d['is_overdue'] == true;
    final int delayDays = d['delay_days'] as int;
    final double lateInterest = (d['late_interest'] as num).toDouble();
    final double requestedAmount = (d['requested_amount'] as num).toDouble();

    return SingleChildScrollView(
      child: Column(
        children: [
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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.5)),
                        ),
                        child: const Text('VENCIDO',
                            style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderItem(
                      '\$${currencyFormat.format(requestedAmount)}',
                      'Monto de\npréstamo',
                    ),
                    _buildHeaderItem(
                      dateFormat.format(disbursementDate),
                      'Fecha de\ndesembolso',
                    ),
                    _buildHeaderItem(
                      dateFormat.format(expirationDate),
                      'Fecha de\nvencimiento',
                      isAlert: isOverdue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                const Text('Detalles',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildDetailRow('Plazo del préstamo', '${d['payment_term']} días'),
                _buildDetailRow('Forma de pago', d['payment_method']),
                _buildDetailRow('Monto recibido', '\$${currencyFormat.format(d['amount_received'])}'),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                _buildDetailRow('Interés total', '\$${currencyFormat.format(d['total_interest'])}'),
                if (lateInterest > 0)
                  _buildDetailRow(
                    'Mora ($delayDays días · 5%/día)',
                    '+\$${currencyFormat.format(lateInterest)}',
                    isNegative: true,
                  ),
                _buildDetailRow(
                  'Monto a pagar',
                  '\$${currencyFormat.format(d['total_to_pay'])}',
                  isBold: true,
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                _buildDetailRow('Fecha de desembolso', dateFormat.format(disbursementDate)),
                _buildDetailRow('Fecha de vencimiento', dateFormat.format(expirationDate),
                    isNegative: isOverdue),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (delayDays >= 5)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          final initialTotal = (d['amount_received'] as num).toDouble() +
                              (d['total_interest'] as num).toDouble();
                          final promoData = Map<String, dynamic>.from(d);
                          promoData['total_to_pay'] = initialTotal;
                          _showRefundModal(context, promoData, isPromo: true);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Pagar préstamo sin intereses por mora',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 160,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _showRefundModal(context, d),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Reembolso',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(String value, String label, {bool isAlert = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isAlert ? Colors.orange : AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          Text(value,
              style: TextStyle(
                color: isNegative ? Colors.redAccent : Colors.white,
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              )),
        ],
      ),
    );
  }

  void _showRefundModal(BuildContext context, Map<String, dynamic> d, {bool isPromo = false}) {
    final currencyFormat = NumberFormat("#,##0.00", "es_MX");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Información de Pago',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    if (isPromo)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: const Text('CERO MORA',
                            style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total a pagar: \$${currencyFormat.format(d['total_to_pay'])} MXN',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: AppColors.primary),
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: '646168200484848484820'));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Clave copiada al portapapeles',
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Banco MERCADO PAGO (STP)',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                const Text('¿Cómo realizar la transferencia?',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildInstructionItem('1. Copia la clave de pago.'),
                _buildInstructionItem('2. Dirige a cualquier banca móvil de tu preferencia.'),
                _buildInstructionItem(
                    '3. Realiza una transferencia normal con la clave que te corresponde.'),
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
            child: Text(text,
                style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
