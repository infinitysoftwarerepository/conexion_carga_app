// lib/app/widgets/new_action_fab.dart
import 'package:flutter/material.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

/// Botón “pill” reutilizable para acciones principales en headers.
///
/// ✅ Diseño consistente:
/// - MISMA altura en todos los botones
/// - Texto soporta 1–2 líneas (sin encoger con FittedBox)
/// - Pensado para grillas responsive (ancho variable)
///
/// 🎨 Colores:
/// - Por defecto usa tu tema (kGreenStrong / kDeepDarkGreen).
/// - Puedes sobrescribir con backgroundColor/foregroundColor.
/// - Si quieres cambiar “el color global” de estos botones:
///   👉 edita kGreenStrong/kDeepDarkGreen en theme_conection.dart
class NewActionFab extends StatelessWidget {
  const NewActionFab({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.minHeight = 46, // 👈 altura estándar (cabe 2 líneas bien)
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    this.borderRadius = 28,
    this.iconSize = 18,
    this.gap = 8,
    this.maxLines = 2,
    this.textAlign = TextAlign.center,
    this.textStyle,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  // 🎨 Overrides opcionales
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;

  // 📐 Layout tuning
  final double minHeight;
  final EdgeInsets padding;
  final double borderRadius;
  final double iconSize;
  final double gap;
  final int maxLines;
  final TextAlign textAlign;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Defaults por tema (si NO pasas overrides):
    final Color bg =
        backgroundColor ?? (isLight ? kGreenStrong : kDeepDarkGreen);
    final Color fg =
        foregroundColor ?? (isLight ? Colors.white : kGreyText);

    final baseStyle = (textStyle ??
            Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ) ??
            const TextStyle(fontWeight: FontWeight.w700))
        .copyWith(color: fg);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.max, // 👈 ocupa el ancho del contenedor
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: iconSize, color: iconColor ?? fg),
                  SizedBox(width: gap),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis, // evita overflows raros
                    textAlign: textAlign,
                    style: baseStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
