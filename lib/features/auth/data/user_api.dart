// lib/features/auth/data/user_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/features/auth/data/models/user_out.dart';

/// Cliente HTTP hacia el backend FastAPI.
/// - `emailExists` hace una verificación previa (GET + filtro local).
/// - `register` ejecuta el POST real hacia /api/users/register.
class UserApi {
  final String baseUrl;
  const UserApi({this.baseUrl = Env.baseUrl});

  /// Verifica si un email ya está registrado.
  /// Implementación simple: GET /api/users y filtra en el cliente.
  /// (Si luego agregas GET /api/users?email=..., cámbialo aquí).
  Future<bool> emailExists(String email) async {
    final uri = Uri.parse('$baseUrl/api/users');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('No se pudo validar el correo (GET ${res.statusCode}).');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.any((u) {
      final mail = (u as Map<String, dynamic>)['email']?.toString().toLowerCase();
      return mail == email.toLowerCase();
    });
  }

  /// Crea un usuario nuevo (registro) en el backend.
  /// Llama a POST /api/users/register con el shape esperado.
  Future<UserOut> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required bool isCompany,
    String? companyName,
    required String password,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$baseUrl/api/users/register');

    final payload = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'is_company': isCompany,
      'company_name': companyName,
      'password': password,
      'confirm_password': confirmPassword,
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode == 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return UserOut.fromJson(json);
    }

    // Intenta extraer mensaje de error legible
    String message = 'Error al registrar (${res.statusCode}).';
    try {
      final obj = jsonDecode(res.body);
      if (obj is Map && obj['detail'] != null) {
        message = obj['detail'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }
}
