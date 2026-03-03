import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Enviar código OTP al celular
  Future<void> sendOtp(String phoneNumber) async {
    // Aseguramos que el número tenga el prefijo +52
    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+52$phoneNumber';
    
    await _supabase.auth.signInWithOtp(
      phone: formattedPhone,
    );
  }

  // Verificar el código OTP recibido
  Future<AuthResponse> verifyOtp(String phoneNumber, String token) async {
    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+52$phoneNumber';
    
    return await _supabase.auth.verifyOTP(
      phone: formattedPhone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;
}
