// lib/features/auth/presentation/registration_controller.dart
import 'package:flutter/material.dart';
import 'package:conexion_carga_app/features/auth/data/user_api.dart';
import 'package:conexion_carga_app/features/auth/data/models/user_out.dart';

/// Encapsula la lógica de envío/validación del formulario de registro.
/// Mantiene la UI de tu página lo más limpia posible.
class RegistrationController {
  final UserApi api;
  RegistrationController({UserApi? api}) : api = api ?? const UserApi();

  /// Valida los campos mínimos del formulario.
  /// Retorna `null` si todo OK, o un mensaje de error si hay problema.
  String? validateForm({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) {
    if (!acceptedTerms) return 'Debes aceptar los términos.';

    if (email.trim().isEmpty ||
        firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return 'Completa los campos obligatorios.';
    }

    // Validación sencilla de email (no perfecta, pero suficiente en UI)
    final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailReg.hasMatch(email.trim())) {
      return 'Correo electrónico inválido.';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener mínimo 8 caracteres.';
    }

    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden.';
    }

    return null; // OK
  }

  /// Flujo completo: valida, revisa si email existe (GET), y si no, hace POST.
  Future<UserOut> submit({
    required BuildContext context,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required bool isCompany,
    String? companyName,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    final error = validateForm(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      acceptedTerms: acceptedTerms,
    );
    if (error != null) {
      throw Exception(error);
    }

    // 1) Verificación previa con GET (si ya existe, informamos)
    final exists = await api.emailExists(email.trim());
    if (exists) {
      throw Exception('El correo ya está registrado, inicie sesión o solicite activación.');
    }

    // 2) Registro real (POST)
    final user = await api.register(
      email: email.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone.trim(),
      isCompany: isCompany,
      companyName: isCompany ? (companyName?.trim().isEmpty == true ? null : companyName?.trim()) : null,
      password: password,
      confirmPassword: confirmPassword,
    );

    return user;
  }
}
