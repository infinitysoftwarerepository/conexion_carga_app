// lib/features/auth/data/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/core/auth_session.dart';

/// Cliente de autenticación.
/// Backend esperado:
///   POST /api/auth/login  -> { access_token | token, user:{...} } ó { access_token | token, ...usuario... }
///   GET  /api/auth/me     -> { ...usuario... }  (o /api/users/me como fallback)
class AuthApi {
  const AuthApi();

  /// Inicia sesión; guarda la sesión global y devuelve el usuario.
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${Env.baseUrl}/api/auth/login');

    // JSON; si tu back requiere form-url-encoded, cambia headers/body.
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 404) {
      throw Exception(
          '404 Not Found en $uri. Revisa baseUrl y el path /api/auth/login en el backend.');
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
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

    // Firma compatible con tu AuthSession esperado por StartPage.
    await AuthSession.instance.signIn(user, token: token);
    return user;
  }

  /// (Opcional) Lee el perfil actual usando el token guardado.
  Future<AuthUser> me() async {
    final tok = AuthSession.instance.token;
    if (tok == null || tok.isEmpty) {
      throw Exception('No hay sesión.');
    }

    // Intenta /api/auth/me; si no existe prueba /api/users/me
    Future<AuthUser> hit(String path) async {
      final res = await http.get(
        Uri.parse('${Env.baseUrl}$path'),
        headers: {'Authorization': 'Bearer $tok'},
      );
      if (res.statusCode != 200) {
        throw Exception('No fue posible obtener el perfil ($path).');
      }
      final Map<String, dynamic> obj =
          (jsonDecode(res.body) as Map).cast<String, dynamic>();
      return AuthUser.fromJson(obj);
    }

    try {
      final user = await hit('/api/auth/me');
      await AuthSession.instance.signIn(user, token: tok);
      return user;
    } catch (_) {
      final user = await hit('/api/users/me');
      await AuthSession.instance.signIn(user, token: tok);
      return user;
    }
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  /// Normaliza payload de login admitiendo:
  ///  A) { "access_token": "...", "user": { ... } }
  ///  B) { "access_token": "...", ...usuario... }
  ///  C) Igual pero con "token" en vez de "access_token".
  (AuthUser, String) _parseLoginPayload(dynamic body) {
    Map<String, dynamic> m;
    if (body is Map<String, dynamic>) {
      m = body;
    } else if (body is Map) {
      m = body.cast<String, dynamic>();
    } else {
      throw Exception('Respuesta de login inválida.');
    }

    final token =
        (m['access_token'] ?? m['token'] ?? '').toString(); // soporta ambos
    if (token.isEmpty) {
      throw Exception('Login sin token en la respuesta.');
    }

    if (m['user'] != null) {
      final userMap = (m['user'] as Map).cast<String, dynamic>();
      final user = AuthUser.fromJson(userMap);
      return (user, token);
    }

    // Si no viene "user", asumimos que el resto del payload es el usuario.
    final user = AuthUser.fromJson(m);
    return (user, token);
  }
}
