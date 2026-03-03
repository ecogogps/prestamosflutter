
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  Session? _session;

  AuthProvider() {
    _session = Supabase.instance.client.auth.currentSession;
    
    // Escuchar cambios en la sesión de Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _session != null;
  Session? get session => _session;

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
