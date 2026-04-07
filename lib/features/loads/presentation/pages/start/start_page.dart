import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:conexion_carga_app/app/widgets/clean_filter.dart'; // 👈 NUEVO


import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';

// 🎨 Tema y colores (los tuyos)
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

// 🧩 Widgets de tu app (ya existentes)
import 'package:conexion_carga_app/app/widgets/molecules/start_headline.dart';
import 'package:conexion_carga_app/app/widgets/glyph_filter.dart';
import 'package:conexion_carga_app/app/widgets/glyph_search.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

// 🔐 Sesión / usuario
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/core/app_version_policy.dart';

// 🌐 Datos
import 'package:conexion_carga_app/features/loads/data/loads_api.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';

// 📄 Navegación a donación
import 'package:conexion_carga_app/features/loads/presentation/pages/donation_page.dart';

// ✅ Widgets extraídos (refactor paso 3)
import 'widgets_start/start_header.dart';
import 'widgets_start/trips_grid.dart';
import 'widgets_start/start_footer_banner.dart';
import 'widgets_start/ad_overlay.dart';
import 'widgets_start/whatsapp_help_button.dart';
import 'widgets_start/search_count_bubble.dart';

/// ============================================================================
/// ✅ Assets usados en esta pantalla.
/// Si cambias la imagen o ícono, cambia estas constantes.
/// ============================================================================
const _adImage = 'assets/images/ad_start_full.png';
const _whatsappIcon = 'assets/icons/whatsapp.png';

