// lib/features/loads/data/loads_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/core/auth_session.dart';

class LoadsApi {
  // 👇 SIEMPRE usa Env.baseUrl, no quemes URLs aquí.
  static String get _base => Env.baseUrl;

  static Map<String, String> _headers() {
    final token = AuthSession.instance.token ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────────────────
  // CARGAS PÚBLICAS (StartPage)
  // ─────────────────────────────────────────────────────────
  static Future<List<Trip>> fetchPublic({int limit = 100}) async {
    final uri = Uri.parse('$_base/api/loads/public?limit=$limit');
    final res = await http.get(uri, headers: _headers());

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);

    if (body is List) {
      return body
          .map((e) => Trip.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (body is Map && body['items'] is List) {
      return (body['items'] as List)
          .map((e) => Trip.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return <Trip>[];
  }

  // ─────────────────────────────────────────────────────────
  // MIS CARGAS (MyLoadsPage)
  // ─────────────────────────────────────────────────────────
  static Future<List<Trip>> fetchMine({String status = 'all'}) async {
    final uri = Uri.parse('$_base/api/loads/mine?status=$status');
    final res = await http.get(uri, headers: _headers());

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);

    if (body is List) {
      return body
          .map((e) => Trip.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (body is Map && body['items'] is List) {
      return (body['items'] as List)
          .map((e) => Trip.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return <Trip>[];
  }

  // ─────────────────────────────────────────────────────────
  // DETALLE (TripDetailPage)
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> fetchTripDetailRaw(String id) async {
    final uri = Uri.parse('$_base/api/loads/$id');
    final res = await http.get(uri, headers: _headers());

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);

    if (body is Map<String, dynamic>) return Map<String, dynamic>.from(body);
    if (body is Map) return Map<String, dynamic>.from(body);

    return <String, dynamic>{};
  }

  // ─────────────────────────────────────────────────────────
  // CREAR VIAJE (útil si quieres usarlo desde otro sitio)
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> create(
      Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base/api/loads');
    final res = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  // ─────────────────────────────────────────────────────────
  // MARCAR VIAJE COMO VENCIDO / ELIMINADO LÓGICO
  // ─────────────────────────────────────────────────────────
  static Future<void> expire(String id) async {
    // 👇 FORZAMOS SIEMPRE POST A /expire (NUNCA DELETE)
    final uri = Uri.parse('$_base/api/loads/$id/expire');
    final res = await http.post(uri, headers: _headers());

    if (res.statusCode == 404) {
      throw Exception('Viaje no encontrado o sin permisos.');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
