import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mis Préstamos', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Préstamo Actual'),
              Tab(text: 'Préstamo Histórico'),
            ],
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase
              .from('loans')
              .stream(primaryKey: ['id'])
              .eq('user_id', userId ?? '')
              .order('created_at', ascending: false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar préstamos: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final allLoans = snapshot.data ?? [];

            // Filtrar según especificaciones
            final currentLoans = allLoans.where((l) {
              final s = l['status'];
              return s != 'rejected' && s != 'paid';
            }).toList();

            final historyLoans = allLoans.where((l) {
              final s = l['status'];
              return s == 'rejected' || s == 'paid';
            }).toList();

            return TabBarView(
              children: [
                _buildLoanList(currentLoans, 'No tienes préstamos actuales activos'),
                _buildLoanList(historyLoans, 'No tienes historial de préstamos'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoanList(List<Map<String, dynamic>> loans, String emptyMessage) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        final amount = loan['amount'] ?? 0;
        final status = loan['status'] ?? 'pending';
        final term = loan['payment_term']?.toString() ?? '0';
        final method = loan['payment_method'] ?? 'N/A';
        final createdAt = loan['created_at'] != null 
            ? DateTime.parse(loan['created_at']) 
            : DateTime.now();

        return InkWell(
          onTap: status == 'accepted' || status == 'overdue'
              ? () => Navigator.pushNamed(context, '/loan-details', arguments: loan)
              : null,
          child: _buildLoanCard(amount, status, term, method, createdAt),
        );
      },
    );
  }

  Widget _buildLoanCard(dynamic amount, String status, String term, String method, DateTime date) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'ACEPTADO';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'RECHAZADO';
        break;
      case 'paid':
        statusColor = Colors.blue;
        statusText = 'PAGADO';
        break;
      case 'overdue':
        statusColor = Colors.orange;
        statusText = 'VENCIDO';
        break;
      default:
        statusColor = Colors.amber;
        statusText = 'PENDIENTE';
    }

    final formattedDate = DateFormat('dd/MM/yyyy').format(date); 

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${NumberFormat("#,##0", "es_MX").format(amount)} MXN',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDetailItem(Icons.calendar_today, 'Plazo', '$term días'),
              const SizedBox(width: 24),
              _buildDetailItem(Icons.payments, 'Pago', method),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}