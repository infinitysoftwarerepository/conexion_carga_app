import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/app/widgets/time_bubbles.dart';

class LoadCard extends StatelessWidget {
  final Trip trip;
  final bool isMine;
  

  /// 👇 Nuevo flag: solo lo usamos desde MyLoadsPage
  /// para dibujar la tarjeta “apagada / vencida”.
  final bool isExpired;

  

  const LoadCard({
    super.key,
    required this.trip,
    this.isMine = false,
    this.isExpired = false, // por defecto NO vencida (StartPage no se toca)
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
    // ---------------------------------------------------------------------------
    // 🎨 Colores “meta” (los textos chicos: carga, vehículo, empresa)
    // IMPORTANTE: NO usar Colors.blackXX aquí, porque en tema oscuro se ven mal.
    // Cambia estos 2 valores y personalizas TODO el look de esa info.
    // ---------------------------------------------------------------------------
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Íconos pequeños a la izquierda (carga/vehículo/empresa)
    final Color metaIconColor =
        isLight ? Colors.black54 : cs.onSurface.withOpacity(0.70);

    // Texto pequeño (carga/vehículo/empresa)
    final Color metaTextColor =
        isLight ? Colors.black87 : cs.onSurface; // blanco/gris claro en dark

    // Estilo único para esos textos (fácil de tunear)
    final TextStyle metaTextStyle = TextStyle(
      fontSize: 10,
      color: metaTextColor,
      // Si un día quieres “más grueso” en oscuro:
      // fontWeight: FontWeight.w500,
    );

    final remaining = trip.remaining;
    final empresa = trip.empresa ?? '';
     

    // 🎨 Si está vencida: la tarjeta se ve más “apagada”
    final Color cardColor = isExpired
        ? cs.surface.withOpacity(0.60)
        : cs.surface;

    // Etiqueta rápida “Vencido”
    Widget? expiredBadge;
    if (isExpired) {
      expiredBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.error.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.error.withOpacity(0.4)),
        ),
        child: Text(
          'Viaje vencido',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.error,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Origen → Destino + badge de vencido
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${trip.origin} → ${trip.destination}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                                          
                                      ),
                    ),
                  ),
                  if (expiredBadge != null) ...[
                    const SizedBox(width: 6),
                    expiredBadge,
                  ],
                ],
              ),
              const SizedBox(height: 3),

              // Tipo de carga
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                  Icons.inventory_2_outlined,
                  size: 14,
                  color: metaIconColor, // ✅ se adapta al tema
                ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.cargoType,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: metaTextStyle, // ✅ se adapta al tema
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),

              // Tipo de vehículo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Icon(
                    Icons.local_shipping_outlined,
                    size: 14,
                    color: metaIconColor, // ✅ se adapta al tema
                  ),
                  
                  
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.vehicle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: metaTextStyle, // ✅ se adapta al tema
                      
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),

              // Tonelaje
              Row(
                children: [
                  Icon(
                    Icons.scale_outlined,
                    size: 14,
                    color: metaIconColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTons(trip.tons),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  metaTextStyle,
                  ),
                ],
              ),
              const SizedBox(height: 3),

              // Precio
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: metaIconColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatMoney(trip.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: metaTextStyle
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              // Empresa
              if (empresa.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 14,
                      color: metaIconColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        empresa,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: metaTextStyle
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 5),
              // Píldora “Toque aquí…”
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
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
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Más info aquí !',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
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

              const SizedBox(height: 3),

              // Burbujas de tiempo: solo si NO está marcada como vencida
              if (!isExpired &&
                  remaining != null &&
                  remaining > Duration.zero) ...[
                const SizedBox(height: 4),
                TimeBubbleRowSmall(remaining: remaining,),
              ],
            ],
          ),

          // Indicador de que el viaje es mío
          if (isMine)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: kGreenStrong,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
