// lib/app/widgets/time_bubbles.dart
import 'package:flutter/material.dart';

/// Burbuja genérica
class TimeBubble extends StatelessWidget {
  final String value;
  final String label;
  final bool compact; // true: cards, false: detalle

  const TimeBubble({
    super.key,
    required this.value,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final double fontSize = compact ? 11 : 14;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize - 1,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Burbujas pequeñas (horas + minutos) para las LoadCard
class TimeBubbleRowSmall extends StatelessWidget {
  final Duration remaining;

  const TimeBubbleRowSmall({
    super.key,
    required this.remaining,
  });


  @override
  Widget build(BuildContext context) {
    final totalMinutes = remaining.inMinutes;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours <= 0 && minutes <= 0) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 2,
      children: [
        if (hours > 0)
          TimeBubble(
            value: hours.toString(),
            label: 'h',
            compact: true,
          ),
        TimeBubble(
          value: minutes.toString(),
          label: 'min',
          compact: true,
        ),
      ],
    );
  }
}

/// Burbujas grandes (horas + min + seg) para TripDetailPage
class TimeBubbleRowBig extends StatelessWidget {
  final Duration remaining;

  const TimeBubbleRowBig({super.key, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final totalSeconds = remaining.inSeconds;
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours <= 0 && minutes <= 0 && seconds <= 0) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        TimeBubble(
          value: hours.toString(),
          label: 'h',
          compact: false,
        ),
        TimeBubble(
          value: minutes.toString(),
          label: 'min',
          compact: false,
        ),
        TimeBubble(
          value: seconds.toString().padLeft(2, '0'),
          label: 'seg',
          compact: false,
        ),
      ],
    );
  }
}
