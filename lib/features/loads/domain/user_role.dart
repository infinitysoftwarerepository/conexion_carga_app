// lib/features/loads/domain/user_role.dart

import 'package:flutter/material.dart';

/// Enum tipado con los roles disponibles.
/// - Agregar/quitar roles aquí es muy fácil.
/// - También añadimos helpers (label, descripción, ícono) para usar en la UI.
enum UserRole {
  comercial,    // “Soy un comercial”
  conductor,    // “Soy un conductor”
  empresa,      // “Somos una empresa”
  propietario,  // “Soy propietario de vehículo” (opcional, pero útil en logística)
}

extension UserRoleX on UserRole {
  /// Título corto para el botón.
  String get title {
    switch (this) {
      case UserRole.comercial:   return 'Soy un comercial';
      case UserRole.conductor:   return 'Soy un conductor';
      case UserRole.empresa:     return 'Somos una empresa';
      case UserRole.propietario: return 'Soy propietario de vehículo';
    }
  }

  /// Descripción secundaria (se muestra debajo del título).
  String get subtitle {
    switch (this) {
      case UserRole.comercial:   return 'Publica y gestiona viajes para tus clientes';
      case UserRole.conductor:   return 'Postúlate a viajes y comparte disponibilidad';
      case UserRole.empresa:     return 'Administra tu flota y tus conductores';
      case UserRole.propietario: return 'Registra tu vehículo y ofrece servicios';
    }
  }

  /// Ícono recomendado para cada rol.
  IconData get icon {
    switch (this) {
      case UserRole.comercial:   return Icons.badge_outlined;
      case UserRole.conductor:   return Icons.local_shipping_outlined;  
      case UserRole.empresa:     return Icons.apartment_outlined;
      case UserRole.propietario: return Icons.garage_outlined;           // si tu versión no lo trae, usa Icons.directions_car_outlined
    }
  }
}
