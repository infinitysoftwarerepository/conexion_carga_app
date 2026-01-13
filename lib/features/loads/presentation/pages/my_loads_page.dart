import 'dart:math';

import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/widgets/load_card.dart';
import 'package:conexion_carga_app/app/widgets/glyph_search.dart';
import 'package:conexion_carga_app/app/widgets/glyph_filter.dart';
import 'package:conexion_carga_app/features/loads/data/loads_api.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/trip_detail_page.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart'; // 👈 NUEVO
import 'package:conexion_carga_app/app/widgets/clean_filter.dart';  // 👈 NUEVO
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart'; // 👈 NUEVO


class MyLoadsPage extends StatefulWidget {
  const MyLoadsPage({super.key});

  @override
  State<MyLoadsPage> createState() => _MyLoadsPageState();
}

class _MyLoadsPageState extends State<MyLoadsPage> {
  // 🔢 Rangos globales de filtros
  static const double kMinTons = 0;
  static const double kMaxTons = 60;
  static const double kMinPrice = 0;
  static const double kMaxPrice = 100_000_000;

  late Future<List<Trip>> _future;

  // búsqueda + filtros
  String _searchQuery = '';
  _TripFilters _filters = _TripFilters();

  List<Trip> _lastItems = const <Trip>[];

  @override
  void initState() {
    super.initState();
    _future = LoadsApi.fetchMine(status: 'all');
  }

  Future<void> _refresh() async {
    setState(() {
      _future = LoadsApi.fetchMine(status: 'all');
    });
  }

    // ✅ NUEVO: saber si hay algo activo (búsqueda o filtros)
  bool get _hasActiveSearchOrFilters =>
      _searchQuery.trim().isNotEmpty || !_filters.isEmpty;

  // ✅ NUEVO: limpiar TODO (lupita + 3 rayitas)
  void _clearSearchAndFilters() {
    if (!_hasActiveSearchOrFilters) return;
    setState(() {
      _searchQuery = '';
      _filters = _TripFilters();
    });
  }

