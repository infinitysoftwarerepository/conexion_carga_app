// lib/features/loads/presentation/pages/checklist/steps/step3_espacios_ocultos.dart
import 'package:flutter/material.dart';
import '../models/checklist_models.dart';

class Step3EspaciosOcultos extends StatefulWidget {
  const Step3EspaciosOcultos({super.key, required this.state});
  final ChecklistState state;

  @override
  State<Step3EspaciosOcultos> createState() => _Step3EspaciosOcultosState();
}

class _Step3EspaciosOcultosState extends State<Step3EspaciosOcultos> {
  @override
  Widget build(BuildContext context) {
    final entries = widget.state.espaciosOcultos.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VERIFICACIÓN DE ESPACIOS OCULTOS',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final e = entries[i];
              return CheckboxListTile(
                value: e.value,
                onChanged: (v) =>
                    setState(() => widget.state.espaciosOcultos[e.key] = v ?? false),
                title: Text(e.key),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
