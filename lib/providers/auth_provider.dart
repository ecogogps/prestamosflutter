import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _phoneNumber;

  bool get isLoading => _isLoading;
  String? get phoneNumber => _phoneNumber;
  bool get isAuthenticated => Supabase.instance.client.auth.currentSession != null;

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  Future<void> loginWithPhone(String phone) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.sendOtp(phone);
      _phoneNumber = phone;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.verifyOtp(_phoneNumber!, token);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }
}
