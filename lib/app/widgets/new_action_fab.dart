import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:flutter/material.dart';

class NewActionFab extends StatelessWidget {
  const NewActionFab({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor,   // 👈 nuevo
    this.foregroundColor,   // 👈 opcional (color del texto/ícono)
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? backgroundColor; // 👈 nuevo
  final Color? foregroundColor; // 👈 nuevo

  @override
  Widget build(BuildContext context) {
    final Color bg = Theme.of(context).brightness == Brightness.light
          ? kGreenStrong
          : kDeepDarkGreen ;
    final Color fg = Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : kGreyText ;

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
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
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
