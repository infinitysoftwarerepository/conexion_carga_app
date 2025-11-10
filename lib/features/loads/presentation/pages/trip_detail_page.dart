import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/features/loads/data/loads_api.dart';

final _money = NumberFormat.simpleCurrency(locale: 'es_CO', name: 'COP');

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
        actions: const [ThemeToggle(size: 22), SizedBox(width: 8)],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: ${snap.error}'),
            ));
          }

          final raw = Map<String, dynamic>.from(snap.data ?? {});
          final trip = widget.trip;

          String s(String key, {String fallback = ''}) {
            final v = raw[key];
            return (v == null) ? fallback : v.toString().trim();
          }

          num? n(String key, {num? fallback}) {
            final v = raw[key];
            if (v is num) return v;
            if (v is String) {
              final parsed = num.tryParse(v.replaceAll('.', '').replaceAll(',', '.'));
              if (parsed != null) return parsed;
            }
            return fallback;
          }

          final origen       = s('origen',       fallback: trip.origin);
          final destino      = s('destino',      fallback: trip.destination);
          final pesoNum      = n('peso',         fallback: trip.tons);
          final tipoCarga    = s('tipo_carga',   fallback: trip.cargoType);
          final tipoVehiculo = s('tipo_vehiculo',fallback: trip.vehicle);
          final valorNum     = n('valor',        fallback: trip.price);
          final conductor    = s('conductor',    fallback: '');
          final observaciones= s('observaciones',fallback: '');
          final comercial    = s('comercial',    fallback: trip.comercial ?? '');
          final contacto     = s('contacto',     fallback: trip.contacto ?? '');

          final myUserId  = AuthSession.instance.user.value?.id ?? '';
          final creadorId = s('comercial_id', fallback: trip.comercialId ?? '');
          final isMine    = creadorId == myUserId;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$origen → $destino', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                _row('Peso',            (pesoNum != null) ? _fmtTons(pesoNum) : '-'),
                _row('Tipo de carga',    tipoCarga.isEmpty ? '-' : tipoCarga),
                _row('Tipo de vehículo', tipoVehiculo.isEmpty ? '-' : tipoVehiculo),
                _row('Tarifa',           (valorNum != null) ? _fmtMoney(valorNum) : '-'),
                _row('Conductor',        conductor.isEmpty ? '-' : conductor),
                _row('Observaciones',    observaciones.isEmpty ? '-' : observaciones),
                _row('Comercial',        comercial.isEmpty ? '-' : comercial),
                _row('Contacto',         contacto.isEmpty ? '-' : contacto),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Conexión Carga únicamente facilita la comunicación entre las partes y no asume '
                    'responsabilidad alguna por la negociación o cumplimiento de los acuerdos. '
                    'Reportes de irregularidades al correo electrónico: conexioncarga@gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.25),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const SizedBox.shrink();

          final raw = Map<String, dynamic>.from(snap.data ?? {});
          final trip = widget.trip;

          String s(String key, {String fallback = ''}) {
            final v = raw[key];
            return (v == null) ? fallback : v.toString().trim();
          }

          final myUserId  = AuthSession.instance.user.value?.id ?? '';
          final creadorId = s('comercial_id', fallback: trip.comercialId ?? '');
          final isMine    = creadorId == myUserId;

          final contacto  = s('contacto', fallback: trip.contacto ?? '');

          Widget wppIcon() => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Image.asset('assets/icons/whatsapp.png', height: 18, fit: BoxFit.contain),
              );

          void onContact() => _openWhatsApp(context, contacto);

          final btnStyle = FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            minimumSize: const Size(0, 44),
          );

          final labelContactar = const Text(
            'Contactar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14),
          );

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: isMine
                  ? Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: wppIcon(),
                            label: labelContactar,
                            onPressed: onContact,
                            style: btnStyle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.ios_share),
                            label: const Text('Exportar'),
                            onPressed: () => _exportTrip(context, raw, trip),
                            style: btnStyle,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: wppIcon(),
                            label: labelContactar,
                            onPressed: onContact,
                            style: btnStyle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.ios_share),
                            label: const Text('Exportar'),
                            onPressed: () => _exportTrip(context, raw, trip),
                            style: btnStyle,
                          ),
                        ),
                      ],
                    ),
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
            SizedBox(width: 160, child: Text('$label:', style: const TextStyle(color: Colors.black54))),
            Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );

  String _fmtTons(num v) {
    final d = v.toDouble();
    if (d == d.truncateToDouble()) return '${d.toStringAsFixed(0)} T';
    return '${d.toStringAsFixed(1)} T';
  }

  String _fmtMoney(num v) => NumberFormat.simpleCurrency(locale: 'es_CO', name: 'COP')
      .format(v)
      .replaceAll(',00', '');

  Future<void> _openWhatsApp(BuildContext context, String phoneRaw) async {
    final digits = phoneRaw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este viaje no tiene un contacto válido.')),
      );
      return;
    }
    final normalized = digits.startsWith('+') ? digits : '+57$digits';
    final uri = Uri.parse('https://wa.me/${normalized.replaceAll('+', '')}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible abrir WhatsApp.')),
      );
    }
  }

  Future<void> _exportTrip(BuildContext context, Map<String, dynamic> raw, Trip trip) async {
    String s(String key, {String fallback = ''}) {
      final v = raw[key];
      return (v == null) ? fallback : v.toString().trim();
    }
    num? n(String key, {num? fallback}) {
      final v = raw[key];
      if (v is num) return v;
      if (v is String) {
        final parsed = num.tryParse(v.replaceAll('.', '').replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    final origen       = s('origen',       fallback: trip.origin);
    final destino      = s('destino',      fallback: trip.destination);
    final pesoNum      = n('peso',         fallback: trip.tons);
    final tipoCarga    = s('tipo_carga',   fallback: trip.cargoType);
    final tipoVehiculo = s('tipo_vehiculo',fallback: trip.vehicle);
    final valorNum     = n('valor',        fallback: trip.price);
    final conductor    = s('conductor',    fallback: '');
    final observaciones= s('observaciones',fallback: '');
    final comercial    = s('comercial',    fallback: trip.comercial ?? '');
    final contacto     = s('contacto',     fallback: trip.contacto ?? '');

    final buffer = StringBuffer()
      ..writeln('📦 Detalle del viaje')
      ..writeln('Ruta: $origen → $destino')
      ..writeln('Peso: ${pesoNum != null ? _fmtTons(pesoNum) : '-'}')
      ..writeln('Tipo de carga: ${tipoCarga.isEmpty ? '-' : tipoCarga}')
      ..writeln('Tipo de vehículo: ${tipoVehiculo.isEmpty ? '-' : tipoVehiculo}')
      ..writeln('Tarifa: ${valorNum != null ? _fmtMoney(valorNum) : '-'}')
      ..writeln('Conductor: ${conductor.isEmpty ? '-' : conductor}')
      ..writeln('Observaciones: ${observaciones.isEmpty ? '-' : observaciones}')
      ..writeln('Comercial: ${comercial.isEmpty ? '-' : comercial}')
      ..writeln('Contacto: ${contacto.isEmpty ? '-' : contacto}');

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Información copiada. ¡Lista para exportar!')),
    );
  }
}
