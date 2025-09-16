import 'package:flutter/material.dart';
import 'package:bolsa_carga_app/features/loads/domain/trip.dart';

// Widgets reutilizables
import 'package:bolsa_carga_app/presentation/widgets/glyph_filter.dart';
import 'package:bolsa_carga_app/presentation/widgets/glyph_search.dart';
import 'package:bolsa_carga_app/presentation/widgets/theme_toggle.dart';
import 'package:bolsa_carga_app/presentation/widgets/load_card.dart';
import 'package:bolsa_carga_app/presentation/widgets/new_action_fab.dart';

// Pantalla del formulario de “Nuevo viaje”
import 'package:bolsa_carga_app/presentation/screens/new_trip_screen.dart';

/// 📄 Listado de viajes (Bolsa de Carga)
/// - AppBar con título + iconitos compactos a la derecha (lupa, filtros, luna)
/// - Búsqueda con “burbujita” animada
/// - Grid de LoadCard (los textos se ven negros incluso en modo oscuro)
/// - FAB para registrar un nuevo viaje
class LoadsPage extends StatefulWidget {
  const LoadsPage({super.key});

  @override
  State<LoadsPage> createState() => _LoadsPageState();
}

class _LoadsPageState extends State<LoadsPage>
    with SingleTickerProviderStateMixin {
  // --- Estado búsqueda ---
  final TextEditingController _searchCtrl = TextEditingController();
  late final AnimationController _anim;
  bool _searchOpen = false;

  // --- Lista mostrada (se filtra sobre mockTrips) ---
  List<Trip> _displayed = List.of(mockTrips);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _searchCtrl.addListener(() => _applyFilter(_searchCtrl.text));
  }

  @override
  void dispose() {
    _anim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Abre/cierra la burbuja de búsqueda
  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _anim.forward();
    } else {
      _anim.reverse();
      _searchCtrl.clear();
      _displayed = List.of(mockTrips);
    }
  }

  // Filtrado en tiempo real por varios campos
  void _applyFilter(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _displayed = List.of(mockTrips));
      return;
    }
    setState(() {
      _displayed = mockTrips.where((t) {
        final campos = <String>[
          t.origin,
          t.destination,
          t.cargoType,
          t.vehicle,
          t.notes,
          t.price.toString(),
          t.tons.toString(),
        ].map((e) => e.toLowerCase());
        return campos.any((s) => s.contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gris para los iconos del AppBar (respeta el tema)
    final actionColor =
        Theme.of(context).appBarTheme.foregroundColor ??
            Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      // ========== APP BAR ==========
      appBar: AppBar(
        titleSpacing: 0, // da aire al título y evita que se corte
        title: const Text('Bolsa de Carga'),
        centerTitle: false,

        // Iconitos compactos agrupados a la derecha
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min, // ocupa solo lo necesario
            children: [
              // 🔎 Lupita (compacta)
              GlyphSearch(
                tooltip: _searchOpen ? 'Cerrar búsqueda' : 'Buscar',
                onTap: _toggleSearch,
                size: 20,
                color: actionColor,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              ),
              const SizedBox(width: 2),

              // ☰ Filtros (compactos)
              GlyphFilter(
                size: 20,
                color: actionColor,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              ),
              const SizedBox(width: 2),

              // 🌙 Toggle claro/oscuro (compacto)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                child: ThemeToggle(
                  color: actionColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4), // pequeño margen al borde derecho
        ],
      ),

      // ========== CUERPO ==========
      body: Stack(
        children: [
          // --- GRID DE CARDS ---
          GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemCount: _displayed.length,
            itemBuilder: (ctx, i) => LoadCard(trip: _displayed[i]),
          ),

          // --- BURBUJA DE BÚSQUEDA (animada) ---
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: IgnorePointer(
              ignoring: !_searchOpen, // no captura toques si está cerrada
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  final scale =
                      Tween<double>(begin: 0.95, end: 1.0).evaluate(_anim);
                  final opacity =
                      Tween<double>(begin: 0.0, end: 1.0).evaluate(_anim);
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Color(0xFF757575)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Buscar origen, destino, placa/vehículo, etc.',
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (_searchCtrl.text.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _applyFilter('');
                                  },
                                  icon: const Icon(Icons.close,
                                      size: 20, color: Color(0xFF757575)),
                                  splashRadius: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // ========== FAB “NUEVO VIAJE” ==========
      floatingActionButton: NewActionFab(
        label: 'Nuevo viaje',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewTripPage()),
          );
        },
      ),
    );
  }
}
