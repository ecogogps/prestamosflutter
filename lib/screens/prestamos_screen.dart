import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_colors.dart';
import 'package:intl/intl.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  final _supabase = Supabase.instance.client;

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pendiente';
      case 'accepted': return 'Aceptado';
      case 'rejected': return 'Rechazado';
      case 'paid': return 'Pagado';
      case 'overdue': return 'Vencido';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'accepted': return AppColors.primary;
      case 'rejected': return Colors.redAccent;
      case 'paid': return Colors.blueAccent;
      case 'overdue': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mis Préstamos', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: userId == null 
        ? const Center(child: Text('Inicia sesión para ver tus préstamos'))
        : StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase
                .from('loans')
                .stream(primaryKey: ['id'])
                .eq('user_id', userId)
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
              }

              final loans = snapshot.data ?? [];

              if (loans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_edu, size: 80, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 20),
                      const Text('Aún no tienes solicitudes', style: TextStyle(color: Colors.white30, fontSize: 18)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  final amount = loan['amount'];
                  final status = loan['status'] as String;
                  final date = DateTime.parse(loan['created_at']).toLocal();
                  final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.account_balance_wallet, color: _getStatusColor(status)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${NumberFormat("#,##0", "es_MX").format(amount)} MXN',
                                style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(formattedDate, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
