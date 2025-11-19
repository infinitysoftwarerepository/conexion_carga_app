// lib/app/widgets/load_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/app/widgets/time_bubbles.dart';

class LoadCard extends StatelessWidget {
  final Trip trip;
  final bool isMine;

  const LoadCard({
    super.key,
    required this.trip,
    this.isMine = false,
  });

  String _formatTons(num? t) {
    try {
      final d = (t ?? 0).toDouble();
      return '${d.toStringAsFixed(d.truncateToDouble() == d ? 0 : 1)} Ton';
    } catch (_) {
      return '- Ton';
    }
  }

  String _formatMoney(num? value) {
    final v = value ?? 0;
    final f = NumberFormat.simpleCurrency(locale: 'es_CO', name: 'COP');
    return f.format(v).replaceAll(',00', '');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final remaining = trip.remaining;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Origen → Destino
              Text(
                '${trip.origin} → ${trip.destination}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),

              // Tipo de carga
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.cargoType,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Tipo de vehículo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.vehicle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Tonelaje
              Row(
                children: [
                  const Icon(Icons.scale_outlined,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    _formatTons(trip.tons),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Precio
              Row(
                children: [
                  const Icon(Icons.attach_money,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatMoney(trip.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Píldora “Toque aquí…”
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 16,
                            color: cs.primary.withOpacity(0.85),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Más info aquí !',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.primary.withOpacity(0.90),
                                letterSpacing: .1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Burbujas de tiempo (abajo, sin overflow)
              if (remaining != null && remaining > Duration.zero) ...[
                const SizedBox(height: 4),
                TimeBubbleRowSmall(remaining: remaining),
              ],
            ],
          ),

          if (isMine)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
