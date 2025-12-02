// lib/app/widgets/new_action_fab.dart
import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:flutter/material.dart';

class NewActionFab extends StatelessWidget {
  const NewActionFab({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor,   // opcional: color de fondo del botón
    this.foregroundColor,   // opcional: color del texto
    this.iconColor,          // 👈 NUEVO: color SOLO del ícono
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? backgroundColor; // opcional
  final Color? foregroundColor; // opcional
  final Color? iconColor;       // 👈 NUEVO

  @override
  Widget build(BuildContext context) {
    // Colores por tema (si no pasan overrides)
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color bg = backgroundColor ?? (isLight ? kGreenStrong : kDeepDarkGreen);
    final Color textColor = foregroundColor ?? (isLight ? Colors.white : kGreyText);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                // 👇 usa iconColor si viene; si no, el mismo del texto
                Icon(icon, size: 20, color: iconColor ?? textColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
