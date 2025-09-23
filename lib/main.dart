import 'package:flutter/material.dart';

/// 1) 🎨 Tema central
/// Asegúrate de que coincida con tu archivo real: 'theme_conection.dart' 
import 'package:bolsa_carga_app/app/theme/theme_conection.dart';

/// 2) 🌗 Controlador + widget del toggle (claro/oscuro)
/// Aquí está el ValueNotifier y el botón que pusimos para cambiar de tema.
import 'package:bolsa_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

/// 3) 🏠 Pantalla inicial REAL
/// Ojo: la carpeta correcta es `screens` y el archivo `home_screen.dart`.
/// Y dentro de ese archivo tu clase debe llamarse **HomeScreen**.
/// import 'package:bolsa_carga_app/features/loads/presentation/pages/home_page.dart';
import 'package:bolsa_carga_app/features/loads/presentation/pages/start_page.dart';

void main() {
  // 🛠 Asegura que Flutter está inicializado antes de ejecutar la app.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}

/// ===============================================================
/// 🥾 Bootstrap
/// Este widget envuelve MaterialApp dentro de un ValueListenableBuilder
/// para escuchar el `ThemeController.themeMode`.
/// Así puedes alternar entre modo claro/oscuro en tiempo real.
/// ===============================================================
class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode, // <- viene de theme_toggle.dart
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'CONEXIÓN CARGA',
          debugShowCheckedModeBanner: false,

          // 🎨 Temas principal y oscuro
          // ⚠️ IMPORTANTE: NO uses `const` porque estás llamando a .theme()
          theme: AppTheme(selectedSeed: 0).theme(),
          darkTheme: AppTheme(selectedSeed: 0).darkTheme(),
          themeMode: mode, // ← controlado por el toggle

          // 🏠 Pantalla inicial
          // Asegúrate que en home_screen.dart la clase sea `HomeScreen`
          home: const StartPage(userName: '◄ Inicie sesión o registrese'),

          // 🚪 Opcional: Define rutas con nombre si quieres navegar con strings
          // routes: {
          //   '/home': (_) => const HomeScreen(userName: 'Nombre de usuario'),
          //   '/loads': (_) => const LoadsPage(),
          // },
        );
      },
    );
  }
}