  // ✅ NUEVO: “botón” verde centrado SIN overflow
  Widget _greenCenterPill(String text) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? kGreenStrong : kDeepDarkGreen;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
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
                'Buscar en mis viajes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText:
                      'Escribe origen, destino, tipo de carga, vehículo, comercial...',
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
    if (_lastItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún no hay viajes para filtrar.')),
      );
      return;
    }

    final tonsValues = _lastItems
        .map((t) => t.tons)
        .where((v) => v != null)
        .cast<double>()
        .toList();
    final priceValues = _lastItems
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

            String fmtNum(num v) => v.round().toString();

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
                          fmtNum(tonsRange.start),
                          fmtNum(tonsRange.end),
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            local.minTons = values.start;
                            local.maxTons = values.end;
                          });
                        },
                      ),
                    ],

                    if (priceValues.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Valor del flete (COP)',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      RangeSlider(
                        values: priceRange,
                        min: priceMin,
                        max: max(priceMax, priceMin + 1),
                        divisions: 20,
                        labels: RangeLabels(
                          fmtNum(priceRange.start),
                          fmtNum(priceRange.end),
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

  // mismos criterios que en StartPage
  List<Trip> _applyFiltersTo(List<Trip> source) {
    final q = _searchQuery.trim().toLowerCase();

    bool containsIgnore(String? value, String pattern) {
      if (pattern.trim().isEmpty) return true;
      if (value == null || value.trim().isEmpty) return false;
      return value.toLowerCase().contains(pattern.toLowerCase());
    }

    return source.where((t) {
      if (!containsIgnore(t.origin, _filters.origin)) return false;
      if (!containsIgnore(t.destination, _filters.destination)) return false;
      if (!containsIgnore(t.cargoType, _filters.cargoType)) return false;
      if (!containsIgnore(t.vehicle, _filters.vehicle)) return false;
      if (!containsIgnore(t.estado, _filters.estado)) return false;
      if (!containsIgnore(t.comercial, _filters.comercial)) return false;
      if (!containsIgnore(t.contacto, _filters.contacto)) return false;

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
        ..write(t.tons?.toString() ?? '')
        ..write(' ')
        ..write(t.price?.toString() ?? '');

      final haystack = buffer.toString().toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  /// 👉 Regla única para saber si un trip está vencido:
  /// - si `activo == false` → vencido
  /// - o si tiene `remaining` y es <= 0 → vencido
  bool _isExpired(Trip t) {
    if (!t.activo) return true;
    final rem = t.remaining;
    if (rem == null) return false; // viajes antiguos sin duración
    return rem <= Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Mis viajes'),

      // ✅ Para controlar nosotros flecha + lupita a la izquierda
      automaticallyImplyLeading: false,

      // ✅ Más ancho porque ponemos 2 íconos (flecha + lupa)
      leadingWidth: 104,

      leading: Builder(
        builder: (context) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          final iconColor = isLight ? Colors.black87 : Colors.white;

          final canPop = Navigator.of(context).canPop();

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Flecha SOLO si esta pantalla fue abierta con Navigator.push
              if (canPop)
                IconButton(
                  tooltip: 'Volver',
                  icon: Icon(Icons.arrow_back, color: iconColor),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              else
                const SizedBox(width: 8),

              // ✅ Lupita al lado de la flecha (izquierda)
              GlyphSearch(
                onTap: _openSearchSheet,
                tooltip: 'Buscar',
                color: iconColor,
                padding: EdgeInsets.zero,
              ),
            ],
          );
        },
      ),

  // ✅ Derecha: filtros + lunita
  actions: [
    GlyphFilter(
      size: 20,
      onTap: _openFiltersSheet,
    ),
    const ThemeToggle(size: 22),
    const SizedBox(width: 8),
  ],
),

      body: FutureBuilder<List<Trip>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final items = snap.data ?? <Trip>[];
          _lastItems = items;

          if (items.isEmpty) {
  // ✅ NO hay viajes: solo el mensaje, sin CleanFilter
  return _greenCenterPill('No tienes viajes publicados.');
}

      final filtered = _applyFiltersTo(items);

      if (filtered.isEmpty) {
        // ✅ Sí hay viajes, pero NO hay coincidencias: mensaje + botón limpiar
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _greenCenterPill('No hay viajes que coincidan con la búsqueda o filtros.'),
              const SizedBox(height: 10),
              CleanFilter(
                enabled: true,
                showLabel: true,
                label: 'Limpiar',
                onTap: _clearSearchAndFilters,
              ),
            ],
          ),
        );
      }


          final myId = AuthSession.instance.user.value?.id ?? '';

          // 🔽 Activos primero, vencidos de últimos
          final sorted = List<Trip>.from(filtered)
            ..sort((a, b) {
              final ea = _isExpired(a);
              final eb = _isExpired(b);
              if (ea == eb) return 0;
              return ea ? 1 : -1; // true (vencido) va después
            });

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sorted.length,
              itemBuilder: (_, i) {
                final t = sorted[i];
                final isMine = (t.comercialId ?? '') == myId;
                final expired = _isExpired(t);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripDetailPage(trip: t),
                        ),
                      );
                      // refrescar al volver (por si se eliminó o editó)
                      await _refresh();
                    },
                    child: LoadCard(
                      trip: t,
                      isMine: isMine,
                      isExpired: expired, // 👈 aquí marcamos las vencidas
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ========= auxiliares (mismos que en StartPage, pero privados al archivo) ====

class _TripFilters {
  String origin;
  String destination;
  String cargoType;
  String vehicle;
  String estado;
  String comercial;
  String contacto;

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
        minTons: minTons,
        maxTons: maxTons,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

    bool get isEmpty =>
      origin.trim().isEmpty &&
      destination.trim().isEmpty &&
      cargoType.trim().isEmpty &&
      vehicle.trim().isEmpty &&
      estado.trim().isEmpty &&
      comercial.trim().isEmpty &&
      contacto.trim().isEmpty &&
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
