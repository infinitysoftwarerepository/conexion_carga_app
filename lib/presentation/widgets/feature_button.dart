import 'package:flutter/material.dart';
import '../themes/theme_conection.dart';

class FeatureButton extends StatelessWidget {
  const FeatureButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor   = enabled ? kBrandGreen : kGreySoft; // ← fondo
    final textColor = enabled ? Colors.black : Colors.black54;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20), // ← radio
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🅰️ Título
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700, // ← grosor
                fontSize: 16,                // ← tamaño
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // 🅱️ Subtítulo (cursiva y tenue)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.75), // ← “transparente”
                fontSize: 12,                       // ← tamaño
                fontStyle: FontStyle.italic,        // ← cursiva
              ),
            ),
          ],
        ),
      ),
    );
  }
}
