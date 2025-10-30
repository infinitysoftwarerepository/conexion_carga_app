import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';

class LoadCard extends StatelessWidget {
  final Trip trip;
  final bool isMine; // si es del usuario, mostramos el muñequito

  const LoadCard({
    super.key,
    required this.trip,
    this.isMine = false,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    try {
      return DateFormat('dd/MM HH:mm').format(dt);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          // Contenido
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Origen → Destino
              Text(
                '${trip.origin} → ${trip.destination}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),

              // Tipo de carga | vehículo
              Text(
                '${trip.cargoType} | ${trip.vehicle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 4),

              // Tonelaje y precio
              Text(
                '${trip.tons.toStringAsFixed(1)} Ton  •  \$${trip.price}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              // Salida
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Salida: ${_formatDate(trip.fechaSalida)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Muñequito si es mío (sin canequita roja)
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
                    )
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
