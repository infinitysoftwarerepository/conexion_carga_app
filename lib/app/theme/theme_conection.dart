import 'package:flutter/material.dart';

/// ===============================================================
/// 🎨 PALETA PRINCIPAL DE COLORES
/// Aquí definimos los colores "base" que usas en tu app.
/// Nota: Son constantes para que queden en un solo lugar.
/// ===============================================================
const kBrandOrange = Color(0xFFFF7800); // Naranja (ej: barrita superior de la tarjeta)
const kOrangeDisabled = Color(0xFFFFEDD9); // Naranja opaco usado en botones desabilitados
const kGreenDisabled = Color(0xFFDBF0D9); //  Verde opaco usado en botonoes desabilitados
const kBrandGreen  = Color(0xFFA7E27A); // Verde claro 
const kDarkOrange = Color(0xFF8B4500); // Naranja oscuro (marrón) usado en botones habilitados del tema oscuro
const kDarkGreen = Color(0xFF5A8B3E); // Verde oscuro usado en botones habilitados del tema oscuro
const kDeepDarkOrange = Color(0xFF4F2B00);
const kDeepDarkGreen = Color(0xFF2F4D2A);
const kDeepDarkGray = Color(0xFF1A1A1A); // Gris muy oscuro
const kGreenStrong = Color(0xFF19B300); // Verde fuerte (acciones principales / FAB)
const kCreamBg     = Color(0xFFF5F5F2); // Fondo de pantallas
const kGreySoft    = Color(0xFFEAEAEA); // Gris claro (bordes, separadores)
const kGreyText    = Color(0xFF6B7280); // Gris medio (íconos, texto secundario)

/// Lista de candidatos de "seed colors".
/// Flutter puede generar un esquema de color completo a partir de un color semilla.
/// Con esta lista, puedes cambiar rápido la tonalidad global de la app.
const List<Color> _seedCandidates = [
  kBrandOrange,
  kBrandGreen,
  kGreenStrong,
];

/// ===============================================================
/// 🔌 THEME EXTENSION: AppColors
/// Con esto creamos nuestra propia extensión de tema.
/// Nos permite guardar "colores de marca" personalizados y usarlos
/// en cualquier widget con: 
///   Theme.of(context).extension<AppColors>()!
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

  /// 🌙 Configuración para tema OSCURO (cuando actives ThemeMode.dark)
  static AppColors dark() => const AppColors(
        brandOrange: Color(0xFFFFB84D),  // Naranja más claro
        success: Color(0xFF57D276),      // Verde más luminoso
        glyph: Color(0xFFBFC3CA),        // Gris más claro para íconos
        cardBorder: Color(0xFF3A3A3A),   // Gris oscuro para bordes
      );

  /// copyWith -> permite clonar el objeto cambiando solo un campo
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

  /// lerp -> necesario para animaciones de cambio de tema (light <-> dark)
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
/// Acá armamos el ThemeData de Flutter y le metemos:
///   - Nuestros colores base
///   - La extensión AppColors
///   - Configuración de AppBar, Input, FAB, etc.
/// ===============================================================
class AppTheme {
  final int selectedSeed;

  /// selectedSeed -> índice para elegir un color semilla de _seedCandidates
  const AppTheme({this.selectedSeed = 0})
      : assert(selectedSeed >= 0 && selectedSeed < _seedCandidates.length);

  /// Tema CLARO
  ThemeData theme() {
    final seed = _seedCandidates[selectedSeed];

    return ThemeData(
      useMaterial3: true, // Usa Material Design 3

      // Color de fondo principal
      scaffoldBackgroundColor: kCreamBg,
      // ColorScheme generado a partir de un seed
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
        primary: kGreenStrong,    // Botones principales
        secondary: kBrandOrange,  // Acentos
        surface: Colors.white,    // Fondos de tarjetas
        background: kCreamBg,     // Fondo de pantalla
      ),

      // Inyectamos nuestra extensión AppColors
      extensions: <ThemeExtension<dynamic>>[
        AppColors.light(),
      ],

      // Configuración del AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: kOrangeDisabled,
        foregroundColor: kDeepDarkOrange,
      ),

      // Inputs de texto (casillitas de formulario)
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),

      // FAB (botón flotante)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white, // texto/ícono del FAB
      ),
    );
  }

  /// Tema OSCURO (si más adelante lo activas)
  ThemeData darkTheme() {
  final seed = _seedCandidates[selectedSeed];

  // 🎯 Paleta manual para oscuro (profesional y neutra)
  const kDarkBg      = Color(0xFF0F0F0F); // fondo global (casi negro)
  const kDarkSurface = Color(0xFF1A1A1A); // superficies (cards, sheets) si no las fijas por widget
  const kOnSurface   = Color(0xFFE6E6E6); // texto/íconos sobre superficies
  // Nota: tus acentos siguen siendo los de la marca:
  // kGreenStrong y kBrandOrange

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ✅ Fondo principal de pantallas
    scaffoldBackgroundColor: kDarkBg,

    // ✅ Colores base del esquema (sobrescribimos lo importante)
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      surface: kDarkSurface,      // superficies por defecto
      onSurface: kOnSurface,      // texto/íconos en superficies
      primary: kGreenStrong,      // acento verde de tu marca
      secondary: kBrandOrange,    // acento naranja de tu marca
    ),

    // ✅ Si usas tu ThemeExtension para íconos/bordes, la conservas
    extensions: <ThemeExtension<dynamic>>[
      AppColors.dark().copyWith(
        // opcional: ajusta tonos de tu extensión si quieres
        // glyph: Color(0xFFBFC3CA),
      ),
    ],

    // ✅ AppBar oscuro consistente (fondo + color de texto/íconos)
    appBarTheme: const AppBarTheme(
      backgroundColor: kDeepDarkGray,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // (Opcional) Si QUIERES que las cards del framework salgan oscuras:
    // cardTheme: const CardTheme(color: kDarkSurface),
    //
    // Nota: tus LoadCards ya fuerzan `color: Colors.white`, así que
    // seguirán viéndose BLANCAS también en oscuro (como pediste).
  );
}
}
