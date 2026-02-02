import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://meta.asociacionmilitaresnuevavision.com';
  final http.Client _client = http.Client();

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    // La lógica de backend espera la contraseña encriptada con SHA1.
    final hashedPassword = sha1.convert(utf8.encode(password)).toString();

    try {
      // Usamos un cliente que no sigue redirecciones para poder inspeccionar la respuesta inicial.
      final request = http.Request('POST', url)
        ..bodyFields = {
          'email': email,
          'password': hashedPassword,
        }
        ..followRedirects = false;

      final streamedResponse = await _client.send(request);
      
      // Una redirección (302) a '/home' indica un inicio de sesión exitoso en el backend de Laravel.
      if (streamedResponse.statusCode == 302) {
        final location = streamedResponse.headers['location'];
        if (location != null && location.endsWith('/home')) {
          // Aunque no usemos cookies explícitamente aquí, el cliente http las gestionará
          // si el backend las establece, lo que es útil para futuras llamadas API con estado.
          return true;
        }
      }
      return false;
    } catch (e) {
      // Manejar errores de red u otros problemas.
      print('Error en login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('$_baseUrl/logout');
    try {
      // El backend de Laravel maneja el logout a través de una petición GET.
      await _client.get(url);
    } catch (e) {
      print('Error en logout: $e');
    }
  }
}
