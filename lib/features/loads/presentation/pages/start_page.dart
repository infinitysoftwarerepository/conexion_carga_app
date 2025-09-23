// lib/features/loads/presentation/pages/start_page.dart
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
import 'package:bolsa_carga_app/features/loads/presentation/pages/home_page.dart';

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
      color: Theme.of(context).colorScheme.surface, // fondo del popup
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
                Navigator.pop(context); // cierra el popup
                // 👉 Navega a Home; usa pushReplacement para no volver con "back"
                Future.microtask(() {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(
                        userName: '◄ Registrese o inicie sesión',
                      ),
                    ),
                  );
                });
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
                Navigator.pop(context); // por ahora solo cierra
                // TODO: Navegar a register_page cuando la tengas
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
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              widget.userName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),

        // 🔍 + 🌙 (ThemeToggle)
        actions: [
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search),
            onPressed: () {}, // futuro buscador
          ),
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
            // Grilla vacía (placeholder)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 3,
                  children: const [],
                ),
              ),
            ),

            // Banner inferior (puedes dejar 1 o varias imágenes)
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
