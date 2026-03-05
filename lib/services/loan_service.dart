
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanService {
  final _supabase = Supabase.instance.client;

  Future<void> requestLoan({
    required double amount,
    required String term,
    required String method,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _supabase.from('loans').insert({
      'user_id': userId,
      'amount': amount,
      'payment_term': term,
      'payment_method': method,
      'status': 'pending',
    });
  }
}
