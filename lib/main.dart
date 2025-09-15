import 'package:flutter/material.dart';
import 'presentation/themes/theme_conection.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ConexionCargaApp());
}

class ConexionCargaApp extends StatelessWidget {
  const ConexionCargaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conexión Carga',
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedSeed: 0).theme(), // naranja/verde
      home: const HomePage(), // ← por ahora el home de diseño
      // Mañana: cambia a LoginPage() o usa rutas nombradas
    );
  }
}
