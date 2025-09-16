import 'package:flutter/material.dart';

class GlyphFilter extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;
  final double topWidth;
  final double step;
  final double height;
  final EdgeInsets padding;

  const GlyphFilter({
    super.key,
    this.onTap,
    this.color = const Color(0xFF757575), // gris medio
    this.topWidth = 22,
    this.step = 6,                        // 22, 16, 10
    this.height = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 12), required int size,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _line(width: topWidth),
            const SizedBox(height: 4),
            _line(width: topWidth - step),
            const SizedBox(height: 4),
            _line(width: topWidth - 2 * step),
          ],
        ),
      ),
    );
  }

  Widget _line({required double width}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
