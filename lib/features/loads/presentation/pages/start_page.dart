// lib/features/loads/presentation/pages/start_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

const _adImage = 'assets/images/ad_start_full.png';
const _whatsappIcon = 'assets/icons/whatsapp.png';

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

  // control de animaciones
  bool _showAd = true;
  bool _showHint = false;

  static const double _footerGap = 170;

  @override
  void initState() {
    super.initState();
    _reload();
    _startAdSequence();
  }

  Future<void> _reload() async {
    final data = await LoadsApi.fetchPublic(limit: 100);
    if (!mounted) return;
    setState(() => _publicTrips = data);
  }

  void _startAdSequence() {
    // mostrar publicidad 5 s → desaparecer lentamente
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _showAd = false);

      // mostrar burbuja de dudas durante 5 s
      Timer(const Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() => _showHint = false);
      });
      setState(() => _showHint = true);
    });
  }

  Future<void> _openWhatsApp() async {
  const phone = '+573207259517';

  const message = '''
Tengo conocimiento de que Conexión Carga únicamente facilita la comunicación entre las partes y no asume responsabilidad alguna por la negociación o cumplimiento de los acuerdos. Puedo reportar irregularidades al correo electrónico: conexioncarga@gmail.com
''';

  final encodedMessage = Uri.encodeComponent(message);
  final Uri url = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}?text=$encodedMessage');

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir WhatsApp')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final myId = AuthSession.instance.user.value?.id ?? '';

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ─────────────── CONTENIDO PRINCIPAL ───────────────
          Column(
            children: [
              _buildHeaderButtons(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, _footerGap),
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => TripDetailPage(trip: t)),
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

          // ─────────────── FOOTER ───────────────
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

          // ─────────────── IMAGEN DE PUBLICIDAD ───────────────
          AnimatedSlide(
            offset: _showAd ? Offset.zero : const Offset(0, 1.2),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _showAd ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1200),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                alignment: Alignment.center,
                child: Image.asset(_adImage, fit: BoxFit.contain),
              ),
            ),
          ),

          // ─────────────── BOTÓN FLOTANTE WHATSAPP ───────────────
          Positioned(
            bottom: 140,
            left: 16,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // burbuja temporal “¿Dudas?”
                  AnimatedOpacity(
                    opacity: _showHint ? 1 : 0,
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade600,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('¿Dudas ?', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),

                  // botón circular fijo
                  GestureDetector(
                    onTap: _openWhatsApp,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF25D366),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(_whatsappIcon, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Header =====================
  Widget _buildHeaderButtons(BuildContext context) {
    final user = AuthSession.instance.user.value;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? kGreenStrong : kDeepDarkGreen;
    final fg = isLight ? Colors.white : kGreyText;

    Widget compact(NewActionFab btn) => SizedBox(
          height: 40,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: IconTheme(
              data: const IconThemeData(size: 16),
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(0.90)),
                child: btn,
              ),
            ),
          ),
        );

    if (user == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
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
                      MaterialPageRoute(builder: (_) => const LoginPage()),
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
                      MaterialPageRoute(builder: (_) => const RegistrationFormPage()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
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
                    MaterialPageRoute(builder: (_) => const NewTripPage()),
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
                    MaterialPageRoute(builder: (_) => const MyLoadsPage()),
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
                icon: Icons.card_giftcard_outlined,
                backgroundColor: kBrandOrange,
                foregroundColor: Colors.white,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PointsPage()),
                  );
                },
              ),
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
                if (user != null)
                  IconButton(
                    key: _profileKey,
                    tooltip: 'Perfil',
                    icon: const Icon(Icons.person_outline),
                    onPressed: _openProfileMenu,
                  ),
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
            padding: const EdgeInsets.all(12),
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
            padding: const EdgeInsets.all(12),
            child: NewActionFab(
              label: 'Cerrar sesión',
              icon: Icons.logout,
              backgroundColor: bg,
              foregroundColor: fg,
              onTap: () {
                Navigator.pop(context);
                AuthSession.instance.signOut();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Sesión cerrada.')));
                _reload();
              },
            ),
          ),
        ),
      ],
    );
  }
}
