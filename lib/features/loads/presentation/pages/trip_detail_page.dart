import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/features/loads/data/loads_api.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/features/loads/presentation/models/trip_share_payload.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/new_trip_page.dart';
import 'package:conexion_carga_app/features/loads/presentation/utils/trip_export_utils.dart';
import 'package:conexion_carga_app/features/loads/presentation/widgets/trip_detail_summary_card.dart';
import 'package:conexion_carga_app/features/loads/presentation/widgets/trip_export_poster.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;

  const TripDetailPage({
    super.key,
    required this.trip,
  });

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late Future<Map<String, dynamic>> _future;

  Duration? _remaining;
  Timer? _timer;

  final GlobalKey _exportPosterKey = GlobalKey();
  TripSharePayload? _sharePayload;
  bool _isExporting = false;

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

  Future<bool> _confirmEliminarViaje(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro que deseas eliminar el viaje?\n\n'
            'Más adelante podrás reutilizarlo rápidamente accediendo a:\n'
            'Mis viajes → (Viaje eliminado o vencido) → Reutilizar viaje',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _updateRemaining() {
    final rem = widget.trip.remaining;
    if (!mounted) return;

    setState(() {
      _remaining = rem;
    });
  }

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

  String _stringValue(
    Map<String, dynamic> raw,
    String key, {
    String fallback = '',
  }) {
    final v = raw[key];
    return v == null ? fallback : v.toString().trim();
  }

  num? _numValue(
    Map<String, dynamic> raw,
    String key, {
    num? fallback,
  }) {
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

  bool _isTripExpired(
    Map<String, dynamic> raw,
    Trip trip,
    Duration? rem,
  ) {
    final activo = raw['activo'];

    bool isActiveBackend() {
      if (activo == null) return trip.activo;
      if (activo is bool) return activo;
      return activo.toString().toLowerCase() == 'true';
    }

    return !isActiveBackend() || rem == null || rem <= Duration.zero;
  }

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

  String _fmtTons(num value) {
    final d = value.toDouble();
    if (d == d.truncateToDouble()) return '${d.toStringAsFixed(0)} T';
    return '${d.toStringAsFixed(1)} T';
  }

  String _fmtMoney(num value) {
    final int amount = value.round();
    final raw = amount.toString();
    final buffer = StringBuffer();

    int count = 0;
    for (int i = raw.length - 1; i >= 0; i--) {
      buffer.write(raw[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    final formatted = buffer.toString().split('').reversed.join();
    return '\$ $formatted';
  }

  String _buildTripShareText(TripSharePayload data) {
  final lines = <String>[
    '🚚 Detalle del viaje - Conexión Carga',
    '',
    'Origen: ${data.origin}',
    'Destino: ${data.destination}',
    'Peso: ${data.weight}',
    'Tipo de carga: ${data.cargoType}',
    'Tipo de vehículo: ${data.vehicleType}',
    'Valor: ${data.price}',
    'Empresa: ${data.company}',
    'Comercial: ${data.commercial}',
    'Contacto: ${data.contact}',
    'Observaciones: ${data.observations}',
    'Estado: ${data.statusText}',
  ];

  return lines.join('\n');
}

  TripSharePayload _buildPayload(
    Map<String, dynamic> raw,
    Trip trip,
  ) {
    final origen = _stringValue(raw, 'origen', fallback: trip.origin);
    final destino = _stringValue(raw, 'destino', fallback: trip.destination);
    final pesoNum = _numValue(raw, 'peso', fallback: trip.tons);
    final tipoCarga = _stringValue(raw, 'tipo_carga', fallback: trip.cargoType);
    final tipoVehiculo =
        _stringValue(raw, 'tipo_vehiculo', fallback: trip.vehicle);
    final valorNum = _numValue(raw, 'valor', fallback: trip.price);
    final empresa = _stringValue(raw, 'empresa', fallback: trip.empresa ?? '');
    final observaciones = _stringValue(raw, 'observaciones', fallback: '');
    final comercial =
        _stringValue(raw, 'comercial', fallback: trip.comercial ?? '');
    final contacto = _stringValue(raw, 'contacto', fallback: trip.contacto ?? '');

    final rem = _remaining ?? trip.remaining;
    final isExpired = _isTripExpired(raw, trip, rem);

    return TripSharePayload(
      origin: origen,
      destination: destino,
      weight: pesoNum != null ? _fmtTons(pesoNum) : '-',
      cargoType: tipoCarga.isEmpty ? '-' : tipoCarga,
      vehicleType: tipoVehiculo.isEmpty ? '-' : tipoVehiculo,
      price: valorNum != null ? _fmtMoney(valorNum) : '-',
      company: empresa.isEmpty ? '-' : empresa,
      observations: observaciones.isEmpty ? '-' : observaciones,
      commercial: comercial.isEmpty ? '-' : comercial,
      contact: contacto.isEmpty ? '-' : contacto,
      statusText: isExpired ? 'Vencido' : 'Disponible',
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneRaw) async {
    final digits = phoneRaw.replaceAll(RegExp(r'[^0-9+]'), '');

    if (digits.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este viaje no tiene un contacto válido.'),
        ),
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
        const SnackBar(
          content: Text('No fue posible abrir WhatsApp.'),
        ),
      );
    }
  }

 Future<void> _exportTrip(
  BuildContext context,
  Map<String, dynamic> raw,
  Trip trip,
) async {
  if (_isExporting) return;

  final payload = _buildPayload(raw, trip);
  final shareText = _buildTripShareText(payload);

  try {
    await precacheImage(
      const AssetImage('assets/icons/app_icon_V4.png'),
      context,
    );
    await precacheImage(
      const AssetImage('assets/images/fondo_tarjeta.png'),
      context,
    );

    if (!mounted) return;

    setState(() {
      _isExporting = true;
      _sharePayload = payload;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 180));

    final bytes = await captureRepaintBoundaryPngBytes(_exportPosterKey);
    final fileName =
        'viaje_${trip.id}_${DateTime.now().millisecondsSinceEpoch}.png';

    await sharePosterBytes(
      context: context,
      bytes: bytes,
      fileName: fileName,
      text: shareText,
      subject: 'Detalle del viaje - Conexión Carga',
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No fue posible generar la imagen: $e'),
      ),
    );
  } finally {
    if (!mounted) return;
    setState(() {
      _isExporting = false;
      _sharePayload = null;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleSpacing: 0,
        height: 56,
        centerTitle: true,
        title: const Text('Detalle del viaje'),
        actions: const [
          ThemeToggle(size: 22),
          SizedBox(width: 8),
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

          final raw = Map<String, dynamic>.from(snap.data ?? {});
          final trip = widget.trip;
          final payload = _buildPayload(raw, trip);
          final appColors = Theme.of(context).extension<AppColors>();
          final bubbleBg = appColors?.helpBubbleBg ?? Colors.amber.shade300;
          final rem = _remaining ?? trip.remaining;
          final isExpired = _isTripExpired(raw, trip, rem);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TripDetailSummaryCard(
                      data: payload,
                      isExpired: isExpired,
                      remaining: rem,
                      bubbleBg: bubbleBg,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),

              if (_sharePayload != null)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: 0.015,
                        child: Material(
                          color: Colors.transparent,
                          child: RepaintBoundary(
                            key: _exportPosterKey,
                            child: TripExportPoster(data: _sharePayload!),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          final raw = Map<String, dynamic>.from(snap.data ?? {});
          final trip = widget.trip;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final darkGreen =
              Theme.of(context).appBarTheme.backgroundColor ?? kDeepDarkGreen;

          final myUserId = AuthSession.instance.user.value?.id ?? '';
          final creadorId =
              _stringValue(raw, 'comercial_id', fallback: trip.comercialId ?? '');
          final isMine = creadorId == myUserId;
          final contacto =
              _stringValue(raw, 'contacto', fallback: trip.contacto ?? '');

          final rem = _remaining ?? trip.remaining;
          final isExpired = _isTripExpired(raw, trip, rem);

          Widget wppIcon() => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Image.asset(
                  'assets/icons/whatsapp.png',
                  height: 18,
                  fit: BoxFit.contain,
                ),
              );

          void onContact() => _openWhatsApp(context, contacto);

          final btnStyle = FilledButton.styleFrom(
            backgroundColor: isDark ? darkGreen : null,
            foregroundColor: isDark ? Colors.white : null,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );

          final outlinedBtnStyle = OutlinedButton.styleFrom(
            foregroundColor: isDark ? darkGreen : null,
            side: isDark ? BorderSide(color: darkGreen) : null,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );

          final labelContactar = _oneLineLabel('Contactar');
          final labelExportar =
              _oneLineLabel(_isExporting ? 'Generando...' : 'Exportar');
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
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.ios_share),
                            label: labelExportar,
                            onPressed: _isExporting
                                ? null
                                : () => _exportTrip(context, raw, trip),
                            style: btnStyle,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                                  icon:
                                      const Icon(Icons.delete_forever_outlined),
                                  label: labelEliminar,
                                  onPressed: () async {
                                    final ok =
                                        await _confirmEliminarViaje(context);
                                    if (!ok) return;

                                    try {
                                      await LoadsApi.expire(trip.id);
                                      if (!mounted) return;

                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      Navigator.pop(context, true);
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Viaje eliminado.'),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
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
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.ios_share),
                            label: labelExportar,
                            onPressed: _isExporting
                                ? null
                                : () => _exportTrip(context, raw, trip),
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
}