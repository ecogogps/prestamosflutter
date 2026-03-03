
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider() {
    // Escuchar cambios de autenticación en Supabase (login, logout, session update)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => Supabase.instance.client.auth.currentSession != null;

  String? get userEmail => Supabase.instance.client.auth.currentUser?.email;
  String? get userPhone => Supabase.instance.client.auth.currentUser?.phone;

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }
}
