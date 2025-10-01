// lib/features/loads/presentation/pages/checklist/steps/step1_info_basica.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/checklist_models.dart';

class Step1InfoBasica extends StatefulWidget {
  const Step1InfoBasica({super.key, required this.state});
  final ChecklistState state;

  @override
  State<Step1InfoBasica> createState() => _Step1InfoBasicaState();
}

class _Step1InfoBasicaState extends State<Step1InfoBasica> {
  final _formKey = GlobalKey<FormState>();
  final _placaCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _placaCtrl.text = widget.state.placa;
    _tipoCtrl.text = widget.state.tipoVehiculo;
    _colorCtrl.text = widget.state.color;
  }

  @override
  void dispose() {
    _placaCtrl
      ..removeListener(() {})
      ..dispose();
    _tipoCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDate: widget.state.fecha ?? now,
    );
    if (picked != null) setState(() => widget.state.fecha = picked);
  }

  bool validateAndSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.state.placa = _placaCtrl.text.trim().toUpperCase();
      widget.state.tipoVehiculo = _tipoCtrl.text.trim();
      widget.state.color = _colorCtrl.text.trim();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final fechaTxt = widget.state.fecha == null
        ? 'Seleccionar fecha'
        : DateFormat('dd/MM/yyyy').format(widget.state.fecha!);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // ——— Espacio superior para "bajar" el contenido ———
          const SizedBox(height: 8),

          // ——— Mensaje promocional ———
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '¡Realiza tu inspección pre-operacional en 5 simples pasos!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'INSPECCIÓN PRE-OPERACIONAL DE VEHÍCULO',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: pickFecha,
              icon: const Icon(Icons.event_outlined),
              label: Text(fechaTxt),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _placaCtrl,
            decoration: const InputDecoration(
              labelText: 'PLACA *',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _tipoCtrl,
            decoration: const InputDecoration(
              labelText: 'TIPO VEHÍCULO *',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _colorCtrl,
            decoration: const InputDecoration(
              labelText: 'COLOR *',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),

          const Spacer(),
          Text(
            'Complete los campos y use “Siguiente”.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
