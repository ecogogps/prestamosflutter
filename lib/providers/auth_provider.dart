import 'package:flutter/material.dart';
import 'package:myapp/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;

  bool get isAuthenticated => _token != null;

  Future<bool> login(String user, String password) async {
    try {
      final token = await _authService.login(user, password);
      if (token != null) {
        _token = token;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
