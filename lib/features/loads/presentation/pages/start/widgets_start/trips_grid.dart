import 'dart:math';

import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/widgets/load_card.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/trip_detail_page.dart';

/// ============================================================================
/// ✅ TripsGrid (OPTIMIZADO, pero sin cambiar comportamiento)
///
/// Qué hace:
/// - Pinta un GridView de viajes (cards).
/// - Respeta bottom gap para que el footer no tape la última fila.
/// - Al tocar una card, abre TripDetailPage.
/// - Si TripDetailPage devuelve `true`, se recarga.
///
/// Optimizaciones seguras:
/// - RepaintBoundary: evita repintar TODA la lista por cambios externos.
/// - KeyedSubtree: ayuda a Flutter a “reconocer” cada item y no reorganizar.
///   (No depende de que Trip tenga id)
///
/// Personalización:
/// - Cambia maxCrossAxisExtent / childAspectRatio para ajustar tamaño.
/// ============================================================================
class TripsGrid extends StatelessWidget {
  const TripsGrid({
    super.key,
    required this.trips,
    required this.myId,
    required this.onTripsChanged,
  });

  final List<Trip> trips;
  final String myId;

  /// Llamado cuando un detalle cambió datos y debemos recargar
  final Future<void> Function() onTripsChanged;

  // Gap base para el footer (igual al original)
  static const double _footerGap = 170;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final isLandscape = media.orientation == Orientation.landscape;

    // Gap dinámico: si pantalla es baja, reduce para no comerse todo el alto
    final double baseGap = isLandscape ? (_footerGap * 0.7) : _footerGap;
    final double maxGapByScreen = size.height * 0.40; // máx. 40% del alto
    final double bottomGap =
        min(baseGap, maxGapByScreen) + media.padding.bottom;

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomGap),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: trips.length,

      itemBuilder: (ctx, i) {
        final t = trips[i];
        final isMine = t.comercialId == myId;

        // Key “estable” sin depender de un id explícito
        // (Si algún día Trip tiene `id`, puedes cambiar a ValueKey(t.id))
        final itemKey = ValueKey(
          '${t.origin}-${t.destination}-${t.price}-${t.tons}-${t.comercialId}-$i',
        );

        return KeyedSubtree(
          key: itemKey,
          child: GestureDetector(
            onTap: () async {
              final changed = await Navigator.of(ctx).push<bool>(
                MaterialPageRoute(builder: (_) => TripDetailPage(trip: t)),
              );

              if (changed == true) {
                await onTripsChanged();
              }
            },

            // ✅ RepaintBoundary: mejora rendimiento en listas con muchas cards
            child: RepaintBoundary(
              child: LoadCard(trip: t, isMine: isMine),
            ),
          ),
        );
      },
    );
  }
}
