import 'package:bolsa_carga_app/presentation/themes/theme_conection.dart';
import 'package:flutter/material.dart';

class CountdownBar extends StatelessWidget {
  final int dots;                 // cuántos círculos (p.ej. 3)
  final double height;            // alto de la barrita
  final double dotSize;           // diámetro de cada círculo
  final double spacing;           // separación entre círculos
  final Color barColor;           // color de la barra
  final Color dotColor;           // color de los círculos
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final MainAxisAlignment align;  // start, center, spaceBetween, etc.

  const CountdownBar({
    super.key,
    this.dots = 3,
    this.height = 28,
    this.dotSize = 16,
    this.spacing = 6,
    this.barColor = kBrandOrange,
    this.dotColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.align = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: barColor, borderRadius: borderRadius),
      padding: padding,
      child: Row(
        mainAxisAlignment: align,
        children: List.generate(
          dots,
          (i) => Padding(
            padding: EdgeInsets.only(right: i == dots - 1 ? 0 : spacing),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
