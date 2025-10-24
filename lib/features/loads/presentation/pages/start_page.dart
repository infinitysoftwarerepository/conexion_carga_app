// lib/features/loads/presentation/pages/start_page.dart

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
import 'package:conexion_carga_app/features/loads/presentation/pages/my_loads_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/points_page.dart';

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
                  // Fila 1: dos columnas con CTAs según estado de sesión
                  ValueListenableBuilder<AuthUser?>(
                    valueListenable: AuthSession.instance.user,
                    builder: (_, user, __) {
                      final isLight =
                          Theme.of(context).brightness == Brightness.light;
                      final bg = isLight ? kGreenStrong : kDeepDarkGreen;
                      final fg = isLight ? Colors.white : kGreyText;

                      if (user == null) {
                        // Invitado: Iniciar sesión / Registrarse
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
                        // Con sesión: Registrar viaje / Mis puntos
                        return _TwoButtonGrid(
                          left: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: NewActionFab(
                              label: '+ Registrar viaje',
                              icon: Icons.add_road,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () {
                                final u = AuthSession.instance.user.value;
                                final name = [
                                  (u?.firstName ?? '').trim(),
                                  (u?.lastName ?? '').trim(),
                                ].where((s) => s.isNotEmpty).join(' ');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LoadsPage(
                                      userName:
                                          name.isEmpty ? 'Usuario' : name,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
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

                  // 🔜 Aquí luego irán las LoadCards públicas
                ],
              ),
            ),

            // Promo de 5s pegada al carrusel
            const _TopAd(),

            // Carrusel / banner inferior
            const BottomBannerSection(donationNumber: '008-168-23331'),
          ],
        ),
      ),
    );
  }

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

      // Título con subtítulo dinámico (envuelto en FittedBox para evitar cortes)
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
        // Editar perfil (siempre deshabilitado por ahora)
        _menuItem(
          label: 'Editar perfil',
          icon: Icons.edit_outlined,
          bg: bg,
          fg: fg,
          onTap: () {},
          enabled: false,
        ),
        const PopupMenuDivider(height: 8),
        // Cerrar sesión (habilitado solo si hay sesión)
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

class _TopAd extends StatelessWidget {
  const _TopAd();

  @override
  Widget build(BuildContext context) {
    // colocado justo encima del carrusel
    return const Padding(
      padding: EdgeInsets.only(top: 4, bottom: 8),
      child: AdBannerFullWidth(
        imageAsset: 'assets/images/ad_start_full.png',
      ),
    );
  }
}

/// Rejilla de 2 columnas para los CTA superiores.
/// Cada botón va envuelto en FittedBox para evitar desbordes.
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
      // Un poco más ancho para reducir la probabilidad de overflow
      childAspectRatio: 3.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [left, right],
    );
  }
}
