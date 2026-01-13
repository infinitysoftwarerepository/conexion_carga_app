// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 NUEVO

import 'package:conexion_carga_app/core/auth_session.dart';

/// 🎨 Tema central (colores corporativos)
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

/// 🌗 Controlador + widget del toggle (claro/oscuro)
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

/// 🏠 Pantalla inicial
import 'package:conexion_carga_app/features/loads/presentation/pages/start/start_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 BLOQUEO DE ORIENTACIÓN (SOLO VERTICAL)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Hidrata la sesión desde storage local (token, user, etc.)
  await AuthSession.instance.hydrate();

  runApp(const Bootstrap());
}


/// ===============================================================
/// 🥾 Bootstrap
/// Escucha el ThemeController para claro/oscuro.
/// ===============================================================
class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'CONEXIÓN CARGA',
          debugShowCheckedModeBanner: false,

          // Tema claro / oscuro con tu paleta
          theme: AppTheme(selectedSeed: 0).theme(),
          darkTheme: AppTheme(selectedSeed: 0).darkTheme(),
          themeMode: mode,

          // StartPage se conecta sola a AuthSession, el parámetro
          // userName es solo un texto de fallback.
          home: const StartPage(userName: '◄ Inicie sesión o registresé'),
        );
      },
    );
  }
}
