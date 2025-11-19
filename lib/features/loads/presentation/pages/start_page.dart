// lib/features/loads/presentation/pages/start_page.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/app/widgets/molecules/start_headline.dart';
import 'package:conexion_carga_app/app/widgets/molecules/bottom_banner_section.dart';
import 'package:conexion_carga_app/app/widgets/new_action_fab.dart';
import 'package:conexion_carga_app/app/widgets/glyph_filter.dart';
import 'package:conexion_carga_app/app/widgets/glyph_search.dart';
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
  // 🔢 Rangos globales de filtros
  static const double kMinTons = 0;
  static const double kMaxTons = 60;
  static const double kMinPrice = 0;
  static const double kMaxPrice = 100_000_000;

  final GlobalKey _profileKey = GlobalKey();
  List<Trip> _publicTrips = const <Trip>[];

  // búsqueda + filtros
  String _searchQuery = '';
  _TripFilters _filters = _TripFilters();

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
    final Uri url =
        Uri.parse('https://wa.me/${phone.replaceAll('+', '')}?text=$encodedMessage');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  // ------------------- BÚSQUEDA -------------------

  void _openSearchSheet() {
    final controller = TextEditingController(text: _searchQuery);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buscar viajes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText:
                      'Escribe origen, destino, tipo de carga, vehículo, comercial, conductor...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------- FILTROS -------------------

  void _openFiltersSheet() {
    if (_publicTrips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún no hay viajes para filtrar.')),
      );
      return;
    }

    // solo para saber si tiene sentido mostrar sliders
    final tonsValues = _publicTrips
        .map((t) => t.tons)
        .where((v) => v != null)
        .cast<double>()
        .toList();
    final priceValues = _publicTrips
        .map((t) => t.price)
        .where((v) => v != null)
        .cast<num>()
        .toList();

    // ▶️ Rangos fijos pedidos
    const double tonsMin = kMinTons;
    const double tonsMax = kMaxTons;

    const double priceMin = kMinPrice;
    const double priceMax = kMaxPrice;

    _TripFilters local = _filters.copy();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;

        String _fmtMillions(num v) {
          final m = v / 1_000_000;
          return '${m.toStringAsFixed(1)} M';
        }

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final tonsRange = RangeValues(
              local.minTons ?? tonsMin,
              local.maxTons ?? tonsMax,
            );

            final priceRange = RangeValues(
              (local.minPrice ?? priceMin).toDouble(),
              (local.maxPrice ?? priceMax).toDouble(),
            );

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // textos
                    _FilterTextField(
                      label: 'Origen',
                      initialValue: local.origin,
                      onChanged: (v) =>
                          setModalState(() => local.origin = v.trim()),
                    ),
                    _FilterTextField(
                      label: 'Destino',
                      initialValue: local.destination,
                      onChanged: (v) =>
                          setModalState(() => local.destination = v.trim()),
                    ),
                    _FilterTextField(
                      label: 'Tipo de carga',
                      initialValue: local.cargoType,
                      onChanged: (v) =>
                          setModalState(() => local.cargoType = v.trim()),
                    ),
                    _FilterTextField(
                      label: 'Tipo de vehículo',
                      initialValue: local.vehicle,
                      onChanged: (v) =>
                          setModalState(() => local.vehicle = v.trim()),
                    ),
                    _FilterTextField(
                      label: 'Estado',
                      initialValue: local.estado,
                      onChanged: (v) =>
                          setModalState(() => local.estado = v.trim()),
                    ),
                    _FilterTextField(
                      label: 'Comercial',
                      initialValue: local.comercial,
                      onChanged: (v) =>
                          setModalState(() => local.comercial = v.trim()),
                    ),
                    _FilterTextField(
                      label: 'Contacto',
                      initialValue: local.contacto,
                      onChanged: (v) =>
                          setModalState(() => local.contacto = v.trim()),
                    ),
                    _FilterTextField(
                      label: 'Conductor',
                      initialValue: local.conductor,
                      onChanged: (v) =>
                          setModalState(() => local.conductor = v.trim()),
                    ),
                    const SizedBox(height: 8),

                    // rango toneladas
                    if (tonsValues.isNotEmpty) ...[
                      const Text(
                        'Peso (Toneladas)',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      RangeSlider(
                        values: tonsRange,
                        min: tonsMin,
                        max: max(tonsMax, tonsMin + 1),
                        divisions: 20,
                        labels: RangeLabels(
                          tonsRange.start.toStringAsFixed(1),
                          tonsRange.end.toStringAsFixed(1),
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            local.minTons = values.start;
                            local.maxTons = values.end;
                          });
                        },
                      ),
                    ],

                    // rango precio
                    if (priceValues.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Valor del viaje (millones de pesos)',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      RangeSlider(
                        values: priceRange,
                        min: priceMin,
                        max: max(priceMax, priceMin + 1),
                        // pasos de 0.5 millones
                        divisions:
                            ((priceMax - priceMin) ~/ 500000).clamp(1, 1000),
                        labels: RangeLabels(
                          _fmtMillions(priceRange.start),
                          _fmtMillions(priceRange.end),
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            // los valores siguen en pesos, solo el label está en millones
                            local.minPrice = values.start;
                            local.maxPrice = values.end;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _filters = _TripFilters();
                            });
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Limpiar filtros'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _filters = local;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Aplicar filtros'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // aplicar búsqueda + filtros sobre la lista original
  List<Trip> _applyFiltersTo(List<Trip> source) {
    final q = _searchQuery.trim().toLowerCase();

    bool containsIgnore(String? value, String pattern) {
      if (pattern.trim().isEmpty) return true;
      if (value == null || value.trim().isEmpty) return false;
      return value.toLowerCase().contains(pattern.toLowerCase());
    }

    return source.where((t) {
      // filtros de texto
      if (!containsIgnore(t.origin, _filters.origin)) return false;
      if (!containsIgnore(t.destination, _filters.destination)) return false;
      if (!containsIgnore(t.cargoType, _filters.cargoType)) return false;
      if (!containsIgnore(t.vehicle, _filters.vehicle)) return false;
      if (!containsIgnore(t.estado, _filters.estado)) return false;
      if (!containsIgnore(t.comercial, _filters.comercial)) return false;
      if (!containsIgnore(t.contacto, _filters.contacto)) return false;
      // 👇 nuevo filtro por conductor
      if (!containsIgnore(t.conductor, _filters.conductor)) return false;

      // rangos numéricos
      if (_filters.minTons != null) {
        if (t.tons == null || t.tons! < _filters.minTons!) return false;
      }
      if (_filters.maxTons != null) {
        if (t.tons == null || t.tons! > _filters.maxTons!) return false;
      }

      if (_filters.minPrice != null) {
        final v = t.price;
        if (v == null || v < _filters.minPrice!) return false;
      }
      if (_filters.maxPrice != null) {
        final v = t.price;
        if (v == null || v > _filters.maxPrice!) return false;
      }

      // búsqueda libre
      if (q.isEmpty) return true;

      final buffer = StringBuffer()
        ..write(t.origin)
        ..write(' ')
        ..write(t.destination)
        ..write(' ')
        ..write(t.cargoType)
        ..write(' ')
        ..write(t.vehicle)
        ..write(' ')
        ..write(t.estado)
        ..write(' ')
        ..write(t.comercial)
        ..write(' ')
        ..write(t.contacto)
        ..write(' ')
        ..write(t.conductor ?? '')
        ..write(' ')
        ..write(t.tons?.toString() ?? '')
        ..write(' ')
        ..write(t.price?.toString() ?? '');

      final haystack = buffer.toString().toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final myId = AuthSession.instance.user.value?.id ?? '';
    final trips = _applyFiltersTo(_publicTrips);

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
                    padding:
                        const EdgeInsets.fromLTRB(12, 0, 12, _footerGap),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: trips.length,
                    itemBuilder: (ctx, i) {
                      final t = trips[i];
                      final isMine = t.comercialId == myId;
                      return GestureDetector(
                        onTap: () async {
                          final changed = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(builder: (_) => TripDetailPage(trip: t)),
                          );

                          // si el detalle cerró con `Navigator.pop(context, true);`
                          // volvemos a consultar los viajes del backend
                          if (changed == true) {
                            await _reload(); // ← tu método que ya existe y hace LoadsApi.fetchPublic...
                          }
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
              child:
                  const BottomBannerSection(donationNumber: '008-168-23331'),
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
                  Container(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('¿Dudas ?',
                              style:
                                  TextStyle(fontWeight: FontWeight.w700)),
                        ],
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
                        child: Image.asset(_whatsappIcon,
                            fit: BoxFit.contain),
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
                      MaterialPageRoute(
                          builder: (_) => const RegistrationFormPage()),
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
                    MaterialPageRoute(
                        builder: (_) => const MyLoadsPage()),
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
                    MaterialPageRoute(
                        builder: (_) => const PointsPage()),
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
      leading: GlyphSearch(
        onTap: _openSearchSheet,
        color: isLight ? Colors.black87 : Colors.white,
        tooltip: 'Buscar viajes',
        padding: const EdgeInsets.only(left: 8),
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
                GlyphFilter(
                  size: 20,
                  onTap: _openFiltersSheet,
                ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesión cerrada.')));
                _reload();
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== Clases auxiliares =====================

class _TripFilters {
  String origin;
  String destination;
  String cargoType;
  String vehicle;
  String estado;
  String comercial;
  String contacto;
  String conductor;

  double? minTons;
  double? maxTons;
  num? minPrice;
  num? maxPrice;

  _TripFilters({
    this.origin = '',
    this.destination = '',
    this.cargoType = '',
    this.vehicle = '',
    this.estado = '',
    this.comercial = '',
    this.contacto = '',
    this.conductor = '',
    this.minTons,
    this.maxTons,
    this.minPrice,
    this.maxPrice,
  });

  _TripFilters copy() => _TripFilters(
        origin: origin,
        destination: destination,
        cargoType: cargoType,
        vehicle: vehicle,
        estado: estado,
        comercial: comercial,
        contacto: contacto,
        conductor: conductor,
        minTons: minTons,
        maxTons: maxTons,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

  bool get isEmpty =>
      origin.isEmpty &&
      destination.isEmpty &&
      cargoType.isEmpty &&
      vehicle.isEmpty &&
      estado.isEmpty &&
      comercial.isEmpty &&
      contacto.isEmpty &&
      conductor.isEmpty &&
      minTons == null &&
      maxTons == null &&
      minPrice == null &&
      maxPrice == null;
}

class _FilterTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _FilterTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
