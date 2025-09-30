// lib/features/loads/presentation/pages/start_page.dart
import 'dart:async';
import 'package:flutter/material.dart';

// 🎨 Colores definidos por ti
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

// 🌗 Lunita (toggle claro/oscuro)
import 'package:conexion_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

// 🟢 Botón reutilizable del menú
import 'package:conexion_carga_app/features/loads/presentation/widgets/new_action_fab.dart';

// 🔎 Filtro/ícono (lo dejas como antes)
import 'package:conexion_carga_app/features/loads/presentation/widgets/glyph_filter.dart';

// 🖼️ Banner inferior (opcional)
import 'package:conexion_carga_app/features/loads/presentation/widgets/banner_carousel.dart';

// Páginas
import 'package:conexion_carga_app/features/loads/presentation/pages/signin_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/login_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
    this.userName = '◄ Inicie sesión o registrese',
  });

  final String userName;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  // Key para posicionar el menú justo debajo del muñequito (leading)
  final GlobalKey _profileKey = GlobalKey();

  // -------- Animación del “ad” inicial --------
  late final AnimationController _dismissCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slideDown;

  Timer? _autoTimer;
  bool _adVisible = true; // cuando termina la animación, lo quitamos del árbol

  @override
  void initState() {
    super.initState();

    _dismissCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Curvas suaves y con intención de “absorber”
    final curved = CurvedAnimation(
      parent: _dismissCtrl,
      curve: Curves.easeInOutCubic,
    );

    // Se desvanece
    _fade = Tween<double>(begin: 1.0, end: 0.0).animate(curved);

    // Se reduce un poco al irse
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(curved);

    // Se desliza HACIA ABAJO: y positivo
    // 0.40–0.55 funciona bien para que “apunte” al banner sin moverlo.
    _slideDown =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.55)).animate(curved);

    // Auto-cierre a los 10 segundos
    _autoTimer = Timer(const Duration(seconds: 5), _startDismiss);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _dismissCtrl.dispose();
    super.dispose();
  }

  void _startDismiss() {
    if (!_adVisible || _dismissCtrl.isAnimating) return;
    _dismissCtrl.forward().whenComplete(() {
      if (mounted) setState(() => _adVisible = false);
    });
  }

  Future<void> _openProfileMenu() async {
    final renderObject = _profileKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final box = renderObject;
    final Offset topLeft = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final RelativeRect position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + size.height,
      topLeft.dx + size.width,
      topLeft.dy,
    );

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

        leading: IconButton(
          key: _profileKey,
          tooltip: 'Perfil',
          icon: const Icon(Icons.person_outline),
          onPressed: _openProfileMenu,
        ),

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
              widget.userName,
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
            // ZONA DE CONTENIDO: el banner permanece abajo.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Stack(
                  children: [
                    // (futuras loads cards irán aquí debajo cuando el ad desaparezca)
                    // Por ahora sólo un contenedor vacío para reservar espacio.
                    const SizedBox.expand(),

                    // ---------- AD grande con animación de salida HACIA ABAJO ----------
                    if (_adVisible)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SlideTransition(
                            position: _slideDown,
                            child: FadeTransition(
                              opacity: _fade,
                              child: ScaleTransition(
                                scale: _scale,
                                child: Stack(
                                  children: [
                                    // Imagen con proporción estable para evitar “saltos”
                                    // Usamos AspectRatio para mantenerla completa/centrada.
                                    Positioned.fill(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: 1080, // base “virtual” estable
                                          height: 1350, // relación vertical (4:5 aprox)
                                          child: Image.asset(
                                            'assets/images/ad_start_full.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Botón de cerrar (✕)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Material(
                                        color: Colors.black.withOpacity(0.35),
                                        shape: const CircleBorder(),
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          onTap: _startDismiss,
                                          child: const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(Icons.close,
                                                size: 20, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Texto intermedio
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

            // Banner SIEMPRE abajo (no se mueve)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: BannerCarousel(
                height: 140,
                imagePaths: const [
                  'assets/images/logo_conexion_carga_oficial_cliente_V1.png',
                ],
                interval: const Duration(seconds: 5),
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
