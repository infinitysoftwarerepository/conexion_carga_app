import 'package:flutter/material.dart';

/// 🎨 PALETA PRINCIPAL
const kBrandOrange = Color(0xFFF6A21A); // Naranja header cards
const kBrandGreen  = Color(0xFFA7E27A); // Verde claro botón habilitado
const kGreenStrong = Color(0xFF4CAF50); // Verde acento
const kCreamBg     = Color(0xFFF5F5F2); // Fondo
const kGreySoft    = Color(0xFFEAEAEA); // Botón deshabilitado
const kGreyText    = Color(0xFF6B7280); // Texto secundario

const List<Color> _seedCandidates = [
  kBrandOrange,
  kBrandGreen,
  kGreenStrong,
];

class AppTheme {
  final int selectedSeed;
  const AppTheme({this.selectedSeed = 0})
      : assert(selectedSeed >= 0 && selectedSeed < _seedCandidates.length);

  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kCreamBg,
      colorSchemeSeed: _seedCandidates[selectedSeed],
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
    );
  }
}
