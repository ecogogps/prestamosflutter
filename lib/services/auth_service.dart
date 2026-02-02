import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://meta.asociacionmilitaresnuevavision.com';

  Future<String?> login(String user, String password) async {
    final url = Uri.parse('$_baseUrl/login-socio');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user': user,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the token is returned under the key 'token'
        if (data.containsKey('token')) {
          return data['token'];
        }
      }
      // If server returns an error response, or token is not found
      return null;
    } catch (e) {
      // Handle network errors or exceptions
      print(e);
      return null;
    }
  }
}
