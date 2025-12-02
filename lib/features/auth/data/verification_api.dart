// lib/features/auth/data/verification_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:conexion_carga_app/core/env.dart';

/// API para verificación de email por código y recuperación de contraseña.
///
/// Endpoints esperados en el backend FastAPI:
///   - POST /api/users/verify              -> verificar código de registro
///   - POST /api/users/reload-code         -> reenviar código de registro
///   - POST /api/auth/password/forgot      -> enviar código para restablecer contraseña
///   - POST /api/auth/password/reset       -> cambiar contraseña usando código
class VerificationApi {
  final String baseUrl;
  const VerificationApi({this.baseUrl = Env.baseUrl});

  /// Helper interno para hacer POST JSON y lanzar Exception si falla.
  Future<void> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');

    final res = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'Error ${res.statusCode} al llamar $path';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['detail'] != null) {
          msg = decoded['detail'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// 🔁 Reenviar un nuevo código de verificación al correo.
  ///
  /// Usa el endpoint: POST /api/users/reload-code
  /// Body: { "email": "<correo>" }
  Future<void> requestEmailCode(String email) async {
    await _post('/api/users/reload-code', {
      'email': email,
    });
  }

  /// 📩 Enviar código para restablecer contraseña (“¿Olvidaste tu contraseña?”).
  ///
  /// Usa el endpoint: POST /api/auth/password/forgot
  /// Body: { "email": "<correo>" }
  Future<void> requestPasswordReset(String email) async {
    await _post('/api/auth/password/forgot', {
      'email': email,
    });
  }

  /// 🔐 Cambiar contraseña usando código + email.
  ///
  /// Usa el endpoint: POST /api/auth/password/reset
  /// Body: { "email": "...", "code": "...", "new_password": "..." }
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _post('/api/auth/password/reset', {
      'email': email,
      'code': code,
      'new_password': newPassword,
    });
  }

  /// ✅ Verificar el código digitado por el usuario para activar la cuenta.
  ///
  /// Usa el endpoint: POST /api/users/verify
  /// Body: { "email": "...", "code": "..." }
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    await _post('/api/users/verify', {
      'email': email,
      'code': code,
    });
  }
}
