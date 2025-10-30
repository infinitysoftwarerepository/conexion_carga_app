// lib/features/loads/presentation/pages/trip_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';

// Toggle de tema
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
// AppBar reutilizable
import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';

import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/features/loads/data/loads_api.dart';

final _money = NumberFormat.currency(locale: 'es_CO', symbol: r'$');

class TripDetailPage extends StatelessWidget {
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final myId = AuthSession.instance.user.value?.id ?? '';
    final isMine = trip.comercialId == myId;
    final isExpired = trip.estado.toLowerCase() != 'publicado' || !trip.activo;

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
            if (trip.notes != null && trip.notes!.isNotEmpty)
              _row('Notas', trip.notes!),
            const Spacer(),

            // Acciones según dueño/estado
            if (!isMine && !isExpired)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  // ⛏️ FIX: Material no tiene Icons.whatsapp
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Contactar!'),
                  onPressed: () {
                    // TODO: abrir WhatsApp si tienes el teléfono en trip.contacto
                    // Ej: usando url_launcher con "https://wa.me/<numero>"
                  },
                ),
              )
            else if (isMine && !isExpired) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Eliminar'),
                      onPressed: () async {
                        await LoadsApi.expire(trip.id);
                        if (!context.mounted) return;
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Viaje eliminado.')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                      onPressed: () {
                        // TODO: abre NewTripPage precargando datos si lo deseas.
                      },
                    ),
                  ),
                ],
              ),
            ] else if (isMine && isExpired)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.replay_outlined),
                  label: const Text('Reutilizar'),
                  onPressed: () {
                    // TODO: abre NewTripPage con datos precargados para solo ajustar fechas.
                  },
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
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}