class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
    this.userName = '◄ Inicie sesión o registrese',
  });

  /// Texto que se muestra cuando NO hay user.firstName
  /// o cuando no hay usuario autenticado.
  final String userName;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  // ============================================================================
  // ✅ 1) ANIMACIÓN: Aura del botón "+ Registrar viaje"
  // ----------------------------------------------------------------------------
  // - Se mantiene la idea que ya tenías.
  // - La UI del botón vive en StartHeader (widget extraído).
  // - Aquí solo mantenemos el Controller y la Animation.
  // ============================================================================
  late final AnimationController _registerGlowController;
  late final Animation<double> _registerGlowAnimation;

  // ============================================================================
  // ✅ 2) Rangos globales para sliders de filtros
  // ----------------------------------------------------------------------------
  // Estos valores ayudan a que los sliders tengan un rango fijo.
  // ============================================================================
  static const double kMinTons = 0;
  static const double kMaxTons = 60;
  static const double kMinPrice = 0;
  static const double kMaxPrice = 100_000_000;

  // ============================================================================
  // ✅ 3) Key para el menú del perfil (AppBar)
  // ----------------------------------------------------------------------------
  // Se usa para ubicar el menú justo debajo del icono del perfil.
  // ============================================================================
  final GlobalKey _profileKey = GlobalKey();

  // ============================================================================
  // ✅ 4) Debounce para búsqueda
  // ----------------------------------------------------------------------------
  // “Debounce” significa: cuando el usuario escribe rápido,
  // NO filtramos en cada letra, esperamos ~200ms.
  // Esto mejora mucho la fluidez.
  // ============================================================================
  Timer? _searchDebounce;

  // ============================================================================
  // ✅ 5) Datos (lista completa y lista visible)
  // ----------------------------------------------------------------------------
  // - _publicTrips: lista completa que llega del API
  // - _visibleTrips: lista ya filtrada para pintar (OPTIMIZACIÓN)
  //
  // Idea: el build NO debe filtrar cada vez.
  // ============================================================================
  List<Trip> _publicTrips = const <Trip>[];
  List<Trip> _visibleTrips = const <Trip>[];

  // ============================================================================
  // ✅ 6) Estado de búsqueda + filtros
  // ============================================================================
  String _searchQuery = '';
  _TripFilters _filters = _TripFilters();

  // ============================================================================
  // ✅ 7) Control UI (publicidad + hint WhatsApp)
  // ============================================================================
  bool _showAd = true;
  bool _showHint = false;
  bool _checkingVersion = false;
  bool _forceUpdateRequired = false;
  bool _updateFlowStarted = false;
  AppVersionPolicy? _versionPolicy;
  String _currentVersion = '';
  int _currentBuild = 0;

  bool get _hasActiveSearchOrFilters =>
      _searchQuery.trim().isNotEmpty || !_filters.isEmpty;

  // ============================================================================
  // ✅ 8) Recalcular _visibleTrips SOLO cuando cambie algo importante
  // ----------------------------------------------------------------------------
  // Esto es el corazón de la optimización:
  // - Antes: filtrabas dentro del build() (muchas veces por segundo).
  // - Ahora: filtramos SOLO cuando:
  //   * llega nueva data (_reload)
  //   * cambia el texto de búsqueda
  //   * se aplican/limpian filtros
  // ============================================================================
  void _recomputeVisibleTrips() {
    // Si NO hay búsqueda ni filtros, no gastes CPU:
    // mostramos directamente la lista completa.
    if (_searchQuery.trim().isEmpty && _filters.isEmpty) {
      if (!mounted) return;
      setState(() => _visibleTrips = _publicTrips);
      return;
    }

    // Si sí hay búsqueda/filtros, usamos tu lógica existente.
    final computed = _applyFiltersTo(_publicTrips);

    if (!mounted) return;
    setState(() => _visibleTrips = computed);
  }

    // ✅ NUEVO: limpia lupita + filtros y recalcula
  void _clearSearchAndFilters() {
    _searchDebounce?.cancel();

    if (!_hasActiveSearchOrFilters) return;

    setState(() {
      _searchQuery = '';
      _filters = _TripFilters();
    });

    _recomputeVisibleTrips();
  }


  @override
  void initState() {
    super.initState();

    _checkVersionPolicy();

    // 1) Cargar viajes (sin cambiar lógica)
    _reload();

    // 2) Secuencia publicidad -> hint
    _startAdSequence();

    // 3) Aura verde pulsante para "+ Registrar viaje"
    _registerGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _registerGlowAnimation = Tween<double>(begin: 0.0, end: 18.0).animate(
      CurvedAnimation(
        parent: _registerGlowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // ✅ MUY IMPORTANTE: cancelar timers para evitar “memory leaks”
    _searchDebounce?.cancel();

    // ✅ Controller animación
    _registerGlowController.dispose();
    super.dispose();
  }

  // ============================================================================
  // ✅ ACTUALIZACION OBLIGATORIA
  // ----------------------------------------------------------------------------
  Future<void> _checkVersionPolicy() async {
    if (_checkingVersion) return;
    _checkingVersion = true;

    try {
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;
      _currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final platform = Platform.isIOS ? 'ios' : 'android';
      final uri = Uri.parse('${Env.baseUrl}/api/app/version-policy').replace(
        queryParameters: {
          'platform': platform,
          'version': _currentVersion,
          'build': _currentBuild.toString(),
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final policy = AppVersionPolicy.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _cachePolicy(policy);
        if (!mounted) return;
        if (policy.forceUpdate) {
          setState(() {
            _forceUpdateRequired = true;
            _versionPolicy = policy;
          });
          if (Platform.isAndroid) {
            await _attemptImmediateUpdate();
          }
        } else {
          setState(() {
            _forceUpdateRequired = false;
            _versionPolicy = policy;
          });
        }
      } else {
        await _loadCachedPolicyIfNeeded();
      }
    } catch (_) {
      await _loadCachedPolicyIfNeeded();
    } finally {
      _checkingVersion = false;
    }
  }

  Future<void> _attemptImmediateUpdate() async {
    if (_updateFlowStarted) return;
    _updateFlowStarted = true;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return;
      }
    } catch (_) {
      // Si falla el flujo Play, dejamos el bloqueo con botón a tienda.
    } finally {
      _updateFlowStarted = false;
    }
  }

  Future<void> _cachePolicy(AppVersionPolicy policy) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'app_version_policy_${policy.platform}';
    await prefs.setString(key, policy.toJsonString());
  }

  Future<void> _loadCachedPolicyIfNeeded() async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    final prefs = await SharedPreferences.getInstance();
    final cached = AppVersionPolicy.fromJsonString(
      prefs.getString('app_version_policy_$platform'),
    );

    if (!mounted || cached == null) return;

    if (cached.forceUpdate) {
      setState(() {
        _forceUpdateRequired = true;
        _versionPolicy = cached;
      });
      if (Platform.isAndroid) {
        await _attemptImmediateUpdate();
      }
    }
  }

  Future<void> _openStoreUrl() async {
    final url = _versionPolicy?.storeUrl ??
        (Platform.isAndroid
            ? 'https://play.google.com/store/apps/details?id=com.infinitysoftware.conexioncarga'
            : null);
    if (url == null || url.trim().isEmpty) {
      return;
    }
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ============================================================================
  // ✅ DATA
  // ============================================================================

  /// Recarga el listado público de viajes.
  /// - Aquí es donde mañana podrías paginar.
  /// - Después de recargar, recalculamos _visibleTrips UNA vez.
  Future<void> _reload() async {
    final data = await LoadsApi.fetchPublic(limit: 100);
    if (!mounted) return;

    setState(() {
      _publicTrips = data;
    });

    // ✅ recalcula lo visible después de cambiar los datos
    _recomputeVisibleTrips();
  }

  /// Secuencia:
  /// 1) Mostrar publicidad 5s
  /// 2) Ocultar publicidad
  /// 3) Mostrar hint WhatsApp y dejarlo fijo
  void _startAdSequence() {
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _showAd = false;
        _showHint = true;
      });
    });
  }

  /// Abre WhatsApp en modo externo.
  /// Si quieres cambiar el mensaje o el teléfono, edítalo aquí.
  Future<void> _openWhatsApp() async {
    const phone = '+573019043971';

    const message = '''
 Tengo conocimiento de que Conexión Carga únicamente facilita la comunicación entre las partes y no asume responsabilidad alguna por la negociación o cumplimiento de los acuerdos. Puedo reportar irregularidades al Whatsapp +57 3019043971
''';

    final encodedMessage = Uri.encodeComponent(message);
    final Uri url = Uri.parse(
      'https://wa.me/${phone.replaceAll('+', '')}?text=$encodedMessage',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  // ============================================================================
  // ✅ BÚSQUEDA (LUPITA)
  // ============================================================================

  /// Modal de búsqueda (igual a tu versión, pero con debounce + recompute)
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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

                      // 1) limpia query
                      setState(() {
                        _searchQuery = '';
                      });

                      // 2) recalcula lista visible (una vez)
                      _recomputeVisibleTrips();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                // ✅ Debounce: espera 200ms después de escribir
                onChanged: (value) {
                  _searchDebounce?.cancel();
                  _searchDebounce =
                      Timer(const Duration(milliseconds: 200), () {
                    if (!mounted) return;

                    setState(() {
                      _searchQuery = value;
                    });

                    _recomputeVisibleTrips();
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

  // ============================================================================
  // ✅ FILTROS (3 RAYITAS)
  // ============================================================================

  void _openFiltersSheet() {
    if (_publicTrips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún no hay viajes para filtrar.')),
      );
      return;
    }

    // (Se mantiene aunque no uses todas, por seguridad)
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

    const double tonsMin = kMinTons;
    const double tonsMax = kMaxTons;
    const double priceMin = kMinPrice;
    const double priceMax = kMaxPrice;

    // Copia local para no afectar _filters hasta “Aplicar”
    _TripFilters local = _filters.copy();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;

        String fmtMillions(num v) {
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 8),

                    // ---- Slider de toneladas ----
                    if (tonsValues.isNotEmpty) ...[
                      const Text(
                        'Peso (Toneladas)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

                    // ---- Slider de precio ----
                    if (priceValues.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Valor flete (millones de pesos)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RangeSlider(
                        values: priceRange,
                        min: priceMin,
                        max: max(priceMax, priceMin + 1),
                        divisions:
                            ((priceMax - priceMin) ~/ 500000).clamp(1, 1000),
                        labels: RangeLabels(
                          fmtMillions(priceRange.start),
                          fmtMillions(priceRange.end),
                        ),
                        onChanged: (values) {
                          setModalState(() {
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
                        // ✅ Limpiar filtros
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _filters = _TripFilters();
                            });

                            Navigator.pop(ctx);

                            // ✅ recalcular lista visible una vez
                            _recomputeVisibleTrips();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Limpiar filtros'),
                        ),

                        // ✅ Aplicar filtros
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _filters = local;
                            });

                            Navigator.pop(ctx);

                            // ✅ recalcular lista visible una vez
                            _recomputeVisibleTrips();
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

  // ============================================================================
  // ✅ NORMALIZACIÓN ESPAÑOL
  // ----------------------------------------------------------------------------
  // Esto es tu “magia” para:
  // - medellin → Medellín
  // - san jose → San José
  // - penol → Peñol
  //
  // 1) lowerCase
  // 2) quitar tildes/diéresis
  // 3) ñ → n
  // ============================================================================
  String _normalizeEs(String? input) {
    if (input == null) return '';
    final lower = input.toLowerCase();
    final buffer = StringBuffer();

    for (int i = 0; i < lower.length; i++) {
      final ch = lower[i];
      switch (ch) {
        case 'á':
        case 'à':
        case 'ä':
        case 'â':
        case 'ã':
          buffer.write('a');
          break;
        case 'é':
        case 'è':
        case 'ë':
        case 'ê':
          buffer.write('e');
          break;
        case 'í':
        case 'ì':
        case 'ï':
        case 'î':
          buffer.write('i');
          break;
        case 'ó':
        case 'ò':
        case 'ö':
        case 'ô':
        case 'õ':
          buffer.write('o');
          break;
        case 'ú':
        case 'ù':
        case 'ü':
        case 'û':
          buffer.write('u');
          break;
        case 'ñ':
          buffer.write('n');
          break;
        default:
          buffer.write(ch);
      }
    }

    return buffer.toString();
  }

  /// “Fuzzy contains” para español
  bool _fuzzyContainsEs(String? text, String pattern) {
    final normalizedPattern = _normalizeEs(pattern).trim();
    if (normalizedPattern.isEmpty) return true;
    if (text == null || text.trim().isEmpty) return false;

    final normalizedText = _normalizeEs(text);
    return normalizedText.contains(normalizedPattern);
  }

  // ============================================================================
  // ✅ APLICAR BÚSQUEDA + FILTROS (SIN CAMBIAR TU LÓGICA)
  // ----------------------------------------------------------------------------
  // Importante:
  // - Esta función puede ser costosa si se llama 100 veces por segundo.
  // - Por eso ahora solo se llama dentro de _recomputeVisibleTrips().
  // ============================================================================
  List<Trip> _applyFiltersTo(List<Trip> source) {
    final normalizedQuery = _normalizeEs(_searchQuery.trim());

    return source.where((t) {
      if (!_fuzzyContainsEs(t.origin, _filters.origin)) return false;
      if (!_fuzzyContainsEs(t.destination, _filters.destination)) return false;
      if (!_fuzzyContainsEs(t.cargoType, _filters.cargoType)) return false;
      if (!_fuzzyContainsEs(t.vehicle, _filters.vehicle)) return false;
      if (!_fuzzyContainsEs(t.estado, _filters.estado)) return false;
      if (!_fuzzyContainsEs(t.comercial, _filters.comercial)) return false;
      if (!_fuzzyContainsEs(t.contacto, _filters.contacto)) return false;
      if (!_fuzzyContainsEs(t.conductor, _filters.conductor)) return false;

      // rangos
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
      if (normalizedQuery.isEmpty) return true;

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

      final haystackNorm = _normalizeEs(buffer.toString());
      return haystackNorm.contains(normalizedQuery);
    }).toList();
  }

  // ============================================================================
  // ✅ BUILD (StartPage ahora es orquestador)
  // ----------------------------------------------------------------------------
  // Importante:
  // - El build NO filtra.
  // - Solo usa _visibleTrips que ya viene calculado.
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    final myId = AuthSession.instance.user.value?.id ?? '';
    final trips = _visibleTrips;

    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light();

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final int tripsCount = trips.length;
    final bool showCounterBubble = _hasActiveSearchOrFilters;

    final bool showCleanFilter = showCounterBubble && tripsCount == 0;
    final bool cleanEnabled = _publicTrips.isNotEmpty && _hasActiveSearchOrFilters;

    if (_forceUpdateRequired) {
      return ForceUpdateScreen(
        message: _versionPolicy?.message ??
            'Debes actualizar la app para continuar.',
        storeUrl: _versionPolicy?.storeUrl,
        onUpdatePressed: _openStoreUrl,
        canOpenStore: (_versionPolicy?.storeUrl?.trim().isNotEmpty ?? false) ||
            Platform.isAndroid,
        onRetryPressed: Platform.isAndroid ? _attemptImmediateUpdate : null,
        version: _currentVersion,
        buildNumber: _currentBuild,
        comparisonMode: _versionPolicy?.comparisonMode ?? 'version',
        minVersion: _versionPolicy?.minSupportedVersion,
        minBuild: _versionPolicy?.minSupportedBuild,
        latestVersion: _versionPolicy?.latestVersion,
        latestBuild: _versionPolicy?.latestBuild,
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ----------------------
          // CONTENIDO PRINCIPAL
          // ----------------------
          Column(
            children: [
              // Header (botones arriba)
              StartHeader(
                registerGlowAnimation: _registerGlowAnimation,
                onTripsChanged: _reload,
              ),

              // Burbuja conteo solo si hay búsqueda/filtros
             if (showCounterBubble)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SearchCountBubble(count: tripsCount),
                      if (showCleanFilter) ...[
                        const SizedBox(width: 8),
                        CleanFilter(
                          enabled: cleanEnabled,
                          onTap: cleanEnabled ? _clearSearchAndFilters : null,
                          showLabel: false, // 👈 compacto para que no reviente en móvil
                        ),
                      ],
                    ],
                  ),
                ),
              ),


              // Grid de viajes
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: TripsGrid(
                    trips: trips,
                    myId: myId,
                    onTripsChanged: _reload,
                  ),
                ),
              ),
            ],
          ),

          // Footer fijo
          StartFooterBanner(
            donationNumber: '0091262121',
            onTapDonation: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DonationPage()),
              );
            },
          ),

          // Publicidad overlay (solo vertical)
          AdOverlay(
            isPortrait: isPortrait,
            showAd: _showAd,
            imageAsset: _adImage,
          ),

          // WhatsApp + hint
          WhatsAppHelpButton(
            showHint: _showHint,
            helpBubbleBg: appColors.helpBubbleBg,
            iconAsset: _whatsappIcon,
            onTap: _openWhatsApp,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ✅ APPBAR (se deja aquí porque usa _profileKey y menús)
  // ============================================================================
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
          final subtitle =
              (user != null && user.firstName.trim().isNotEmpty)
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
                GlyphFilter(size: 20, onTap: _openFiltersSheet),
                const ThemeToggle(size: 22),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Menú del perfil (igual)
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
              child: _DisabledActionButton(
                label: 'Editar perfil',
                icon: Icons.edit_outlined,
                bg: bg,
                fg: fg,
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
            child: _LogoutActionButton(
              bg: bg,
              fg: fg,
              onLogout: () {
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

/// ---------------------------------------------------------------------------
/// Helpers del menú de perfil
/// ---------------------------------------------------------------------------

class _DisabledActionButton extends StatelessWidget {
  const _DisabledActionButton({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LogoutActionButton extends StatelessWidget {
  const _LogoutActionButton({
    required this.bg,
    required this.fg,
    required this.onLogout,
  });

  final Color bg;
  final Color fg;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onLogout,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, color: fg, size: 18),
            const SizedBox(width: 8),
            Text(
              'Cerrar sesión',
              style: TextStyle(color: fg, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ Clases auxiliares (sin cambios funcionales)
// ============================================================================

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

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({
    super.key,
    required this.message,
    required this.onUpdatePressed,
    required this.canOpenStore,
    this.onRetryPressed,
    this.storeUrl,
    required this.version,
    required this.buildNumber,
    required this.comparisonMode,
    this.minVersion,
    this.minBuild,
    this.latestVersion,
    this.latestBuild,
  });

  final String message;
  final String? storeUrl;
  final VoidCallback onUpdatePressed;
  final bool canOpenStore;
  final VoidCallback? onRetryPressed;
  final String version;
  final int buildNumber;
  final String comparisonMode;
  final String? minVersion;
  final int? minBuild;
  final String? latestVersion;
  final int? latestBuild;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: isLight ? const Color(0xFFF7F8FC) : cs.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.system_update,
                        color: cs.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Actualización obligatoria',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (version.isNotEmpty)
                      Text(
                        'Versión instalada: $version ($buildNumber)',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.55),
                            ),
                      ),
                    const SizedBox(height: 6),
                    if (minBuild != null || (minVersion?.isNotEmpty ?? false))
                      Text(
                        comparisonMode == 'build'
                            ? 'Mínimo requerido: build ${minBuild ?? '-'}'
                            : 'Mínimo requerido: ${minVersion ?? '-'}'
                                '${minBuild != null ? ' · build $minBuild' : ''}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.55),
                            ),
                      ),
                    if (latestVersion != null || latestBuild != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Última publicada: ${latestVersion ?? '-'}'
                          '${latestBuild != null ? ' · build $latestBuild' : ''}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.45),
                              ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (canOpenStore)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onUpdatePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Actualizar ahora'),
                        ),
                      ),
                    if (canOpenStore) const SizedBox(height: 10),
                    if (onRetryPressed != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onRetryPressed,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Reintentar actualización'),
                        ),
                      ),
                    ],
                    if (storeUrl != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        storeUrl!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.45),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
