// lib/features/loads/presentation/pages/start_page.dart
import 'package:bolsa_carga_app/features/loads/presentation/widgets/glyph_filter.dart';
import 'package:flutter/material.dart';

// 🎨 Colores definidos por ti
import 'package:bolsa_carga_app/app/theme/theme_conection.dart';

// 🌗 Lunita (toggle claro/oscuro)
import 'package:bolsa_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

// 🟢 Botón reutilizable del menú
import 'package:bolsa_carga_app/features/loads/presentation/widgets/new_action_fab.dart';

// 🖼️ Banner inferior (opcional)
import 'package:bolsa_carga_app/features/loads/presentation/widgets/banner_carousel.dart';

// 🏠 Página destino al iniciar sesión

// Registro
import 'package:bolsa_carga_app/features/loads/presentation/pages/signin_page.dart';

import 'package:bolsa_carga_app/features/loads/presentation/pages/login_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
    this.userName = '◄ Inicie sesión o registrese',
  });

  final String userName;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // Key para posicionar el menú justo debajo del muñequito (leading)
  final GlobalKey _profileKey = GlobalKey();

  Future<void> _openProfileMenu() async {
    final renderObject = _profileKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final box = renderObject;
    final Offset topLeft = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    // Posición del popup: justo debajo del botón leading
    final RelativeRect position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + size.height,
      topLeft.dx + size.width,
      topLeft.dy,
    );

    // Colores del botón del menú según tema
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color bg = isLight ? kGreenStrong : kDeepDarkGreen;
    final Color fg = isLight ? Colors.white : kGreyText;

    await showMenu<void>(
      context: context,
      position: position,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: NewActionFab(
              label: 'Iniciar sesión',
              icon: Icons.login,
              backgroundColor: bg,
              foregroundColor: fg,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ),
        ),
        PopupMenuItem<void>(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: NewActionFab(
              label: 'Registrarse',
              icon: Icons.person_add,
              backgroundColor: bg,
              foregroundColor: fg,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        foregroundColor:
            Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        toolbarHeight: 72,
        centerTitle: true,

        // 👤 Muñequito (leading) con key para anclar el menú
        leading: IconButton(
          key: _profileKey,
          tooltip: 'Perfil',
          icon: const Icon(Icons.person_outline),
          onPressed: _openProfileMenu,
        ),

        // Título en dos líneas
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CONEXIÓN CARGA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              '◄ Inicie sesión o registrese',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
                color: Theme.of(context).brightness == Brightness.light
                    ? kGreyText
                    : kGreySoft,
              ),
            ),
          ],
        ),

        // 🔍 + 🌙 (ThemeToggle)
        actions: [
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          const GlyphFilter(size: 20),
          ThemeToggle(
            color: cs.onSurface,
            size: 22,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 📌 Imagen principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/ad_start_full.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),

            // 📌 Texto entre la imagen y el carrusel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                '¡Apoya este proyecto! Ahorros Bancolombia: ###-###-#####',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).brightness == Brightness.light
                      ? kGreyText
                      : kGreySoft,
                ),
              ),
            ),

            // 📌 Banner inferior
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: BannerCarousel(
                height: 140,
                imagePaths: const [
                  'assets/images/logo_conexion_carga_oficial_cliente_V1.png',
                  'assets/images/banner_llantas_30_off.png',
                  'assets/images/banner_seguros_20.png',
                ],
                interval: Duration(seconds: 5),
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
