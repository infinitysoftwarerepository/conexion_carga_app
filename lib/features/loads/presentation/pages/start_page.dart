// lib/features/loads/presentation/pages/start_page.dart
import 'package:flutter/material.dart';

/// 🎨 Tema y widgets compartidos de tu app
import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/app/widgets/molecules/start_headline.dart';
import 'package:conexion_carga_app/app/widgets/molecules/bottom_banner_section.dart';
import 'package:conexion_carga_app/app/widgets/organisms/ad_banner_full_width.dart';
import 'package:conexion_carga_app/app/widgets/new_action_fab.dart';
import 'package:conexion_carga_app/app/widgets/glyph_filter.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

/// 🔐 Páginas de auth ya existentes
import 'package:conexion_carga_app/features/loads/presentation/pages/login_page.dart';

/// 🆕 NUEVO: único formulario de registro al que queremos ir directamente
import 'package:conexion_carga_app/features/loads/presentation/pages/registration_form_page.dart';

/// Página de inicio (StartPage)
/// Mantiene tu diseño modular:
/// - AppBar con menú de perfil y toggle de tema
/// - Anuncio/banner superior a todo lo ancho (sin recortes)
/// - Sección inferior con texto + carrusel
class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
    this.userName = '◄ Inicie sesión o registrese',
  });

  /// Subtítulo que muestras bajo el título del AppBar
  final String userName;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  /// Clave para poder abrir el menú contextual (popup) justo debajo del ícono
  final GlobalKey _profileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: const [
            // Parte superior con el anuncio
            Expanded(child: _TopAd()),
            // Parte inferior (texto + carrusel de logos/banners)
            BottomBannerSection(donationNumber: '008-168-23331',),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // APP BAR
  // ────────────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // Color del ícono/título según tema actual
      foregroundColor:
          Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      toolbarHeight: 72,
      centerTitle: true,

      // Ícono de “perfil” que abre el menú de Acciones (Iniciar sesión / Registrarse)
      leading: IconButton(
        key: _profileKey,
        tooltip: 'Perfil',
        icon: const Icon(Icons.person_outline),
        onPressed: _openProfileMenu, // ← abrimos el popup justo debajo del ícono
      ),

      // Título reutilizable con subtítulo (tu componente StartHeadline)
      title: StartHeadline(subtitle: widget.userName),

      // Acciones a la derecha del AppBar: buscar, filtros y el toggle de tema
      actions: const [
        Icon(Icons.search),
        SizedBox(width: 4),
        GlyphFilter(size: 20),
        // No forzamos color: ThemeToggle pinta luna negra en claro / sol blanco en oscuro
        ThemeToggle(size: 22),
        SizedBox(width: 8),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MENÚ DE PERFIL (mostrado debajo del ícono leading)
  // ────────────────────────────────────────────────────────────────────────────

  /// Botón compactado para meter dentro del PopupMenu.
  PopupMenuEntry<void> _menuItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color fg,
    EdgeInsets padding = const EdgeInsets.fromLTRB(12, 12, 12, 12),
  }) {
    return PopupMenuItem<void>(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: padding,
        child: NewActionFab(
          label: label,
          icon: icon,
          backgroundColor: bg,
          foregroundColor: fg,
          onTap: onTap,
        ),
      ),
    );
  }

  /// Helper para navegar a una página con MaterialPageRoute.
  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  /// Abre el popup “anclado” a la posición del botón de perfil.
  Future<void> _openProfileMenu() async {
    // 1) Calculamos la posición del icono “perfil”
    final ro = _profileKey.currentContext?.findRenderObject();
    if (ro is! RenderBox) return;

    final topLeft = ro.localToGlobal(Offset.zero);
    final size = ro.size;
    final position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + size.height, // Colocar el menú justo DEBAJO del ícono
      topLeft.dx + size.width,
      topLeft.dy,
    );

    // 2) Colores del botón del menú (verde marca en claro, verde profundo en oscuro)
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? kGreenStrong : kDeepDarkGreen;
    final fg = isLight ? Colors.white : kGreyText;

    // 3) Mostramos el menú con dos acciones.
    //    👉 Aquí es donde cambiamos la acción “Registrarse” para ir DIRECTO
    //    al nuevo RegistrationFormPage (saltándonos la pantalla de elegir rol).
    await showMenu<void>(
      context: context,
      position: position,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        _menuItem(
          label: 'Iniciar sesión',
          icon: Icons.login,
          bg: bg,
          fg: fg,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          onTap: () {
            Navigator.pop(context);         // cerramos popup
            _push(const LoginPage());       // → Login
          },
        ),
        _menuItem(
          label: 'Registrarse',
          icon: Icons.person_add,
          bg: bg,
          fg: fg,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          onTap: () {
            Navigator.pop(context);         // cerramos popup
            // 👉 Navegamos DIRECTO al formulario único de registro
            _push(const RegistrationFormPage());
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// WIDGET PRIVADO: Parte superior con el anuncio a todo lo ancho (sin recortar)
// ──────────────────────────────────────────────────────────────────────────────
class _TopAd extends StatelessWidget {
  const _TopAd();

  @override
  Widget build(BuildContext context) {
    // Separación inferior para que no quede pegado al carrusel inferior
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: AdBannerFullWidth(
        imageAsset: 'assets/images/ad_start_full.png',
        // Este widget ya maneja proporciones, animación y botón de cierre (✕).
        // Asegúrate de que internamente use `BoxFit.contain` para ver la imagen completa.
      ),
    );
  }
}
