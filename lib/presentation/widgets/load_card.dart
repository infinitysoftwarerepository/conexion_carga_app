import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bolsa_carga_app/features/loads/domain/trip.dart';
import 'package:bolsa_carga_app/presentation/screens/trip_detail_screen.dart';
import 'package:bolsa_carga_app/presentation/widgets/countdown_bar.dart';

final _money = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);

class LoadCard extends StatelessWidget {
  final Trip trip;
  const LoadCard({super.key, required this.trip});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TripDetailPage(trip: trip),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
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
                      barColor: Color(0xFFFFA000),
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
                        color: const Color(0xFF28A745),
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
              const SizedBox(height: 8),

              Text('${trip.tons.toStringAsFixed(1)} T',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              _smallLabel('Origen: ${trip.origin}'),
              _smallLabel('Destino: ${trip.destination}'),
              const SizedBox(height: 6),
              _smallMuted('${trip.cargoType} • ${trip.vehicle}'),
              const Spacer(),
              Text(_money.format(trip.price),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallLabel(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      );
  Widget _smallMuted(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
}
