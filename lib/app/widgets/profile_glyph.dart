import 'package:flutter/material.dart';

/// ===============================================================
/// 👤 ProfileGlyph
/// Botón reutilizable de “perfil/usuario” para AppBars u otras vistas.
///
/// - Cambia de color automáticamente según el tema (claro/oscuro)
///   usando los colores del Theme (no colores hardcodeados).
/// - Por ahora no hace nada en onTap; más adelante lo usamos para
///   navegar al perfil del usuario / editar datos, etc.
///
/// Cómo usar:
///   AppBar(
///     leading: const ProfileGlyph(),  // ← ícono a la izquierda
///   )
/// ===============================================================
class ProfileGlyph extends StatelessWidget {
  /// Acción al tocar el ícono (opcional). Si no se pasa, no hace nada.
  final VoidCallback? onTap;

  /// Tamaño del ícono en px.
  final double size;

  /// Color opcional. Si no se pasa, usa el color del tema actual.
  final Color? color;

  /// Padding alrededor del ícono (útil en AppBar).
  final EdgeInsets padding;

  /// Texto del tooltip al dejar presionado.
  final String? tooltip;

  const ProfileGlyph({
    super.key,
    this.onTap,
    this.size = 24,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    // Elegimos un color que se vea bien en claro/oscuro.
    final iconColor = color ??
        // Primero intentamos con el color del AppBar si está definido
        Theme.of(context).appBarTheme.foregroundColor ??
        // Si no, nos vamos por los colores del esquema
        Theme.of(context).colorScheme.onSurface;

    final icon = Icon(
      Icons.person_outline_rounded,
      size: size,
      color: iconColor,
    );

    return InkWell(
      onTap: onTap ?? () {}, // por ahora no hace nada
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: padding,
        child: tooltip == null ? icon : Tooltip(message: tooltip!, child: icon),
      ),
    );
  }
}
