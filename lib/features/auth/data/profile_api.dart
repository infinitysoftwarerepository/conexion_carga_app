import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/core/env.dart';

class ProfileApi {
  const ProfileApi();

  Map<String, String> get _headers {
    final token = AuthSession.instance.token ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<AuthUser> updateMe({
    required String email,
    required String firstName,
    required String lastName,
    required String document,
    required String phoneCode,
    required String phoneNumber,
    required bool isCompany,
    required bool isDriver,
    String? companyName,
  }) async {
    final normalizedNumber = phoneNumber.replaceAll(RegExp(r'\D+'), '');
    final normalizedCode = phoneCode.startsWith('+') ? phoneCode : '+$phoneCode';
    final fullPhone = '$normalizedCode$normalizedNumber';

    final response = await http
        .put(
          Uri.parse('${Env.baseUrl}/api/users/me'),
          headers: _headers,
          body: jsonEncode({
            'email': email,
            'first_name': firstName,
            'last_name': lastName,
            'document': document,
            'phone_code': normalizedCode,
            'phone_number': normalizedNumber,
            'phone': fullPhone,
            'is_company': isCompany,
            'is_driver': isDriver,
            'company_name': isCompany ? companyName : null,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response, 'No fue posible actualizar el perfil.'));
    }

    final data = (jsonDecode(response.body) as Map).cast<String, dynamic>();
    final user = AuthUser.fromJson(data);
    final token = AuthSession.instance.token;
    if (token != null && token.isNotEmpty) {
      await AuthSession.instance.signIn(user, token: token);
    }
    return user;
  }

  Future<void> requestAccountDeletion({
    required String userId,
    required String email,
    required String motivo,
  }) async {
    final response = await http
        .post(
          Uri.parse('${Env.baseUrl}/user/request-account-deletion'),
          headers: _headers,
          body: jsonEncode({
            'user_id': userId,
            'email': email,
            'motivo': motivo,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response, 'No fue posible enviar la solicitud.'),
      );
    }
  }

  String _extractMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        return body['detail'].toString();
      }
    } catch (_) {}
    return '$fallback (${response.statusCode})';
  }
}
