import 'package:flutter/material.dart';

/// 🔘 Botón de flecha reutilizable para banners
/// - [direction]: izquierda o derecha
/// - [backgroundColor]: color del círculo (usa opacidad baja para que sea translúcido)
/// - [iconColor]: color del ícono (flecha)
/// - [onTap]: callback al presionar
class ArrowButton extends StatelessWidget {
  final AxisDirection direction;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const ArrowButton({
    super.key,
    required this.direction,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: backgroundColor, // 👈 círculo translúcido
          shape: BoxShape.circle,
        ),
        child: Icon(
          direction == AxisDirection.left
              ? Icons.chevron_left
              : Icons.chevron_right,
          color: iconColor, // 👈 color de la flecha
          size: 22,
        ),
      ),
    );
  }
}
