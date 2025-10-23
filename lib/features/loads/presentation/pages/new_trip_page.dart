// lib/features/loads/presentation/pages/new_trip_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/app/widgets/inputs/app_text_field.dart';
import 'package:conexion_carga_app/app/widgets/inputs/app_multiline_field.dart';
import 'package:conexion_carga_app/app/widgets/inputs/app_datetime_field.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';
import 'package:conexion_carga_app/app/widgets/forms/form_layout.dart';

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/core/auth_session.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final _origenCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  final _tipoCargaCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _comercialCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _conductorCtrl = TextEditingController();
  final _vehiculoCtrl = TextEditingController();
  final _tipoVehiculoCtrl = TextEditingController();
  final _salidaCtrl = TextEditingController(
    text: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
  );
  final _llegadaCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  bool _premium = false; // viaje estándar por defecto

  @override
  void dispose() {
    _origenCtrl.dispose();
    _destinoCtrl.dispose();
    _tipoCargaCtrl.dispose();
    _pesoCtrl.dispose();
    _valorCtrl.dispose();
    _comercialCtrl.dispose();
    _contactoCtrl.dispose();
    _conductorCtrl.dispose();
    _vehiculoCtrl.dispose();
    _tipoVehiculoCtrl.dispose();
    _salidaCtrl.dispose();
    _llegadaCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  DateTime? _parseDT(String v) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').parseStrict(v);
    } catch (_) {
      return null;
    }
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    // Validaciones mínimas
    if (_origenCtrl.text.trim().isEmpty ||
        _destinoCtrl.text.trim().isEmpty ||
        _tipoCargaCtrl.text.trim().isEmpty ||
        _pesoCtrl.text.trim().isEmpty ||
        _valorCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios.')),
      );
      return;
    }

    final salida = _parseDT(_salidaCtrl.text);
    if (salida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fecha de salida inválida.')),
      );
      return;
    }
    final llegada = _llegadaCtrl.text.trim().isEmpty ? null : _parseDT(_llegadaCtrl.text);

    final tok = AuthSession.instance.token ?? '';
    final me = AuthSession.instance.user.value;

    final uri = Uri.parse('${Env.baseUrl}/api/loads');
    final body = {
      "empresa_id": null, // si luego guardas empresa del usuario, la envías aquí
      "origen": _origenCtrl.text.trim(),
      "destino": _destinoCtrl.text.trim(),
      "tipo_carga": _tipoCargaCtrl.text.trim(),
      "peso": double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0.0,
      "valor": int.tryParse(_valorCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0,
      // comercial_id lo pone el backend con el usuario actual
      "conductor": _conductorCtrl.text.trim().isEmpty ? null : _conductorCtrl.text.trim(),
      "vehiculo_id": _vehiculoCtrl.text.trim().isEmpty ? null : _vehiculoCtrl.text.trim(),
      "fecha_salida": salida.toIso8601String(),
      "fecha_llegada_estimada": llegada?.toIso8601String(),
      "premium_trip": _premium,
    };

    try {
      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (tok.isNotEmpty) 'Authorization': 'Bearer $tok',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 201) {
        String msg = 'No se pudo registrar el viaje (${res.statusCode}).';
        try {
          final m = jsonDecode(res.body);
          if (m is Map && m['detail'] != null) msg = m['detail'].toString();
        } catch (_) {}
        throw Exception(msg);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Viaje registrado para ${me?.firstName ?? 'ti'}.')),
      );
      if (mounted) Navigator.of(context).pop(true); // vuelve a la lista
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        titleSpacing: 0,
        height: 56,
        centerTitle: true,
        title: const Text('Registrar nuevo viaje'),
        actions: [
          ThemeToggle(color: cs.onSurface, size: 22),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FormRow2(
                left: AppTextField(
                  label: 'Origen',
                  hint: 'Ciudad de origen',
                  controller: _origenCtrl,
                  icon: Icons.location_on_outlined,
                ),
                right: AppTextField(
                  label: 'Destino',
                  hint: 'Ciudad de destino',
                  controller: _destinoCtrl,
                  icon: Icons.flag_outlined,
                ),
              ),
              const FormGap(),

              FormRow2(
                left: AppTextField(
                  label: 'Tipo de carga',
                  hint: 'Granel, Contenedor, etc.',
                  controller: _tipoCargaCtrl,
                  icon: Icons.inventory_2_outlined,
                ),
                right: AppTextField(
                  label: 'Peso (T)',
                  hint: 'Ej: 32.0',
                  controller: _pesoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  icon: Icons.scale_outlined,
                ),
              ),
              const FormGap(),

              FormRow2(
                left: AppTextField(
                  label: 'Valor (COP)',
                  hint: 'Ej: 9.200.000',
                  controller: _valorCtrl,
                  keyboardType: TextInputType.number,
                  icon: Icons.attach_money,
                ),
                right: AppTextField(
                  label: 'Comercial',
                  hint: 'Nombre del comercial',
                  controller: _comercialCtrl,
                  icon: Icons.badge_outlined,
                ),
              ),
              const FormGap(),

              FormRow2(
                left: AppTextField(
                  label: 'Contacto (teléfono)',
                  hint: 'Cel del comercial',
                  controller: _contactoCtrl,
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone_outlined,
                ),
                right: AppTextField(
                  label: 'Conductor',
                  hint: 'Nombre del conductor',
                  controller: _conductorCtrl,
                  icon: Icons.person_outline,
                ),
              ),
              const FormGap(),

              FormRow2(
                left: AppTextField(
                  label: 'Vehículo',
                  hint: 'Placa o identificación',
                  controller: _vehiculoCtrl,
                  icon: Icons.local_shipping_outlined,
                ),
                right: AppTextField(
                  label: 'Tipo de vehículo',
                  hint: 'Tracto, Sencillo, etc.',
                  controller: _tipoVehiculoCtrl,
                  icon: Icons.agriculture_outlined,
                ),
              ),
              const FormGap(),

              FormRow2(
                left: AppDateTimeField(
                  label: 'Fecha y hora de salida',
                  controller: _salidaCtrl,
                ),
                right: AppDateTimeField(
                  label: 'Fecha y hora de llegada (estimada)',
                  controller: _llegadaCtrl,
                ),
              ),
              const FormGap(),

              AppMultilineField(
                label: 'Observaciones',
                controller: _obsCtrl,
                hint: 'Detalles adicionales…',
                minLines: 4,
                maxLines: 8,
              ),
              const SizedBox(height: 12),

              // ── Tipo de viaje (horizontal, estándar/premium) ──────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Tipo de viaje', style: Theme.of(context).textTheme.titleSmall),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? cs.surfaceVariant.withOpacity(0.35)
                      : cs.surfaceVariant.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Estándar (siempre activo)
                    Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: _premium,
                          onChanged: (_) {}, // bloqueado: siempre estándar (por ahora)
                        ),
                        const Text('Viaje estándar'),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Premium (deshabilitado visualmente)
                    Opacity(
                      opacity: 0.45,
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _premium,
                            onChanged: null, // deshabilitado hasta suscripción
                          ),
                          const Text('Viaje premium'),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Registrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
