// lib/features/loads/presentation/pages/start_page.dart
import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/app/widgets/molecules/start_headline.dart';
import 'package:conexion_carga_app/app/widgets/molecules/bottom_banner_section.dart';
import 'package:conexion_carga_app/app/widgets/new_action_fab.dart';
import 'package:conexion_carga_app/app/widgets/glyph_filter.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/widgets/load_card.dart';

import 'package:conexion_carga_app/features/loads/presentation/pages/login_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/registration_form_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/my_loads_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/points_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/new_trip_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/trip_detail_page.dart';

import 'package:conexion_carga_app/features/loads/data/loads_api.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';
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

  List<Trip> _publicTrips = const <Trip>[];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final data = await LoadsApi.fetchPublic(limit: 100);
    if (!mounted) return;
    setState(() => _publicTrips = data);
  }

  @override
  Widget build(BuildContext context) {
    final myId = AuthSession.instance.user.value?.id ?? '';

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Header fijo + grid scrolleable comentario
          Column(
            children: [
              // ───────────────── Header fijo con botones (compactos) ─────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: ValueListenableBuilder<AuthUser?>(
                  valueListenable: AuthSession.instance.user,
                  builder: (_, user, __) {
                    final isLight =
                        Theme.of(context).brightness == Brightness.light;
                    final bg = isLight ? kGreenStrong : kDeepDarkGreen;
                    final fg = isLight ? Colors.white : kGreyText;

                    Widget compact(NewActionFab btn) {
                      // Altura bajita + escala automática para evitar overflows
                      return SizedBox(
                        height: 40, // <- compacta (si ves muy apretado, sube a 42)
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: IconTheme(
                            data: const IconThemeData(size: 16), // icono más pequeño
                            child: MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaler: const TextScaler.linear(0.90)),
                              child: btn,
                            ),
                          ),
                        ),
                      );
                    }

                    if (user == null) {
                      // Invitado: 2 botones
                      return Row(
                        children: [
                          Expanded(
                            child: compact(
                              NewActionFab(
                                label: 'Iniciar sesión',
                                icon: Icons.login,
                                backgroundColor: bg,
                                foregroundColor: fg,
                                onTap: () async {
                                  final ok = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                  if (ok == true && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('¡Bienvenido!')),
                                    );
                                    await _reload();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: compact(
                              NewActionFab(
                                label: 'Registrarse',
                                icon: Icons.person_add,
                                backgroundColor: bg,
                                foregroundColor: fg,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegistrationFormPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Con sesión: 3 botones
                    return Row(
                      children: [
                        Expanded(
                          child: compact(
                            NewActionFab(
                              label: '+ Registrar viaje',
                              icon: Icons.add_road,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NewTripPage(),
                                  ),
                                );
                                await _reload();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: compact(
                            NewActionFab(
                              label: 'Mis viajes',
                              icon: Icons.local_shipping_outlined,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoadsPage(userName: ''),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: compact(
                            NewActionFab(
                              label: 'Mis puntos',
                              icon: Icons.stars_outlined,
                              backgroundColor: bg,
                              foregroundColor: fg,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PointsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ───────────────── Grid scrolleable ─────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: _publicTrips.length,
                    itemBuilder: (ctx, i) {
                      final t = _publicTrips[i];
                      final isMine = t.comercialId == myId;

                      // Tap → detalle del viaje
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TripDetailPage(trip: t),
                            ),
                          );
                        },
                        child: LoadCard(trip: t, isMine: isMine),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // ───────────────── Footer fijo con TU BottomBannerSection ─────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              elevation: 12,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const BottomBannerSection(donationNumber: '008-168-23331'),
            ),
          ),
        ],
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
      leading: IconButton(
        tooltip: 'Buscar',
        icon: const Icon(Icons.search),
        onPressed: () {},
      ),
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
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Opacity(
              opacity: 0.45,
              child: NewActionFab(
                label: 'Editar perfil',
                icon: Icons.edit_outlined,
                backgroundColor: bg,
                foregroundColor: fg,
                onTap: () {},
              ),
            ),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<void>(
          enabled: user != null,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: NewActionFab(
              label: 'Cerrar sesión',
              icon: Icons.logout,
              backgroundColor: bg,
              foregroundColor: fg,
              onTap: () {
                Navigator.pop(context);
                AuthSession.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada.')),
                );
                _reload();
              },
            ),
          ),
        ),
      ],
    );
  }
}

