import 'package:flutter/material.dart';

import 'package:conexion_carga_app/core/auth_session.dart'; // <-- importa

/// 🎨 Tema central
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

/// 🌗 Controlador + widget del toggle (claro/oscuro)
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

/// 🏠 Pantalla inicial
import 'package:conexion_carga_app/features/loads/presentation/pages/start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSession.instance.hydrate();// <-- añade esto
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

          theme: AppTheme(selectedSeed: 0).theme(),
          darkTheme: AppTheme(selectedSeed: 0).darkTheme(),
          themeMode: mode,

          // 👇 StartPage ahora reacciona sola a la sesión (no hace falta pasar nombre)
          home: const StartPage(userName: 'Inicie sesión o registrese'),
        );
      },
    );
  }
}
