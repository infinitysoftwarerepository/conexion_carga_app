// lib/features/loads/data/loads_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';

class LoadsApi {
  static Map<String, String> _headers() {
    final tok = AuthSession.instance.token ?? '';
    return {
      'Content-Type': 'application/json',
      if (tok.isNotEmpty) 'Authorization': 'Bearer $tok',
    };
  }

  static Future<List<Trip>> fetchPublic({int skip = 0, int limit = 100}) async {
    final uri = Uri.parse('${Env.baseUrl}/api/loads/public?skip=$skip&limit=$limit');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) {
      throw Exception('No se pudieron cargar los viajes publicados.');
    }
    return Trip.listFromResponse(res.body);
  }

  static Future<List<Trip>> fetchMine({String status = 'all'}) async {
    final uri = Uri.parse('${Env.baseUrl}/api/loads/mine?status=$status');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) {
      throw Exception('No se pudieron cargar tus viajes.');
    }
    return Trip.listFromResponse(res.body);
  }

  static Future<Trip> getOne(String id) async {
    final uri = Uri.parse('${Env.baseUrl}/api/loads/$id');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) {
      throw Exception('No se pudo obtener el viaje.');
    }
    return Trip.fromJson(jsonDecode(res.body));
  }

  static Future<void> expire(String id) async {
    final uri = Uri.parse('${Env.baseUrl}/api/loads/$id/expire');
    final res = await http.post(uri, headers: _headers());
    if (res.statusCode != 200) {
      throw Exception('No se pudo eliminar (caducar) el viaje.');
    }
  }
}
