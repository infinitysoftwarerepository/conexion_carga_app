import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';

// Toggle de tema
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

// NUEVO: AppBar reutilizable
import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';

final _money = NumberFormat.currency(locale: 'es_CO', symbol: r'$');

class TripDetailPage extends StatelessWidget {
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleSpacing: 0,
        height: 56,
        centerTitle: true,
        title: const Text('Detalle del viaje'),
        actions: [
          ThemeToggle(
            color: Theme.of(context).colorScheme.onSurface,
            size: 22,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${trip.origin} → ${trip.destination}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _row('Tonelaje', '${trip.tons.toStringAsFixed(1)} T'),
            _row('Tipo de carga', trip.cargoType),
            _row('Vehículo', trip.vehicle),
            _row('Tarifa', _money.format(trip.price)),
            if (trip.notes.isNotEmpty) _row('Notas', trip.notes),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Postularme'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(width: 130, child: Text('$label:')),
            Expanded(
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
