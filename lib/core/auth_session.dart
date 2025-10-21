// lib/core/auth_session.dart
//
// Estado global de autenticación sencillo.
// - Guarda/lee usuario y token en SharedPreferences.
// - Expone un ValueNotifier<AuthUser?> para que las pantallas reaccionen.
//
// Uso típico:
//   await AuthSession.instance.load();        // en main() antes de runApp()
//   AuthSession.instance.signIn(authUser);    // tras login OK
//   AuthSession.instance.signOut();           // cerrar sesión
//
// Este archivo NO hace llamadas HTTP. Eso está en data/auth_api.dart.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo simple del usuario en sesión.
/// Debe acoplarse a lo que te devuelve el backend.
class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> map) => AuthUser(
        id: map['id']?.toString() ?? '',
        email: map['email'] ?? '',
        firstName: map['first_name'] ?? map['firstName'] ?? '',
        lastName: map['last_name'] ?? map['lastName'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      };
}

class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  /// Notificador global del usuario autenticado (o null si sin sesión)
  final ValueNotifier<AuthUser?> user = ValueNotifier<AuthUser?>(null);

  String? _token;
  String? get token => _token;

  static const _kUser = 'auth.user';
  static const _kToken = 'auth.token';

  /// Carga la sesión guardada (si existe). NUNCA lanza excepciones.
  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();

      final userStr = sp.getString(_kUser);
      final tok = sp.getString(_kToken);

      if (userStr != null) {
        try {
          final map = jsonDecode(userStr) as Map<String, dynamic>;
          user.value = AuthUser.fromJson(map);
        } catch (_) {
          user.value = null;
        }
      } else {
        user.value = null;
      }

      _token = tok;
    } catch (_) {
      // Si algo falla (p.ej. localStorage bloqueado en web),
      // dejamos la app seguir sin sesión.
      user.value = null;
      _token = null;
    }
  }

  /// Guarda sesión después de login.
  Future<void> signIn(AuthUser u, {required String? token}) async {
    user.value = u;
    _token = token;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kUser, jsonEncode(u.toJson()));
      if (token != null) {
        await sp.setString(_kToken, token);
      } else {
        await sp.remove(_kToken);
      }
    } catch (_) {
      // ignoramos persistencia fallida
    }
  }

  /// Cierra sesión y limpia storage. No lanza excepciones.
  Future<void> signOut() async {
    user.value = null;
    _token = null;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kUser);
      await sp.remove(_kToken);
    } catch (_) {}
  }
}
