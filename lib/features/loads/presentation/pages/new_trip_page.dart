import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Inputs
import 'package:conexion_carga_app/core/widgets/inputs/app_text_field.dart';
import 'package:conexion_carga_app/core/widgets/inputs/app_multiline_field.dart';
import 'package:conexion_carga_app/core/widgets/inputs/app_datetime_field.dart';

// Toggle Tema
import 'package:conexion_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

// AppBar custom (ya lo usas)
import 'package:conexion_carga_app/features/loads/presentation/widgets/custom_app_bar.dart';

// Reutilizables de layout
import 'package:conexion_carga_app/core/widgets/forms/form_layout.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final _empresaCtrl = TextEditingController();
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

  @override
  void dispose() {
    _empresaCtrl.dispose();
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

  void _guardar() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Viaje registrado (diseño listo).')));
    Navigator.of(context).pop();
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
              AppTextField(
                label: 'Empresa / Cliente',
                hint: 'Nombre de la empresa o persona',
                controller: _empresaCtrl,
                icon: Icons.apartment,
              ),
              const FormGap(),

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
                  hint: 'Granel, Paletizado, etc.',
                  controller: _tipoCargaCtrl,
                  icon: Icons.inventory_2_outlined,
                ),
                right: AppTextField(
                  label: 'Peso (T)',
                  hint: 'Ej: 32.0',
                  controller: _pesoCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 20),

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
