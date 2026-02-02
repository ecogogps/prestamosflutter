import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  bool _isLoading = false;

  AuthProvider() {
    _loadTokenFromStorage();
  }

  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

  void _loadTokenFromStorage() {
    // In a real app, you would load this from flutter_secure_storage
    // For now, we'll assume the user is logged out on app start.
    _token = null;
    notifyListeners();
  }

  Future<bool> login(String user, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.login(user, password);
      if (token != null) {
        _token = token;
        // In a real app, you would save this to flutter_secure_storage
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error, maybe show a snackbar
      debugPrint('Login failed: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    // Here you would also remove the token from secure storage
    notifyListeners(); // The router's refreshListenable will trigger the redirect
  }
}
