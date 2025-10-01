// lib/features/loads/presentation/pages/checklist/widgets/tri_option_selector.dart
import 'package:flutter/material.dart';
import '../models/checklist_models.dart';

class TriOptionSelector extends StatelessWidget {
  const TriOptionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TriOption? value;
  final ValueChanged<TriOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('CUMPLE'),
          selected: value == TriOption.cumple,
          onSelected: (_) => onChanged(TriOption.cumple),
        ),
        ChoiceChip(
          label: const Text('NO CUMPLE'),
          selected: value == TriOption.noCumple,
          onSelected: (_) => onChanged(TriOption.noCumple),
        ),
        ChoiceChip(
          label: const Text('NO APLICA'),
          selected: value == TriOption.noAplica,
          onSelected: (_) => onChanged(TriOption.noAplica),
        ),
      ],
    );
  }
}
