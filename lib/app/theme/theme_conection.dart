import 'package:flutter/material.dart';

/// ===============================================================
/// 🎨 PALETA PRINCIPAL DE COLORES
/// ===============================================================
const kBrandOrange = Color(0xFFFF7800); // Naranja (ej: barrita superior de la tarjeta)
const kOrangeDisabled = Color(0xFFFFEDD9); // Naranja opaco usado en botones desabilitados
const kGreenDisabled = Color(0xFFDBF0D9); //  Verde opaco usado en botonoes desabilitados
const kBrandGreen  = Color(0xFFA7E27A); // ✅ Verde claro (ahora reemplaza “salmón” en claro)
const kDarkOrange = Color(0xFF8B4500); // Naranja oscuro (marrón) usado en botones habilitados del tema oscuro
const kDarkGreen = Color(0xFF5A8B3E); // Verde oscuro usado en botones habilitados del tema oscuro
const kDeepDarkOrange = Color(0xFF4F2B00);
const kDeepDarkGreen = Color(0xFF2F4D2A); // ✅ Verde profundo (equivalente en oscuro)
const kDeepDarkGray = Color(0xFF1A1A1A); // Gris muy oscuro
const kGreenStrong = Color(0xFF19B300); // Verde fuerte (acciones principales / FAB)
const kCreamBg     = Color(0xFFF5F5F2); // Fondo de pantallas
const kGreySoft    = Color(0xFFEAEAEA); // Gris claro (bordes, separadores)
const kGreyText    = Color(0xFF6B7280); // Gris medio (íconos, texto secundario)

/// Lista de candidatos de "seed colors".
const List<Color> _seedCandidates = [
  kBrandOrange,
  kBrandGreen,
  kGreenStrong,
];

/// ===============================================================
/// 🔌 THEME EXTENSION: AppColors
/// ===============================================================
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color brandOrange; // Naranja de la barrita / countdown
  final Color success;     // Verde fuerte para acciones
  final Color glyph;       // Gris de íconos (lupa, filtros, etc.)
  final Color cardBorder;  // Color del borde de las tarjetas

  const AppColors({
    required this.brandOrange,
    required this.success,
    required this.glyph,
    required this.cardBorder,
  });

  /// 🎨 Configuración para tema CLARO
  static AppColors light() => const AppColors(
        brandOrange: kBrandOrange,
        success: kGreenStrong,
        glyph: kGreyText,
        cardBorder: kGreySoft,
      );

  /// 🌙 Configuración para tema OSCURO
  static AppColors dark() => const AppColors(
        brandOrange: Color(0xFFFFB84D),  // Naranja más claro
        success: Color(0xFF57D276),      // Verde más luminoso
        glyph: Color(0xFFBFC3CA),        // Gris más claro para íconos
        cardBorder: Color(0xFF3A3A3A),   // Gris oscuro para bordes
      );

  @override
  AppColors copyWith({
    Color? brandOrange,
    Color? success,
    Color? glyph,
    Color? cardBorder,
  }) {
    return AppColors(
      brandOrange: brandOrange ?? this.brandOrange,
      success: success ?? this.success,
      glyph: glyph ?? this.glyph,
      cardBorder: cardBorder ?? this.cardBorder,
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

    return ThemeData(
      useMaterial3: true,

      // Fondo principal
      scaffoldBackgroundColor: kCreamBg,

      // ✅ Ajustamos el ColorScheme para que:
      //  - secondaryContainer sea kBrandGreen (reemplaza las “cajitas salmón”)
      //  - onSecondaryContainer contraste bien (usamos un verde profundo)
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
        primary: kGreenStrong,    // Botones principales (FilledButton)
        secondary: kBrandOrange,  // Acentos puntuales
        surface: Colors.white,    // Fondos de tarjetas
        background: kCreamBg,     // Fondo de pantalla
      ).copyWith(
        secondaryContainer: kBrandGreen,       // << AQUÍ va tu verde marca
        onSecondaryContainer: kDeepDarkGreen,  // texto/ícono encima de esa cajita
      ),

      // Extensión propia
      extensions: <ThemeExtension<dynamic>>[
        AppColors.light(),
      ],

      // ✅ AppBar claro usa tu verde marca (en lugar del salmón)
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: kBrandGreen,     // << verde marca
        foregroundColor: kDeepDarkGreen,  // íconos/texto del AppBar
      ),

      // Inputs de texto (casillitas de formulario)
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: kDarkBg,

      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ).copyWith(
        surface: kDarkSurface,
        onSurface: kOnSurface,
        primary: kGreenStrong,
        secondary: kBrandOrange,
        // ✅ En oscuro, tus cajitas y avisos usan DeepDarkGreen
        secondaryContainer: kDeepDarkGreen,
        onSecondaryContainer: Colors.white, // contraste en oscuro
      ),

      extensions: <ThemeExtension<dynamic>>[
        AppColors.dark(),
      ],

      // ✅ AppBar oscuro con el mismo deep green
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
