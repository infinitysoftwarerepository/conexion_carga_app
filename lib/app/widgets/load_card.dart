import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/trip_detail_page.dart';
import 'package:conexion_carga_app/app/widgets/countdown_bar.dart';

/// Formato de moneda COP sin decimales
final _money = NumberFormat.currency(
  locale: 'es_CO',
  symbol: r'$',
  decimalDigits: 0,
);

/// Tarjeta de viaje (LoadCard)
class LoadCard extends StatelessWidget {
  final Trip trip;
  const LoadCard({super.key, required this.trip});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: isLight ? Colors.white : kDeepDarkGray,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isLight ? Colors.white : kDeepDarkGray),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Bloque superior ─────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABECERA: barrita + botón hamburguesa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CountdownBar(
                          dots: 3,
                          height: 28,
                          dotSize: 16,
                          spacing: 6,
                          barColor:  Theme.of(context).brightness == Brightness.light
                            ? kBrandOrange
                            : kDeepDarkOrange,
                          dotColor:  Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                          align: MainAxisAlignment.start,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _openDetail(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color:  Theme.of(context).brightness == Brightness.light
                                    ? kGreenStrong
                                    : kDeepDarkGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 3,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child:  Icon(Icons.menu, size: 16, color: 
                          
                           Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : kGreyText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Tonelaje (negro/blanco según tema)
                  Text(
                    '${trip.tons.toStringAsFixed(1)} T',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isLight ? Colors.black : kGreyText,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Origen / Destino (negro/blanco según tema)
                  _smallLabel(context, 'Origen: ${trip.origin}'),
                  _smallLabel(context, 'Destino: ${trip.destination}'),

                  const SizedBox(height: 4),

                  // Info adicional
                  _smallMuted(context, '${trip.cargoType} • ${trip.vehicle}'),
                ],
              ),

              // ── Bloque inferior: precio (negro/blanco según tema) ──────────
              Text(
                _money.format(trip.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isLight ? Colors.black : kGreyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Etiquetas (origen/destino): negro en claro, blanco en oscuro
  Widget _smallLabel(BuildContext context, String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : kGreyText,
        ),
      );

  // “Muted”: si lo quieres también negro/blanco según tema, queda así.
  // (Si prefieres gris fijo, cambia el color a const Color(0xFF6B7280).)
  Widget _smallMuted(BuildContext context, String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
      );
}
