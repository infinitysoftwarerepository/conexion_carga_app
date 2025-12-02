import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/features/loads/data/loads_api.dart';
import 'package:conexion_carga_app/app/widgets/time_bubbles.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/new_trip_page.dart'; // 👈 nuevo

/// Formateador de dinero en COP
final _money = NumberFormat.simpleCurrency(locale: 'es_CO', name: 'COP');

class TripDetailPage extends StatefulWidget {
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  /// Detalle crudo desde el backend (para exportar / campos extra)
  late Future<Map<String, dynamic>> _future;

  /// Tiempo restante que vamos actualizando cada segundo
  Duration? _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _future = LoadsApi.fetchTripDetailRaw(widget.trip.id);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Recalcula el tiempo restante a partir del Trip
  void _updateRemaining() {
    final rem = widget.trip.remaining;
    if (!mounted) return;
    setState(() {
      _remaining = rem;
    });
  }

  /// Arranca el timer de 1 seg para ir actualizando la cuenta regresiva
  void _startTimer() {
    _timer?.cancel();

    if (widget.trip.expiresAt == null) {
      _remaining = null;
      return;
    }

    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snap.error}'),
              ),
            );
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
              final parsed = num.tryParse(
                v.replaceAll('.', '').replaceAll(',', '.'),
              );
              if (parsed != null) return parsed;
            }
            return fallback;
          }

          // ------------ Valores de detalle (con fallback al Trip) ------------
          final origen = s('origen', fallback: trip.origin);
          final destino = s('destino', fallback: trip.destination);
          final pesoNum = n('peso', fallback: trip.tons);
          final tipoCarga = s('tipo_carga', fallback: trip.cargoType);
          final tipoVehiculo = s('tipo_vehiculo', fallback: trip.vehicle);
          final valorNum = n('valor', fallback: trip.price);
          final empresa = s('empresa', fallback: trip.empresa ?? '');
          final conductor = s('conductor', fallback: '');
          final observaciones = s('observaciones', fallback: '');
          final comercial = s('comercial', fallback: trip.comercial ?? '');
          final contacto = s('contacto', fallback: trip.contacto ?? '');

          // ------------ ¿El viaje es mío? (para botones de abajo) ------------
          final myUserId = AuthSession.instance.user.value?.id ?? '';
          final creadorId = s('comercial_id', fallback: trip.comercialId ?? '');
          final isMine = creadorId == myUserId;

          // ------------ Lógica de vencimiento / eliminado ------------
          final Duration? rem = _remaining ?? trip.remaining;

          bool _fromRawActivo() {
            final v = raw['activo'];
            if (v == null) return trip.activo;
            if (v is bool) return v;
            return v.toString().toLowerCase() == 'true';
          }

          final bool isActiveBackend = _fromRawActivo();
          final bool isExpired =
              !isActiveBackend || rem == null || rem <= Duration.zero;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------- Título Origen → Destino ----------
                Text(
                  '$origen → $destino',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 10),

                // --------- Burbujas de tiempo o aviso vencido ----------
                if (!isExpired && rem != null) ...[
                  TimeBubbleRowBig(
                    remaining: rem,
                  ),
                ] else ...[
                  Text(
                    'Este viaje ya está vencido.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                const SizedBox(height: 12),

                // --------- Detalle de campos ----------
                _row(
                    'Peso', (pesoNum != null) ? _fmtTons(pesoNum) : '-'),
                _row('Tipo de carga', tipoCarga.isEmpty ? '-' : tipoCarga),
                _row('Tipo de vehículo',
                    tipoVehiculo.isEmpty ? '-' : tipoVehiculo),
                _row('Valor',
                    (valorNum != null) ? _fmtMoney(valorNum) : '-'),
                _row('Empresa', empresa.isEmpty ? '-' : empresa),

                _row('Observaciones',
                    observaciones.isEmpty ? '-' : observaciones),
                _row('Comercial', comercial.isEmpty ? '-' : comercial),
                _row('Contacto', contacto.isEmpty ? '-' : contacto),

                const SizedBox(height: 20),

                // --------- Aviso legal ----------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Conexión Carga únicamente facilita la comunicación entre las partes y no asume '
                    'responsabilidad alguna por la negociación o cumplimiento de los acuerdos. '
                    'Reportes de irregularidades al WhatsApp: +57 301 9043971',
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

      // --------------------------------------------------------------------
      // BARRA INFERIOR: Contactar / Exportar / Eliminar o Reutilizar
      // --------------------------------------------------------------------
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          final raw = Map<String, dynamic>.from(snap.data ?? {});
          final trip = widget.trip;

          String s(String key, {String fallback = ''}) {
            final v = raw[key];
            return (v == null) ? fallback : v.toString().trim();
          }

          final myUserId = AuthSession.instance.user.value?.id ?? '';
          final creadorId = s('comercial_id', fallback: trip.comercialId ?? '');
          final isMine = creadorId == myUserId;
          final contacto = s('contacto', fallback: trip.contacto ?? '');

          // 🔁 Reusamos la lógica de vencido también aquí
          final Duration? rem = _remaining ?? trip.remaining;
          bool _fromRawActivo() {
            final v = raw['activo'];
            if (v == null) return trip.activo;
            if (v is bool) return v;
            return v.toString().toLowerCase() == 'true';
          }

          final bool isActiveBackend = _fromRawActivo();
          final bool isExpired =
              !isActiveBackend || rem == null || rem <= Duration.zero;

          Widget wppIcon() => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Image.asset(
                  'assets/icons/whatsapp.png',
                  height: 18,
                  fit: BoxFit.contain,
                ),
              );

          void onContact() => _openWhatsApp(context, contacto);

          // 🔧 Estilos compactos para evitar overflows y 2 líneas
          final btnStyle = FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );

          final outlinedBtnStyle = OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );

          final labelContactar = _oneLineLabel('Contactar');
          final labelExportar = _oneLineLabel('Exportar');
          final labelReutilizar = _oneLineLabel('Reutilizar');
          final labelEliminar = _oneLineLabel('Eliminar');

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
                            label: labelExportar,
                            onPressed: () => _exportTrip(context, raw, trip),
                            style: btnStyle,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 👉 Si el viaje está vencido: botón "Reutilizar"
                        //    Si sigue activo: botón "Eliminar" como antes
                        Expanded(
                          child: isExpired
                              ? OutlinedButton.icon(
                                  icon: const Icon(Icons.recycling),
                                  label: labelReutilizar,
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            NewTripPage(initialTrip: trip),
                                      ),
                                    );
                                  },
                                  style: outlinedBtnStyle,
                                )
                              : OutlinedButton.icon(
                                  icon: const Icon(
                                      Icons.delete_forever_outlined),
                                  label: labelEliminar,
                                  onPressed: () async {
                                    try {
                                      await LoadsApi.expire(trip.id);
                                      if (!mounted) return;
                                      Navigator.pop(context, true);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Viaje eliminado.'),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error al eliminar: $e'),
                                        ),
                                      );
                                    }
                                  },
                                  style: outlinedBtnStyle,
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
                            label: labelExportar,
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

  // --------------------------- Helpers de UI ---------------------------
  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
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

  // 🔧 Texto de botón que NUNCA se parte en 2 líneas
  Widget _oneLineLabel(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.visible,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  String _fmtTons(num v) {
    final d = v.toDouble();
    if (d == d.truncateToDouble()) return '${d.toStringAsFixed(0)} T';
    return '${d.toStringAsFixed(1)} T';
  }

  String _fmtMoney(num v) =>
      _money.format(v).replaceAll(',00', '');

  // --------------------------------------------------------------------------
  // WhatsApp + exportar
  // --------------------------------------------------------------------------
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
    final uri =
        Uri.parse('https://wa.me/${normalized.replaceAll('+', '')}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible abrir WhatsApp.')),
      );
    }
  }

  Future<void> _exportTrip(
    BuildContext context,
    Map<String, dynamic> raw,
    Trip trip,
  ) async {
    String s(String key, {String fallback = ''}) {
      final v = raw[key];
      return (v == null) ? fallback : v.toString().trim();
    }

    num? n(String key, {num? fallback}) {
      final v = raw[key];
      if (v is num) return v;
      if (v is String) {
        final parsed = num.tryParse(
          v.replaceAll('.', '').replaceAll(',', '.'),
        );
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    final origen = s('origen', fallback: trip.origin);
    final destino = s('destino', fallback: trip.destination);
    final pesoNum = n('peso', fallback: trip.tons);
    final tipoCarga = s('tipo_carga', fallback: trip.cargoType);
    final tipoVehiculo = s('tipo_vehiculo', fallback: trip.vehicle);
    final valorNum = n('valor', fallback: trip.price);
    final empresa = s('empresa', fallback: trip.empresa ?? '');

    final conductor = s('conductor', fallback: '');
    final observaciones = s('observaciones', fallback: '');
    final comercial = s('comercial', fallback: trip.comercial ?? '');
    final contacto = s('contacto', fallback: trip.contacto ?? '');

    final buffer = StringBuffer()
      ..writeln('📦 Detalle del viaje')
      ..writeln('Ruta: $origen → $destino')
      ..writeln('Peso: ${pesoNum != null ? _fmtTons(pesoNum) : '-'}')
      ..writeln('Tipo de carga: ${tipoCarga.isEmpty ? '-' : tipoCarga}')
      ..writeln('Tipo de vehículo: ${tipoVehiculo.isEmpty ? '-' : tipoVehiculo}')
      ..writeln('Valor: ${valorNum != null ? _fmtMoney(valorNum) : '-'}')
      ..writeln('Empresa: ${empresa.isEmpty ? '-' : empresa}')
      ..writeln('Conductor: ${conductor.isEmpty ? '-' : conductor}')
      ..writeln('Observaciones: ${observaciones.isEmpty ? '-' : observaciones}')
      ..writeln('Comercial: ${comercial.isEmpty ? '-' : comercial}')
      ..writeln('Contacto: ${contacto.isEmpty ? '-' : contacto}');

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Información copiada. ¡Lista para exportar!'),
      ),
    );
  }
}
