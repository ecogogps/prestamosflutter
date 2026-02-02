import 'package:flutter/material.dart';
import 'package:myapp/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final success = await _authService.login(email, password);
      if (success) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _isAuthenticated = false;
    _setLoading(false);
    notifyListeners();
  }
}
