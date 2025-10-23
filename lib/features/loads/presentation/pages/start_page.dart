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
import 'package:conexion_carga_app/features/loads/presentation/pages/points_page.dart'; // ⬅️ NUEVA IMPORTACIÓN

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
          children: const [
            Expanded(child: _TopAd()),
            BottomBannerSection(donationNumber: '008-168-23331'),
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
      leading: IconButton(
        key: _profileKey,
        tooltip: 'Perfil',
        icon: const Icon(Icons.person_outline),
        onPressed: _openProfileMenu,
      ),
      title: ValueListenableBuilder<AuthUser?>(
        valueListenable: AuthSession.instance.user,
        builder: (_, user, __) {
          final subtitle = (user != null && user.firstName.trim().isNotEmpty)
              ? 'Bienvenido ${user.firstName}'
              : widget.userName;
          return StartHeadline(subtitle: subtitle);
        },
      ),
      actions: const [
        Icon(Icons.search),
        SizedBox(width: 4),
        GlyphFilter(size: 20),
        ThemeToggle(size: 22),
        SizedBox(width: 8),
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

  /// Item visualmente deshabilitado (no clickeable)
  PopupMenuEntry<void> _menuItemDisabled({
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
    EdgeInsets padding = const EdgeInsets.fromLTRB(12, 0, 12, 0),
  }) {
    return PopupMenuItem<void>(
      enabled: false,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: padding,
        child: Opacity(
          opacity: 0.45,
          child: IgnorePointer(
            child: NewActionFab(
              label: label,
              icon: icon,
              backgroundColor: bg,
              foregroundColor: fg,
              onTap: () {}, // ignorado por IgnorePointer
            ),
          ),
        ),
      ),
    );
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
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
      items: user != null
          // ─────────────── MENÚ CUANDO HAY SESIÓN ───────────────
          ? <PopupMenuEntry<void>>[
              _menuItem(
                label: '+ Registrar viaje',
                icon: Icons.add_road,
                bg: bg,
                fg: fg,
                onTap: () {
                  Navigator.pop(context);

                  // Nombre para saludo en LoadsPage
                  final u = AuthSession.instance.user.value;
                  final name = [
                    (u?.firstName ?? '').trim(),
                    (u?.lastName ?? '').trim(),
                  ].where((s) => s.isNotEmpty).join(' ');

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoadsPage(
                        userName: name.isEmpty ? 'Usuario' : name,
                      ),
                    ),
                  );
                },
              ),
              _menuItemDisabled(
                label: 'Editar perfil',
                icon: Icons.edit_outlined,
                bg: bg,
                fg: fg,
              ),
              _menuItem(
                label: 'Mis puntos',
                icon: Icons.stars_outlined,
                bg: bg,
                fg: fg,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PointsPage()),
                  );
                },
              ),
              const PopupMenuDivider(height: 8),
              _menuItem(
                label: 'Cerrar sesión',
                icon: Icons.logout,
                bg: bg,
                fg: fg,
                onTap: () {
                  Navigator.pop(context);
                  AuthSession.instance.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesión cerrada.')),
                  );
                },
              ),
            ]
          // ─────────────── MENÚ CUANDO NO HAY SESIÓN ───────────────
          : <PopupMenuEntry<void>>[
              _menuItem(
                label: 'Iniciar sesión',
                icon: Icons.login,
                bg: bg,
                fg: fg,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                  if (ok == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Bienvenido!')),
                    );
                  }
                },
              ),
              _menuItem(
                label: 'Registrarse',
                icon: Icons.person_add,
                bg: bg,
                fg: fg,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                onTap: () {
                  Navigator.pop(context);
                  _push(const RegistrationFormPage());
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
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: AdBannerFullWidth(
        imageAsset: 'assets/images/ad_start_full.png',
      ),
    );
  }
}
