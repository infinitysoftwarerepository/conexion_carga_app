// lib/app/theme/theme_conection.dart

import 'package:flutter/material.dart';

/// ===============================================================
/// 🎨 PALETA PRINCIPAL DE COLORES
/// ===============================================================

const kBrandOrange   = Color(0xFFFF7800); // Naranja principal (acentos, barritas)
const kOrangeDisabled = Color(0xFFFFEDD9); // Naranja opaco (botones deshabilitados)
const kGreenDisabled  = Color(0xFFDBF0D9); // Verde opaco (botones deshabilitados)

const kBrandGreen   = Color(0xFFA7E27A); // ✅ Verde claro (fondo de AppBar, chips, etc.)
const kDarkOrange   = Color(0xFF8B4500); // Naranja oscuro (tema oscuro / botones)
const kDarkGreen    = Color(0xFF5A8B3E); // Verde oscuro (tema oscuro / botones)
const kDeepDarkOrange = Color(0xFF4F2B00);
const kDeepDarkGreen  = Color(0xFF2F4D2A); // ✅ Verde muy profundo (AppBar oscuro, contenedores)
const kDeepDarkGray   = Color(0xFF1A1A1A); // Gris muy oscuro (fondos en dark)

const kGreenStrong  = Color(0xFF19B300); // Verde fuerte (acciones principales / FAB)
const kCreamBg      = Color(0xFFF5F5F2); // Fondo de pantallas en claro
const kGreySoft     = Color(0xFFEAEAEA); // Gris claro (bordes, separadores)
const kGreyText     = Color(0xFF6B7280); // Gris medio (texto secundario, íconos)

// 💛 Amarillo corporativo para tips, burbujas, avisos suaves.
const kBrandYellow  = Color(0xFFFFD54F);

/// Lista de "seed colors" candidatos (por si quieres cambiar tema más adelante)
const List<Color> _seedCandidates = [
  kBrandOrange,
  kBrandGreen,
  kGreenStrong,
];

/// ===============================================================
/// 🔌 THEME EXTENSION: AppColors
/// Extras que no caben bien en ColorScheme.
/// ===============================================================
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color brandOrange; // Naranja para detalles / barritas / countdown
  final Color success;     // Verde fuerte para acciones
  final Color glyph;       // Gris de íconos (lupa, filtros, etc.)
  final Color cardBorder;  // Borde de tarjetas
  // Podrías usarlo para burbujas tipo "¿Dudas?"
  final Color helpBubbleBg;

  const AppColors({
    required this.brandOrange,
    required this.success,
    required this.glyph,
    required this.cardBorder,
    required this.helpBubbleBg,
  });

  /// 🎨 Configuración para tema CLARO
  static AppColors light() => const AppColors(
        brandOrange: kBrandOrange,
        success: kGreenStrong,
        glyph: kGreyText,
        cardBorder: kGreySoft,
        helpBubbleBg: kBrandYellow,
      );

  /// 🌙 Configuración para tema OSCURO
  static AppColors dark() => const AppColors(
        brandOrange: Color(0xFFFFB84D),  // Naranja más suave en oscuro
        success: Color(0xFF57D276),      // Verde luminoso en oscuro
        glyph: Color(0xFFBFC3CA),        // Gris claro para íconos en oscuro
        cardBorder: Color(0xFF3A3A3A),   // Gris oscuro en bordes
        helpBubbleBg: Color(0xFFFFB84D), // Amarillo/naranja suave en oscuro
      );

  @override
  AppColors copyWith({
    Color? brandOrange,
    Color? success,
    Color? glyph,
    Color? cardBorder,
    Color? helpBubbleBg,
  }) {
    return AppColors(
      brandOrange: brandOrange ?? this.brandOrange,
      success: success ?? this.success,
      glyph: glyph ?? this.glyph,
      cardBorder: cardBorder ?? this.cardBorder,
      helpBubbleBg: helpBubbleBg ?? this.helpBubbleBg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandOrange: Color.lerp(brandOrange, other.brandOrange, t)!,
      success: Color.lerp(success, other.success, t)!,
      glyph: Color.lerp(glyph, other.glyph, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      helpBubbleBg: Color.lerp(helpBubbleBg, other.helpBubbleBg, t)!,
    );
  }
}

/// ===============================================================
/// 🌈 CLASE PRINCIPAL DE TEMA: AppTheme
/// ===============================================================
class AppTheme {
  final int selectedSeed;

  const AppTheme({this.selectedSeed = 0})
      : assert(selectedSeed >= 0 && selectedSeed < _seedCandidates.length);

  /// Tema CLARO
  ThemeData theme() {
    final seed = _seedCandidates[selectedSeed];

    final baseScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: kGreenStrong,    // Botones principales (FilledButton)
      secondary: kBrandOrange,  // Acentos puntuales
      surface: Colors.white,    // Fondos de tarjetas
      background: kCreamBg,     // Fondo de pantalla
    );

    return ThemeData(
      useMaterial3: true,

      // Fondo principal
      scaffoldBackgroundColor: kCreamBg,

      // Ajustamos el ColorScheme
      colorScheme: baseScheme.copyWith(
        secondaryContainer: kBrandGreen,       // Cajitas (chips, avisos)
        onSecondaryContainer: kDeepDarkGreen,  // Texto/íconos encima de esa cajita
        // Podrías usar tertiary para cosas amarillas si más adelante las necesitas
        tertiary: kBrandYellow,
      ),

      // Extensión propia con extras
      extensions: <ThemeExtension<dynamic>>[
        AppColors.light(),
      ],

      // ✅ AppBar claro usa tu verde marca
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: kBrandGreen,     // Verde marca
        foregroundColor: kDeepDarkGreen,  // Íconos/texto AppBar
      ),

      // Inputs de texto (formularios)
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Tema OSCURO
  ThemeData darkTheme() {
    final seed = _seedCandidates[selectedSeed];

    // Paleta base para oscuro
    const kDarkBg      = Color(0xFF0F0F0F);
    const kDarkSurface = Color(0xFF1A1A1A);
    const kOnSurface   = Color(0xFFE6E6E6);

    final baseScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: kDarkBg,

      colorScheme: baseScheme.copyWith(
        surface: kDarkSurface,
        onSurface: kOnSurface,
        primary: kGreenStrong,
        secondary: kBrandOrange,
        // En oscuro, “cajitas” con verde profundo
        secondaryContainer: kDeepDarkGreen,
        onSecondaryContainer: Colors.white,
        tertiary: kBrandYellow,
      ),

      extensions: <ThemeExtension<dynamic>>[
        AppColors.dark(),
      ],

      // AppBar oscuro con verde profundo
      appBarTheme: const AppBarTheme(
        backgroundColor: kDeepDarkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Si quieres forzar cards oscuras del framework:
      // cardTheme: const CardTheme(color: kDarkSurface),
    );
  }
}
