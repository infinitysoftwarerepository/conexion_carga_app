import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bolsa_carga_app/features/loads/domain/trip.dart';
import 'package:bolsa_carga_app/presentation/screens/trip_detail_screen.dart';
import 'package:bolsa_carga_app/presentation/widgets/countdown_bar.dart';

/// Formato de moneda COP sin decimales
final _money = NumberFormat.currency(
  locale: 'es_CO',
  symbol: r'$',
  decimalDigits: 0,
);

/// Tarjeta de viaje (LoadCard)
/// - **Diseño igual** al que te gustaba:
///   • Encabezado naranja con 3 puntos blancos
///   • Botón verde (hamburguesa) arriba derecha
///   • Tarjeta **blanca** SIEMPRE (claro y oscuro)
/// - **Texto siempre negro** (no se apaga en dark mode)
/// - Sin overflow: el contenido no se sale de la tarjeta
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
    // ⚠️ Forzamos blanco para mantener la tarjeta igual en ambos temas
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE7E7E7)),
          ),
          padding: const EdgeInsets.all(10),
          // ✅ Distribuimos contenido para evitar “BOTTOM OVERFLOWED…”
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
                      const Expanded(
                        child: CountdownBar(
                          dots: 3,
                          height: 28,
                          dotSize: 16,
                          spacing: 6,
                          barColor: Color(0xFFFFA000), // naranja
                          dotColor: Colors.white,
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
                            color: const Color(0xFF28A745), // verde
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 3,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.menu, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // un pelín más compacto que antes

                  // Tonelaje
                  Text(
                    '${trip.tons.toStringAsFixed(1)} T',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black, // ← SIEMPRE negro
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Origen / Destino
                  _smallLabel('Origen: ${trip.origin}'),
                  _smallLabel('Destino: ${trip.destination}'),

                  const SizedBox(height: 4),

                  // Info adicional (gris pero bien visible)
                  _smallMuted('${trip.cargoType} • ${trip.vehicle}'),
                ],
              ),

              // ── Bloque inferior: precio ─────────────────────────────────────
              Text(
                _money.format(trip.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black, // ← SIEMPRE negro
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Texto “etiqueta” (origen/destino) SIEMPRE negro
  Widget _smallLabel(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black, // ← SIEMPRE negro
        ),
      );

  // Texto “muted” (carga / vehículo) gris estable (visible en ambos temas)
  Widget _smallMuted(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280), // gris firme (no se apaga en dark)
        ),
      );
}
