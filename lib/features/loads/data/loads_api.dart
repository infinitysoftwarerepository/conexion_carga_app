import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/core/auth_session.dart';

class LoadsApi {
  static String get _base => Env.baseUrl;

  static Map<String, String> _headers() {
    final token = AuthSession.instance.token ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Trip>> fetchPublic({int limit = 100}) async {
    final uri = Uri.parse('$_base/api/loads/public?limit=$limit');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is List) {
      return body.map<Trip>((e) => Trip.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    if (body is Map && body['items'] is List) {
      return (body['items'] as List).map<Trip>((e) => Trip.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return <Trip>[];
  }

  static Future<List<Trip>> fetchMine({String status = 'all'}) async {
    final uri = Uri.parse('$_base/api/loads/mine?status=$status');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is List) {
      return body.map<Trip>((e) => Trip.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    if (body is Map && body['items'] is List) {
      return (body['items'] as List).map<Trip>((e) => Trip.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return <Trip>[];
  }

  static Future<Map<String, dynamic>> fetchTripDetailRaw(String id) async {
    final uri = Uri.parse('$_base/api/loads/$id');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is Map<String, dynamic>) return body;
    return <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base/api/loads');
    final res = await http.post(uri, headers: _headers(), body: jsonEncode(body));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  static Future<void> expire(String id) async {
    final uri = Uri.parse('$_base/api/loads/$id');
    final res = await http.delete(uri, headers: _headers());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
