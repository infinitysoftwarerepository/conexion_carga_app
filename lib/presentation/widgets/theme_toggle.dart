import 'package:flutter/material.dart';

/// ===============================================================
/// 🌗 WIDGET: ThemeToggle
/// Botón reutilizable para alternar entre modo claro y modo oscuro.
/// 
/// 📌 Cómo usarlo:
/// 1. Asegúrate que tu MaterialApp se inicialice con:
///    MaterialApp(
///      theme: AppTheme().theme(),
///      darkTheme: AppTheme().darkTheme(),
///      themeMode: ThemeMode.system, // ← O controlado por un ValueNotifier
///    )
///
/// 2. Envuelve tu MaterialApp con un ValueListenableBuilder
///    o con Provider/GetX/etc. si quieres algo más pro.
///    Por simplicidad, este ejemplo usa un ValueNotifier estático.
/// ===============================================================
class ThemeController {
  /// ValueNotifier guarda el estado actual (ThemeMode)
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Cambia de claro ↔ oscuro
  static void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }
}

class ThemeToggle extends StatelessWidget {
  final double size;
  final Color? color;

  const ThemeToggle({
    super.key,
    this.size = 26,      // tamaño del ícono
    this.color,          // puedes sobreescribir el color si quieres
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        // Elegimos icono según el modo
        final isLight = mode == ThemeMode.light;
        final icon = isLight ? Icons.dark_mode : Icons.light_mode;

        return IconButton(
          tooltip: isLight ? "Cambiar a oscuro" : "Cambiar a claro",
          icon: Icon(icon, size: size, color: color ?? Theme.of(context).iconTheme.color),
          onPressed: ThemeController.toggleTheme,
        );
      },
    );
  }
}
