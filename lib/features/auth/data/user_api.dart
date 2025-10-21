import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/features/auth/data/models/user_out.dart';

class UserApi {
  const UserApi();

  Future<UserOut> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required bool isCompany,
    String? companyName,
    required String password,
    required String confirmPassword,
    String? referrerEmail,
  }) async {
    final uri = Uri.parse('${Env.baseUrl}/api/users/register');

    final body = <String, dynamic>{
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "is_company": isCompany,
      "company_name": companyName,
      "password": password,
      "confirm_password": confirmPassword,
      if (referrerEmail != null) "referrer_email": referrerEmail,
    };

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    // OK → devolvemos user
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return UserOut.fromJson(data);
    }

    // Error → tratamos de extraer mensaje {detail: "..."}
    String message = 'Registro falló: [${res.statusCode}]';
    try {
      final m = jsonDecode(res.body);
      if (m is Map && m['detail'] is String) {
        message = m['detail'] as String;
      } else if (m is String) {
        message = m;
      }
    } catch (_) {
      // no-op
    }
    throw Exception(message);
  }
}
