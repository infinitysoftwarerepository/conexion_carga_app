// lib/features/auth/data/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/core/auth_session.dart';

/// Cliente de autenticación.
/// Backend esperado:
///   POST /api/auth/login  -> { token, user:{...} }  ó  { token, ...campos usuario... }
///   GET  /api/users/me    -> { ...usuario... }  (opcional)
class AuthApi {
  const AuthApi();

  /// Inicia sesión; guarda la sesión global y devuelve el usuario.
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${Env.baseUrl}/api/auth/login');

    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode == 404) {
      throw Exception(
          '404 Not Found en $uri. Revisa baseUrl y el path /api/auth/login en el backend.');
    }
    if (res.statusCode != 200) {
      String message = 'No se pudo iniciar sesión (${res.statusCode}).';
      try {
        final obj = jsonDecode(res.body);
        if (obj is Map && obj['detail'] != null) {
          message = obj['detail'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final body = jsonDecode(res.body);
    final (user, token) = _parseLoginPayload(body);

    // ¡OJO! El primer parámetro es posicional (no nombrado).
    await AuthSession.instance.signIn(user, token: token);
    return user;
  }

  /// (Opcional) Lee el perfil actual usando el token guardado.
  Future<AuthUser> me() async {
    final tok = AuthSession.instance.token;
    if (tok == null || tok.isEmpty) {
      throw Exception('No hay sesión.');
    }

    final uri = Uri.parse('${Env.baseUrl}/api/users/me');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $tok'},
    );

    if (res.statusCode != 200) {
      throw Exception('No fue posible obtener el perfil.');
    }

    // 👇 Aquí estaba el error: casteamos a Map<String, dynamic>
    final Map<String, dynamic> obj =
        (jsonDecode(res.body) as Map).cast<String, dynamic>();

    final user = AuthUser.fromJson(obj);

    // Refresca el usuario en memoria (sin alterar el token)
    await AuthSession.instance.signIn(user, token: tok);
    return user;
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  /// Normaliza payload de login:
  ///  A) { "token": "...", "user": { ... } }
  ///  B) { "token": "...", ...campos del usuario... }
  (AuthUser, String) _parseLoginPayload(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body['user'] != null) {
        final token = body['token']?.toString() ?? '';
        final Map<String, dynamic> userMap =
            (body['user'] as Map).cast<String, dynamic>();
        final user = AuthUser.fromJson(userMap);
        return (user, token);
      }
      final token = body['token']?.toString() ?? '';
      final user = AuthUser.fromJson(body);
      return (user, token);
    }

    // Si vino como Map<dynamic, dynamic>, también lo aceptamos:
    if (body is Map) {
      final m = body.cast<String, dynamic>();
      if (m['user'] != null) {
        final token = m['token']?.toString() ?? '';
        final Map<String, dynamic> userMap =
            (m['user'] as Map).cast<String, dynamic>();
        final user = AuthUser.fromJson(userMap);
        return (user, token);
      }
      final token = m['token']?.toString() ?? '';
      final user = AuthUser.fromJson(m);
      return (user, token);
    }

    throw Exception('Respuesta de login inválida.');
  }
}
