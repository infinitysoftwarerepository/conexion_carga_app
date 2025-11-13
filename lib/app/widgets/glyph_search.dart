import 'package:flutter/material.dart';

class GlyphSearch extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;
  final double size;
  final String? tooltip;
  final EdgeInsets padding;

  const GlyphSearch({
    super.key,
    this.onTap,
    this.color = const Color(0xFF757575), // gris
    this.size = 22,
    this.tooltip,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    // En AppBar los hijos de actions deben tener altura ~kToolbarHeight.
    return SizedBox(
      height: kToolbarHeight,
      child: IconButton(
        onPressed: onTap ?? () {}, // evita estado "disabled"
        icon: Icon(Icons.search, size: size, color: color),
        tooltip: tooltip,
        padding: padding,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        splashRadius: size + 2,
      ),
    );
  }
}
