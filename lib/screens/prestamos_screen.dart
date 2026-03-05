import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  late final Stream<List<Map<String, dynamic>>> _loansStream;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    _loansStream = Supabase.instance.client
        .from('loans')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId ?? '')
        .order('created_at', ascending: false);
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'accepted': return 'Aceptado';
      case 'rejected': return 'Rechazado';
      case 'paid': return 'Pagado';
      case 'overdue': return 'Vencido';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'accepted': return AppColors.primary;
      case 'rejected': return Colors.red;
      case 'paid': return Colors.blue;
      case 'overdue': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mis Préstamos', style: TextStyle(color: AppColors.text)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => context.go('/'),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _loansStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final loans = snapshot.data ?? [];

          if (loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_edu, size: 80, color: Colors.white10),
                  const SizedBox(height: 20),
                  const Text('No tienes préstamos registrados', style: TextStyle(color: Colors.white30, fontSize: 18)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => context.push('/solicitar'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                    child: const Text('Solicitar mi primer préstamo'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              final status = loan['status'] as String;
              final amount = loan['amount'] as num;
              final date = DateTime.parse(loan['created_at']);
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${NumberFormat("#,##0", "es_MX").format(amount)} MXN',
                              style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(formattedDate, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getStatusColor(status).withOpacity(0.5)),
                          ),
                          child: Text(
                            _getStatusLabel(status),
                            style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoItem('Plazo', loan['payment_term']),
                        _infoItem('Forma de Pago', loan['payment_method']),
                      ],
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

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
