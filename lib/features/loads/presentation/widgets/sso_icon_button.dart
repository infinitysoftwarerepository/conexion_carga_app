import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Botón redondo para SSO (Google, Microsoft, Apple, etc.)
/// - Reutilizable y “theming-aware”
/// - Si no pasas colores, usa `surfaceVariant`/`onSurfaceVariant` del tema
///
/// Ejemplo de uso:
/// ```dart
/// Row(
///   children:[
///     SsoIconButton(icon: FontAwesomeIcons.google, onTap: () {} ),
///     SsoIconButton(icon: FontAwesomeIcons.microsoft, onTap: () {} ),
///     SsoIconButton(icon: FontAwesomeIcons.apple, onTap: () {} ),
///   ],
/// )
/// ```
class SsoIconButton extends StatelessWidget {
  const SsoIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  /// Ícono de marca (usa FontAwesome: Google/Microsoft/Apple, etc.)
  final IconData icon;

  /// Acción al tocar (integra tu flujo OAuth más adelante)
  final VoidCallback? onTap;

  /// Radio del círculo
  final double radius;

  /// Colores (opcionales). Si no se especifican, se derivan del tema.
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bg = backgroundColor ?? cs.surfaceVariant;
    final Color fg = iconColor ?? cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius + 4),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: FaIcon(icon, color: fg, size: radius), // ícono del tamaño del radio
      ),
    );
  }
}
