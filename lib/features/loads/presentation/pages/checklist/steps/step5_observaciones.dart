// lib/features/loads/presentation/pages/checklist/steps/step5_observaciones.dart
import 'package:flutter/material.dart';
import '../models/checklist_models.dart';

class Step5Observaciones extends StatefulWidget {
  const Step5Observaciones({super.key, required this.state});
  final ChecklistState state;

  @override
  State<Step5Observaciones> createState() => _Step5ObservacionesState();
}

class _Step5ObservacionesState extends State<Step5Observaciones> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _obsCtrl;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _cedulaCtrl;

  @override
  void initState() {
    super.initState();
    _obsCtrl = TextEditingController(text: widget.state.comentarioGeneral);
    _nombreCtrl = TextEditingController(text: widget.state.nombreConductor);
    _cedulaCtrl = TextEditingController(text: widget.state.cedulaConductor);
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    _nombreCtrl.dispose();
    _cedulaCtrl.dispose();
    super.dispose();
  }

  bool validateAndSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.state.comentarioGeneral = _obsCtrl.text.trim();
      widget.state.nombreConductor = _nombreCtrl.text.trim();
      widget.state.cedulaConductor = _cedulaCtrl.text.trim();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const clausula =
        'Cláusula de veracidad y exactitud de la información: El conductor del vehículo garantiza '
        'que los datos consignados en el presente documento son veraces y se hace responsable de comunicar '
        'cualquier modificación de los mismos. El conductor será el único responsable de cualquier daño o '
        'perjuicio directo o indirecto que pudiere ocasionar a terceros a causa de la inexactitud o falsedad '
        'de la información suministrada para este documento.';

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _obsCtrl,
            decoration: const InputDecoration(
              labelText: 'Si tiene observaciones, por favor deje el comentario',
              border: OutlineInputBorder(),
            ),
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombres y Apellidos (COMPLETOS) del conductor *',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cedulaCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cédula *',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          const Text('Cláusula de veracidad y exactitud de la información',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(clausula, textAlign: TextAlign.justify),
          const Spacer(),
          Text('Revise y presione Guardar', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
