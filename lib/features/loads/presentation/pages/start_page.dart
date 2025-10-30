// lib/features/loads/presentation/pages/start_page.dart
//
// StartPage
// - Invitado: primera fila con 2 botones (Iniciar sesión / Registrarse)
// - Con sesión: SOLO la primera fila con 3 botones
//      [+ Registrar viaje]  [Mis viajes]  [Mis puntos]
//   * "+ Registrar viaje"  -> NewTripPage
//   * "Mis viajes"         -> LoadsPage   (el widget que tienes en my_loads_page.dart)
//   * "Mis puntos"         -> PointsPage
// - El resto de contenido (LoadCards) lo dejamos para 2 columnas más adelante.
//

import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/app/widgets/molecules/start_headline.dart';
import 'package:conexion_carga_app/app/widgets/molecules/bottom_banner_section.dart';
import 'package:conexion_carga_app/app/widgets/organisms/ad_banner_full_width.dart';
import 'package:conexion_carga_app/app/widgets/new_action_fab.dart';
import 'package:conexion_carga_app/app/widgets/glyph_filter.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

import 'package:conexion_carga_app/features/loads/presentation/pages/login_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/registration_form_page.dart';
// En tu proyecto este archivo define el widget LoadsPage:
import 'package:conexion_carga_app/features/loads/presentation/pages/my_loads_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/points_page.dart';
// Nuevo: registrar viaje directo
import 'package:conexion_carga_app/features/loads/presentation/pages/new_trip_page.dart';

