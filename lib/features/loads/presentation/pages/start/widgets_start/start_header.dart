import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/app/widgets/new_action_fab.dart';

import 'package:conexion_carga_app/core/auth_session.dart';

import 'package:conexion_carga_app/features/loads/presentation/pages/login_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/registration_form_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/my_loads_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/points_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/new_trip_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/profile_page.dart';

/// ===============================================================
/// ✅ StartHeader
/// - Contiene los botones superiores: Login / Registrarse / Registrar viaje / Mis viajes / Mis puntos
/// - Mantiene la lógica original:
///   - Conductor NO puede registrar viajes ni ver mis viajes (mensaje SnackBar)
///   - Aura/Glow animado para "+ Registrar viaje" (solo si NO es driver)
///   - Recarga lista al volver de flujos que cambien datos
///
/// 🎯 Personalización fácil:
/// - Cambia colores (bg/fg) según tu tema
/// - Cambia textos o íconos sin tocar StartPage
/// ===============================================================
class StartHeader extends StatelessWidget {
  const StartHeader({
    super.key,
    required this.registerGlowAnimation,
    required this.onTripsChanged,
  });

  /// Animación creada en StartPage (para no duplicar controllers aquí)
  final Animation<double> registerGlowAnimation;

  /// Callback para recargar viajes cuando algo cambie
  final Future<void> Function() onTripsChanged;

  // Estilo de texto de los botones (idéntico al original)
  static const TextStyle _headerButtonTextStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthUser?>(
      valueListenable: AuthSession.instance.user,
      builder: (_, user, __) {
        final isDriver = user?.isDriver ?? false;

        final isLight = Theme.of(context).brightness == Brightness.light;
        final Color bg = isLight ? kGreenStrong : kDeepDarkGreen;
        final Color fg = Colors.white;

        final List<Widget> buttons = [];

        if (user == null) {
          // -------------------------------------------------------
          // ✅ Usuario NO autenticado
          // -------------------------------------------------------
          buttons.add(
            NewActionFab(
              label: 'Iniciar sesión',
              icon: Icons.login,
              backgroundColor: bg,
              foregroundColor: fg,
              textStyle: _headerButtonTextStyle,
              onTap: () async {
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );

                if (!context.mounted) return;
                if (ok == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Bienvenido!')),
                  );
                  await onTripsChanged();
                }
              },
            ),
          );

          buttons.add(
            NewActionFab(
              label: 'Registrarse',
              icon: Icons.person_add,
              backgroundColor: bg,
              foregroundColor: fg,
              textStyle: _headerButtonTextStyle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegistrationFormPage(),
                  ),
                );
              },
            ),
          );
        } else {
          // -------------------------------------------------------
          // ✅ Usuario autenticado
          // -------------------------------------------------------

          // 1) Registrar viaje
          buttons.add(
            _RegisterTripButton(
              isDriver: isDriver,
              bg: bg,
              fg: fg,
              glowAnimation: registerGlowAnimation,
              onTap: () {
                if (isDriver) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Como conductor no puedes registrar viajes.'),
                    ),
                  );
                  return;
                }

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const NewTripPage()))
                    .then((changed) async {
                  if (changed == true) await onTripsChanged();
                });
              },
            ),
          );

          // 2) Mis viajes
          buttons.add(
            NewActionFab(
              label: 'Mis viajes',
              icon: Icons.local_shipping_outlined,
              backgroundColor: isDriver ? Colors.grey : bg,
              foregroundColor: fg,
              textStyle: _headerButtonTextStyle,
              onTap: () {
                if (isDriver) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Como conductor no puedes registrar viajes.'),
                    ),
                  );
                  return;
                }

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const MyLoadsPage()))
                    .then((changed) async {
                  if (changed == true) await onTripsChanged();
                });
              },
            ),
          );

          // 3) Mis puntos
          buttons.add(
            NewActionFab(
              label: 'Mis puntos',
              icon: Icons.card_giftcard_outlined,
              backgroundColor: kBrandOrange,
              foregroundColor: Colors.white,
              textStyle: _headerButtonTextStyle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PointsPage()),
                );
              },
            ),
          );

          buttons.add(
            NewActionFab(
              label: 'Editar perfil',
              icon: Icons.edit_outlined,
              backgroundColor: bg,
              foregroundColor: fg,
              textStyle: _headerButtonTextStyle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          );
        }

        // Layout original: fila con Expanded para que queden alineados y no se salgan
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                Expanded(child: buttons[i]),
                if (i != buttons.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Botón Registrar viaje con aura animada (idéntico al original)
class _RegisterTripButton extends StatelessWidget {
  const _RegisterTripButton({
    required this.isDriver,
    required this.bg,
    required this.fg,
    required this.glowAnimation,
    required this.onTap,
  });

  final bool isDriver;
  final Color bg;
  final Color fg;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;

  static const TextStyle _headerButtonTextStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    final baseButton = NewActionFab(
      label: '+ Publicar viaje',
      icon: Icons.add_road,
      backgroundColor: isDriver ? Colors.grey : bg,
      foregroundColor: fg,
      textStyle: _headerButtonTextStyle,
      onTap: onTap,
    );

    // Si es conductor, NO animamos (igual que antes)
    if (isDriver) return baseButton;

    return AnimatedBuilder(
      animation: glowAnimation,
      child: baseButton,
      builder: (context, child) {
        final glow = glowAnimation.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.7),
                blurRadius: glow,
                spreadRadius: glow * 0.25,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
