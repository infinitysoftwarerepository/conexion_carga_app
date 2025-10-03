import 'package:flutter/material.dart';

class AppMultilineField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  const AppMultilineField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.minLines = 4,
    this.maxLines = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
