
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
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
  String? get userPhone => _session?.user.phone;

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
