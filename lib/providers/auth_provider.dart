
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<bool> signInWithOtp(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phone,
        channel: OtpChannel.sms,
      );
      return true;
    } on AuthException catch (e) {
      developer.log('Error de Supabase Auth: ${e.message}', name: 'auth', error: e);
      rethrow; // Lanzamos para que la UI pueda mostrar el error específico
    } catch (e) {
      developer.log('Error inesperado en signInWithOtp: $e', name: 'auth');
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String token) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      return response.user != null;
    } catch (e) {
      developer.log('Error en verifyOtp: $e', name: 'auth');
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}