import 'package:conexion_carga_app/core/auth_session.dart';

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
  final GlobalKey _profileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                children: [
                  // ------------------------------------------------------------------
                  // Fila #1 (solamente esta fila cambia a 3 columnas si hay sesión)
                  // ------------------------------------------------------------------
                  ValueListenableBuilder<AuthUser?>(
                    valueListenable: AuthSession.instance.user,
                    builder: (_, user, __) {
                      final isLight =
                          Theme.of(context).brightness == Brightness.light;
                      final bg = isLight ? kGreenStrong : kDeepDarkGreen;
                      final fg = isLight ? Colors.white : kGreyText;

                      if (user == null) {
                        // Invitado: 2 columnas
                        return _TwoButtonGrid(
                          left: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: NewActionFab(
                              label: 'Iniciar sesión',
                              icon: Icons.login,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () async {
                                final ok =
                                    await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginPage()),
                                );
                                if (ok == true && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('¡Bienvenido!')),
                                  );
                                }
                              },
                            ),
                          ),
                          right: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: NewActionFab(
                              label: 'Registrarse',
                              icon: Icons.person_add,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const RegistrationFormPage()),
                                );
                              },
                            ),
                          ),
                        );
                      } else {
                        // Con sesión: 3 columnas (SOLO esta primera fila)
                        return _ThreeButtonGrid(
                          // 1) + Registrar viaje -> NewTripPage
                          left: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: NewActionFab(
                              label: '+ Registrar viaje',
                              icon: Icons.add_road,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const NewTripPage()),
                                );
                              },
                            ),
                          ),
                          // 2) Mis viajes -> LoadsPage (tu pantalla de mis cargas)
                          middle: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: NewActionFab(
                              label: 'Mis viajes',
                              icon: Icons.local_shipping_outlined,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () {
                                final u = AuthSession.instance.user.value;
                                final userName = [
                                  (u?.firstName ?? '').trim(),
                                  (u?.lastName ?? '').trim(),
                                ].where((s) => s.isNotEmpty).join(' ');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LoadsPage(
                                      userName: userName.isEmpty
                                          ? 'Usuario'
                                          : userName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // 3) Mis puntos -> PointsPage
                          right: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: NewActionFab(
                              label: 'Mis puntos',
                              icon: Icons.stars_outlined,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const PointsPage()),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 8),

                  // 🔜 Aquí luego montamos las LoadCards en 2 columnas.
                ],
              ),
            ),

            // Promo pegada al carrusel
            const _TopAd(),

            // Carrusel / banner inferior
            const BottomBannerSection(donationNumber: '008-168-23331'),
          ],
        ),
      ),
    );
  }

  // ===================== AppBar =====================

  PreferredSizeWidget _buildAppBar() {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AppBar(
      foregroundColor: isLight ? Colors.black : Colors.white,
      toolbarHeight: 72,
      centerTitle: false,

      // Lupita SIEMPRE a la izquierda
      leading: IconButton(
        tooltip: 'Buscar',
        icon: const Icon(Icons.search),
        onPressed: () {
          // TODO: abrir buscador global
        },
      ),

      // Título con subtítulo dinámico
      title: ValueListenableBuilder<AuthUser?>(
        valueListenable: AuthSession.instance.user,
        builder: (_, user, __) {
          final subtitle = (user != null && user.firstName.trim().isNotEmpty)
              ? 'Bienvenido ${user.firstName}'
              : widget.userName;

          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: StartHeadline(subtitle: subtitle),
          );
        },
      ),

      // Acciones: muñequito (solo si hay sesión), filtro y toggle
      actions: [
        ValueListenableBuilder<AuthUser?>(
          valueListenable: AuthSession.instance.user,
          builder: (_, user, __) {
            return Row(
              // ✅ aquí estaba el typo: es MainAxisSize, no "MainSize"
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user != null) ...[
                  IconButton(
                    key: _profileKey,
                    tooltip: 'Perfil',
                    icon: const Icon(Icons.person_outline),
                    onPressed: _openProfileMenu,
                  ),
                  const SizedBox(width: 4),
                ],
                const GlyphFilter(size: 20),
                const ThemeToggle(size: 22),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  PopupMenuEntry<void> _menuItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color fg,
    EdgeInsets padding = const EdgeInsets.fromLTRB(12, 12, 12, 12),
    bool enabled = true,
  }) {
    return PopupMenuItem<void>(
      enabled: enabled,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: padding,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.45,
          child: NewActionFab(
            label: label,
            icon: icon,
            backgroundColor: bg,
            foregroundColor: fg,
            onTap: () {
              if (enabled) onTap();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openProfileMenu() async {
    final ro = _profileKey.currentContext?.findRenderObject();
    if (ro is! RenderBox) return;

    final topLeft = ro.localToGlobal(Offset.zero);
    final size = ro.size;
    final position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + size.height,
      topLeft.dx + size.width,
      topLeft.dy,
    );

    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? kGreenStrong : kDeepDarkGreen;
    final fg = isLight ? Colors.white : kGreyText;

    final user = AuthSession.instance.user.value;

    await showMenu<void>(
      context: context,
      position: position,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: <PopupMenuEntry<void>>[
        // Editar perfil (por ahora deshabilitado)
        _menuItem(
          label: 'Editar perfil',
          icon: Icons.edit_outlined,
          bg: bg,
          fg: fg,
          onTap: () {},
          enabled: false,
        ),
        const PopupMenuDivider(height: 8),
        _menuItem(
          label: 'Cerrar sesión',
          icon: Icons.logout,
          bg: bg,
          fg: fg,
          enabled: user != null,
          onTap: () {
            Navigator.pop(context);
            AuthSession.instance.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sesión cerrada.')),
            );
          },
        ),
      ],
    );
  }
}

// ===================== Widgets auxiliares =====================

class _TopAd extends StatelessWidget {
  const _TopAd();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 4, bottom: 8),
      child: AdBannerFullWidth(
        imageAsset: 'assets/images/ad_start_full.png',
      ),
    );
  }
}

/// Rejilla de 2 columnas (invitado y/o secciones futuras 2-col).
class _TwoButtonGrid extends StatelessWidget {
  const _TwoButtonGrid({
    required this.left,
    required this.right,
  });

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [left, right],
    );
  }
}

/// Rejilla SOLO para la primera fila cuando hay sesión (3 columnas).
class _ThreeButtonGrid extends StatelessWidget {
  const _ThreeButtonGrid({
    required this.left,
    required this.middle,
    required this.right,
  });

  final Widget left;
  final Widget middle;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3, // ← división en 3 SOLO para esta fila
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [left, middle, right],
    );
  }
}
