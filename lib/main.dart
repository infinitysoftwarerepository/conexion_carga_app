// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/start/start_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/registration_form_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await AuthSession.instance.hydrate();

  runApp(const Bootstrap());
}

class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final rawName = settings.name ?? '/';

    Uri uri;
    try {
      uri = Uri.parse(rawName);
    } catch (_) {
      uri = Uri(path: '/');
    }

    final path = uri.path.isEmpty ? '/' : uri.path;

    if (path == '/register') {
      final ref = uri.queryParameters['ref']?.trim();
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => RegistrationFormPage(
          initialReferrerEmail: (ref == null || ref.isEmpty) ? null : ref,
        ),
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const StartPage(
        userName: '◄ Inicie sesión o registresé',
      ),
    );
  }

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
          initialRoute: '/',
          onGenerateRoute: _onGenerateRoute,
        );
      },
    );
  }
}