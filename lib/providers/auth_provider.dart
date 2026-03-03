
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  Session? _session;

  AuthProvider() {
    _session = _supabase.auth.currentSession;
    _supabase.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _session != null;
  Session? get session => _session;

  Future<bool> signInWithOtp(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
      return true;
    } catch (e) {
      debugPrint('Error en signInWithOtp: $e');
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String token) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: token,
      );
      return response.session != null;
    } catch (e) {
      debugPrint('Error en verifyOtp: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
