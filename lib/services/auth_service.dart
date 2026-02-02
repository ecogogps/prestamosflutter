import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://meta.asociacionmilitaresnuevavision.com/api';

  Future<String?> login(String user, String password) async {
    final url = Uri.parse('$_baseUrl/login-socio');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user': user,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('token')) {
          return responseData['token'];
        }
      }
      return null;
    } catch (e) {
      // In a real app, you'd want to log this error
      return null;
    }
  }
}
