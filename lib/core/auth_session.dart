// lib/core/auth_session.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'env.dart';

class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isPremium;
  final int points;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isPremium,
    required this.points,
  });

  factory AuthUser.fromJson(Map<String, dynamic> j) {
    return AuthUser(
      id: (j['id'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      firstName: (j['first_name'] ?? j['firstName'] ?? '').toString(),
      lastName: (j['last_name'] ?? j['lastName'] ?? '').toString(),
      isPremium: j['is_premium'] == true || j['isPremium'] == true,
      points: (j['points'] is int)
          ? j['points'] as int
          : int.tryParse('${j['points'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'is_premium': isPremium,
        'points': points,
      };
}

class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  static const _kTokenKey = 'cc_token_v1';
  static const _kUserKey = 'cc_user_v1';

  /// Usuario actual. StartPage escucha este ValueListenable.
  final ValueNotifier<AuthUser?> user = ValueNotifier<AuthUser?>(null);

  /// Token actual en memoria.
  String? token;

  /// Restaura token+usuario desde disco y valida el token contra /me.
  Future<void> hydrate() async {
    final sp = await SharedPreferences.getInstance();
    token = sp.getString(_kTokenKey);
    final rawUser = sp.getString(_kUserKey);

    if (rawUser != null) {
      try {
        user.value = AuthUser.fromJson(jsonDecode(rawUser));
      } catch (_) {
        user.value = null;
      }
    }

    if (token == null || token!.isEmpty) {
      user.value = null;
      return;
    }

    // Verificar token contra /me (aceptamos /api/auth/me o /api/users/me)
    try {
      final me = await _fetchMe();
      user.value = me;
      await _persist(me, token!);
    } catch (_) {
      await signOut();
    }
  }

  /// Firma compatible con tu auth_api.dart:
  /// guarda token y usuario, notifica a listeners y persiste.
  Future<void> signIn(AuthUser u, {required String token}) async {
    this.token = token;
    user.value = u;
    await _persist(u, token);
  }

  Future<void> signOut() async {
    token = null;
    user.value = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kTokenKey);
    await sp.remove(_kUserKey);
  }

  Future<void> _persist(AuthUser u, String t) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTokenKey, t);
    await sp.setString(_kUserKey, jsonEncode(u.toJson()));
  }

  /// GET perfil usando el token. Intenta /api/auth/me y si no existe, /api/users/me.
  Future<AuthUser> _fetchMe() async {
    final t = token ?? '';
    if (t.isEmpty) throw Exception('No token');

    Future<AuthUser> hit(String path) async {
      final res = await http.get(
        Uri.parse('${Env.baseUrl}$path'),
        headers: {'Authorization': 'Bearer $t'},
      );
      if (res.statusCode != 200) {
        throw Exception('ME $path ${res.statusCode}');
      }
      final map = (jsonDecode(res.body) as Map).cast<String, dynamic>();
      return AuthUser.fromJson(map);
    }

    try {
      return await hit('/api/auth/me');
    } catch (_) {
      // fallback si tu back expone /api/users/me
      return await hit('/api/users/me');
    }
  }
}
