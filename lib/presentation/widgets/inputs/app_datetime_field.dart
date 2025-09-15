import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateTimeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String format;
  final DateTime? initial;

  const AppDateTimeField({
    super.key,
    required this.label,
    required this.controller,
    this.format = 'dd/MM/yyyy HH:mm',
    this.initial,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1);
    final last = DateTime(now.year + 2);

    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: first,
      lastDate: last,
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
    );
    if (time == null) return;

    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    controller.text = DateFormat(format).format(combined);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _pick(context),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.event),
            hintText: 'Selecciona fecha y hora',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
