// lib/features/auth/presentation/registration_controller.dart
import 'package:flutter/material.dart';
import 'package:conexion_carga_app/features/auth/data/models/user_out.dart';
import 'package:conexion_carga_app/features/auth/data/user_api.dart';

class RegistrationController {
  final _api = const UserApi();

  Future<UserOut> submit({
    required BuildContext context,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required bool isCompany,
    required bool isDriver, 
    required String? companyName,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
    String? referrerEmail, // nuevo
  }) async {
    if (!acceptedTerms) {
      throw Exception("Debes aceptar los términos y condiciones.");
    }
    if (password != confirmPassword) {
      throw Exception("Las contraseñas no coinciden.");
    }

    final user = await _api.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      isCompany: isCompany,
      isDriver: isDriver,                            
      companyName: (isCompany ? companyName : null),
      password: password,
      confirmPassword: confirmPassword,
      referrerEmail: (referrerEmail?.isEmpty ?? true) ? null : referrerEmail,
    );

    return user;
  }
}
