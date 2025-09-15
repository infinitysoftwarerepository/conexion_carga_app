import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bolsa_carga_app/presentation/widgets/inputs/app_text_field.dart';
import 'package:bolsa_carga_app/presentation/widgets/inputs/app_multiline_field.dart';
import 'package:bolsa_carga_app/presentation/widgets/inputs/app_datetime_field.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  // Controllers
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
    // TODO: aquí armar el objeto/DTO y enviar a repositorio o API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viaje registrado (diseño listo).')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 12.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar nuevo viaje')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // fila 1
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Empresa / Cliente',
                      hint: 'Nombre de la empresa o persona',
                      controller: _empresaCtrl,
                      icon: Icons.apartment,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // fila 2
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Origen',
                      hint: 'Ciudad de origen',
                      controller: _origenCtrl,
                      icon: Icons.location_on_outlined,
                      // onChanged: (v) { /* luego: autocompletar */ },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Destino',
                      hint: 'Ciudad de destino',
                      controller: _destinoCtrl,
                      icon: Icons.flag_outlined,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // fila 3
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Tipo de carga',
                      hint: 'Granel, Paletizado, etc.',
                      controller: _tipoCargaCtrl,
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Peso (T)',
                      hint: 'Ej: 32.0',
                      controller: _pesoCtrl,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      icon: Icons.scale_outlined,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // fila 4
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Valor (COP)',
                      hint: 'Ej: 9.200.000',
                      controller: _valorCtrl,
                      keyboardType: TextInputType.number,
                      icon: Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Comercial',
                      hint: 'Nombre del comercial',
                      controller: _comercialCtrl,
                      icon: Icons.badge_outlined,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // fila 5
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Contacto (teléfono)',
                      hint: 'Cel del comercial',
                      controller: _contactoCtrl,
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Conductor',
                      hint: 'Nombre del conductor',
                      controller: _conductorCtrl,
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // fila 6
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Vehículo',
                      hint: 'Placa o identificación',
                      controller: _vehiculoCtrl,
                      icon: Icons.local_shipping_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Tipo de vehículo',
                      hint: 'Tracto, Sencillo, etc.',
                      controller: _tipoVehiculoCtrl,
                      icon: Icons.agriculture_outlined,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // fila 7
              Row(
                children: [
                  Expanded(
                    child: AppDateTimeField(
                      label: 'Fecha y hora de salida',
                      controller: _salidaCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDateTimeField(
                      label: 'Fecha y hora de llegada (estimada)',
                      controller: _llegadaCtrl,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),

              // Observaciones
              AppMultilineField(
                label: 'Observaciones',
                controller: _obsCtrl,
                hint: 'Detalles adicionales…',
                minLines: 4,
                maxLines: 8,
              ),
              const SizedBox(height: 20),

              // Botones
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
