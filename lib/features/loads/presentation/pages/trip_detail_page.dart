// lib/features/loads/presentation/pages/trip_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/features/loads/data/loads_api.dart';

final _money = NumberFormat.currency(locale: 'es_CO', symbol: r'$');

class TripDetailPage extends StatefulWidget {
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    // 👇 Traemos SIEMPRE el detalle crudo desde el backend
    _future = LoadsApi.fetchTripDetailRaw(widget.trip.id);
  }

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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snap.error}'),
              ),
            );
          }

          // Mezclamos la info del Trip (por si viene algún null en el JSON)
          final raw = Map<String, dynamic>.from(snap.data ?? {});
          final trip = widget.trip;

          // Helpers para obtener campos desde múltiples claves posibles
          String _pickStr(List<String> keys, {String? fallback}) {
            for (final k in keys) {
              final v = raw[k];
              if (v != null && v.toString().trim().isNotEmpty) {
                return v.toString();
              }
            }
            return fallback ?? '';
          }

          num? _pickNum(List<String> keys, {num? fallback}) {
            for (final k in keys) {
              final v = raw[k];
              if (v is num) return v;
              if (v is String) {
                final parsed = num.tryParse(v.replaceAll('.', '').replaceAll(',', '.'));
                if (parsed != null) return parsed;
              }
            }
            return fallback;
          }

          // Campos principales (con fallback a Trip)
          final origen       = _pickStr(['origen','origin'],       fallback: trip.origin);
          final destino      = _pickStr(['destino','destination'], fallback: trip.destination);
          final tipoCarga    = _pickStr(['tipo_carga','cargoType'], fallback: trip.cargoType);
          final tonsNum      = _pickNum(['peso','tons'],            fallback: trip.tons);
          final precioNum    = _pickNum(['valor','price'],          fallback: trip.price);
          final tipoVehiculo = _pickStr(['tipo_vehiculo','vehicle'], fallback: trip.vehicle);
          final vehiculo     = _pickStr(['vehiculo','placa','vehicle_id']);
          final comercial = _pickStr(
            ['comercial', 'commercial', 'comercial_nombre', 'commercial_name'],
            // No hay campo de texto en Trip; si el backend no lo manda, mostramos vacío
            fallback: '',
          );
          final contacto     = _pickStr(['contacto','telefono','phone','cel'], fallback: '');
          final conductor    = _pickStr(['conductor','driver'], fallback: '');
          final notas        = _pickStr(['observaciones','notes','descripcion']);

          final myId    = AuthSession.instance.user.value?.id ?? '';
          final isMine  = (trip.comercialId == myId) || _pickStr(['comercial_id','created_by'], fallback: '') == myId;
          final estado  = _pickStr(['estado','status'], fallback: trip.estado);
          final activo  = _pickStr(['activo'], fallback: trip.activo ? 'true' : 'false').toString().toLowerCase() == 'true';
          final isExpired = estado.toLowerCase() != 'publicado' || !activo;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título origen → destino
                Text(
                  '$origen → $destino',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // 🔎 Mostramos TODOS los campos del formulario (menos premium/duración)
                _row('Tonelaje', tonsNum != null ? '${tonsNum.toStringAsFixed(1)} T' : '-'),
                _row('Tipo de carga', tipoCarga),
                _row('Tipo de vehículo', tipoVehiculo),
                if (vehiculo.isNotEmpty) _row('Vehículo', vehiculo),
                _row('Tarifa', precioNum != null ? _money.format(precioNum) : '-'),
                if (comercial.isNotEmpty) _row('Comercial', comercial),
                if (contacto.isNotEmpty) _row('Contacto (tel.)', contacto),
                if (conductor.isNotEmpty) _row('Conductor', conductor),
                if (notas.isNotEmpty) _row('Observaciones', notas),

                const Spacer(),

                // Acciones según dueño/estado
                if (!isMine && !isExpired)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('¡Contactar!'),
                      onPressed: () {
                        // TODO: Usa url_launcher con "https://wa.me/<numero>"
                        // si tienes numero en `contacto`.
                        // Ej: launchUrl(Uri.parse('https://wa.me/$numero'));
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
                            if (!mounted) return;
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
                            // TODO: abrir NewTripPage precargando datos si lo deseas.
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
                        // TODO: abrir NewTripPage con datos precargados.
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                '$label:',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}
