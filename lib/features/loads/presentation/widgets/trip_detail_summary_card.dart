import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/app/widgets/time_bubbles.dart';
import 'package:conexion_carga_app/features/loads/presentation/models/trip_share_payload.dart';

class TripDetailSummaryCard extends StatelessWidget {
  final TripSharePayload data;
  final bool isExpired;
  final Duration? remaining;
  final Color bubbleBg;

  const TripDetailSummaryCard({
    super.key,
    required this.data,
    required this.isExpired,
    required this.remaining,
    required this.bubbleBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF7FBF3),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE6EFE1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: kDeepDarkGreen,
                fontSize: 14,
                height: 1.2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD9E8D1)),
                        ),
                        child: Image.asset(
                          'assets/icons/app_icon_V4.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conexión Carga',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: kDeepDarkGreen,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Detalle del viaje',
                              style: TextStyle(
                                fontSize: 12,
                                color: kGreyText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isExpired ? Colors.red.shade400 : kBrandOrange,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isExpired ? 'Vencido' : 'Disponible',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Ruta',
                    style: TextStyle(
                      color: kGreyText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${data.origin} → ${data.destination}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kDeepDarkGreen,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: kBrandOrange,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isExpired && remaining != null) ...[
                    TimeBubbleRowBig(remaining: remaining!),
                  ] else ...[
                    Text(
                      'Este viaje ya está vencido.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      TripInfoPill(
                        icon: Icons.scale_outlined,
                        label: 'Peso',
                        value: data.weight,
                      ),
                      TripInfoPill(
                        icon: Icons.inventory_2_outlined,
                        label: 'Carga',
                        value: data.cargoType,
                      ),
                      TripInfoPill(
                        icon: Icons.local_shipping_outlined,
                        label: 'Vehículo',
                        value: data.vehicleType,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD9B0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valor del viaje',
                          style: TextStyle(
                            color: kGreyText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.price,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: kDarkOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TripSectionTitle(title: 'Información principal'),
                  const SizedBox(height: 10),
                  TripSectionCard(
                    child: Column(
                      children: [
                        TripCardInfoRow(
                          label: 'Empresa',
                          value: data.company,
                        ),
                        TripCardInfoRow(
                          label: 'Comercial',
                          value: data.commercial,
                        ),
                        TripCardInfoRow(
                          label: 'Contacto',
                          value: data.contact,
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const TripSectionTitle(title: 'Observaciones'),
                  const SizedBox(height: 10),
                  TripSectionCard(
                    child: Text(
                      data.observations,
                      style: const TextStyle(
                        color: kDeepDarkGreen,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: bubbleBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Conexión Carga únicamente facilita la comunicación entre las partes y no asume responsabilidad alguna por la negociación o cumplimiento de los acuerdos. Reportes de irregularidades al WhatsApp: +57 3019043971',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.25,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class TripSectionTitle extends StatelessWidget {
  final String title;

  const TripSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: kGreyText,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class TripSectionCard extends StatelessWidget {
  final Widget child;

  const TripSectionCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EFE1)),
      ),
      child: child,
    );
  }
}

class TripCardInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const TripCardInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: kGreyText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: highlight ? kDarkGreen : kDeepDarkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TripInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const TripInfoPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 105),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E8D1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: kDarkGreen),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kGreyText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kDeepDarkGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}