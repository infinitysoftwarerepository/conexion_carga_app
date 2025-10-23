// lib/features/loads/presentation/pages/my_loads_page.dart
import 'package:flutter/material.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';

// widgets
import 'package:conexion_carga_app/app/widgets/glyph_filter.dart';
import 'package:conexion_carga_app/app/widgets/glyph_search.dart';
import 'package:conexion_carga_app/app/widgets/load_card.dart';
import 'package:conexion_carga_app/app/widgets/new_action_fab.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

// pantalla del formulario
import 'package:conexion_carga_app/features/loads/presentation/pages/new_trip_page.dart';

// AppBar reutilizable
import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';

// Sesión (para leer el nombre del usuario)
import 'package:conexion_carga_app/core/auth_session.dart';

class LoadsPage extends StatefulWidget {
  const LoadsPage({super.key, required String userName});

  @override
  State<LoadsPage> createState() => _LoadsPageState();
}

class _LoadsPageState extends State<LoadsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late final AnimationController _anim;
  bool _searchOpen = false;

  List<Trip> _displayed = List.of(mockTrips);

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _searchCtrl.addListener(() => _applyFilter(_searchCtrl.text));
  }

  @override
  void dispose() {
    _anim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

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
    return Scaffold(
      appBar: CustomAppBar(
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
        titleSpacing: 0,
        height: 84, // 👈 más alto para que quepa el subtítulo en 2 líneas
        centerTitle: false,
        title: ValueListenableBuilder<AuthUser?>(
          valueListenable: AuthSession.instance.user,
          builder: (_, user, __) {
            final firstName = (user?.firstName ?? '').trim();
            final soloPrimerNombre =
                firstName.isEmpty ? '' : firstName.split(RegExp(r'\s+')).first;
            final subtitle = soloPrimerNombre.isEmpty
                ? 'Viajes personalizados'
                : 'Viajes personalizados de $soloPrimerNombre';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Bolsa de Carga',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,          // 👈 2 líneas
                  softWrap: true,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.12,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.85),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          GlyphSearch(
            tooltip: _searchOpen ? 'Cerrar búsqueda' : 'Buscar',
            onTap: _toggleSearch,
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
          ),
          const GlyphFilter(size: 20),
          ThemeToggle(
            color: Theme.of(context).colorScheme.onSurface,
            size: 22,
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: Stack(
        children: [
          // GRID DE CARDS
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), // 👈 un pelín más arriba
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemCount: _displayed.length,
            itemBuilder: (ctx, i) => LoadCard(trip: _displayed[i]),
          ),

          // BURBUJA DE BÚSQUEDA (animada)
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: IgnorePointer(
              ignoring: !_searchOpen,
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
                              horizontal: 12, vertical: 8),
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

      // FAB: abre el formulario de nuevo viaje
      floatingActionButton: NewActionFab(
        label: 'Nuevo viaje',
        icon: Icons.add,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewTripPage()),
          );
        },
      ),
    );
  }
}
