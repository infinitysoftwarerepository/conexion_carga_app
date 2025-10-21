// lib/features/auth/data/verification_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:conexion_carga_app/core/env.dart';

/// API para verificación de email por código.
/// Se conecta con los endpoints del backend FastAPI:
///   - POST /api/users/register             -> registro inicial
///   - POST /api/users/verify               -> verificación de código
///
/// En este cliente Flutter sólo usamos:
///   - POST /api/users/verify
class VerificationApi {
  final String baseUrl;
  const VerificationApi({this.baseUrl = Env.baseUrl});

  /// Reenvía un nuevo código de verificación al correo (opcional).
  /// ⚠️ Solo funciona si el backend lo soporta (por ahora no hay un endpoint específico).
  Future<void> requestEmailCode(String email) async {
    final uri = Uri.parse('$baseUrl/api/users/register'); // mismo registro para regenerar código

    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': 'temporal123',
            'confirm_password': 'temporal123',
            'first_name': 'Temporal',
            'last_name': 'User',
            'is_company': false
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 201 && res.statusCode != 200) {
      String message = 'No se pudo reenviar el código (${res.statusCode}).';
      try {
        final obj = jsonDecode(res.body);
        if (obj is Map && obj['detail'] != null) {
          message = obj['detail'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Envía el código digitado por el usuario para verificar su correo.
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    // ✅ Endpoint correcto según tu backend: /api/users/verify
    final uri = Uri.parse('$baseUrl/api/users/verify');

    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'code': code}),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      String message = 'Código inválido o vencido.';
      try {
        final obj = jsonDecode(res.body);
        if (obj is Map && obj['detail'] != null) {
          message = obj['detail'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
