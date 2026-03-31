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
    required String document,
    required String phoneCode,
    required String phoneNumber,
    required bool isCompany,
    required bool isDriver,
    String? companyName,
    required String password,
    required String confirmPassword,
    String? referrerEmail,
  }) async {
    final uri = Uri.parse('${Env.baseUrl}/api/users/register');
    final normalizedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D+'), '');
    final normalizedPhoneCode = phoneCode.startsWith('+') ? phoneCode : '+$phoneCode';
    final fullPhone = '$normalizedPhoneCode$normalizedPhoneNumber';

    final body = <String, dynamic>{
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'document': document,
      'phone_code': normalizedPhoneCode,
      'phone_number': normalizedPhoneNumber,
      'phone': fullPhone,
      'is_company': isCompany,
      'is_driver': isDriver,
      'company_name': companyName,
      'password': password,
      'confirm_password': confirmPassword,
      if (referrerEmail != null) 'referrer_email': referrerEmail,
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return UserOut.fromJson(data);
    }

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
