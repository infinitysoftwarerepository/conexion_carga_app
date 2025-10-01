// lib/features/loads/presentation/pages/checklist/steps/step4_componentes.dart
import 'package:flutter/material.dart';
import '../models/checklist_models.dart';
import '../widgets/tri_option_selector.dart';

class Step4Componentes extends StatefulWidget {
  const Step4Componentes({super.key, required this.state});
  final ChecklistState state;

  @override
  State<Step4Componentes> createState() => _Step4ComponentesState();
}

class _Step4ComponentesState extends State<Step4Componentes> {
  @override
  Widget build(BuildContext context) {
    final items = widget.state.componentes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ESTADO DE COMPONENTES',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final it = items[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.titulo, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      TriOptionSelector(
                        value: it.valor,
                        onChanged: (v) => setState(() => it.valor = v),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
