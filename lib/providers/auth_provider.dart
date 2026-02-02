import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoRouter goRouter;

  bool _isLoading = false;
  String? _token;

  AuthProvider(this.goRouter);

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get token => _token;

  Future<bool> login(String user, String password) async {
    _isLoading = true;
    notifyListeners();

    final token = await _authService.login(user, password);
    _isLoading = false;

    if (token != null) {
      _token = token;
      notifyListeners();
      goRouter.go('/home');
      return true;
    } else {
      _token = null;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
    goRouter.go('/login');
  }
}
