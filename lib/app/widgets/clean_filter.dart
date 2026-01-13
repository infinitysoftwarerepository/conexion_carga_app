import 'package:flutter/material.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

class CleanFilter extends StatelessWidget {
  const CleanFilter({
    super.key,
    required this.onTap,
    this.enabled = true,
    this.showLabel = false,
    this.label = 'Limpiar',
  });

  final VoidCallback? onTap;
  final bool enabled;
  final bool showLabel;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bg = enabled
        ? (isLight ? kGreenStrong : kDeepDarkGreen)
        : (isLight ? kGreenDisabled : kDeepDarkGreen.withOpacity(0.35));

    final border = enabled
        ? (isLight ? kBrandOrange : kBrandOrange.withOpacity(0.9))
        : (isLight ? kOrangeDisabled : kBrandOrange.withOpacity(0.25));

    final fg = Colors.white;

    return Tooltip(
      message: 'Limpiar búsqueda y filtros',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1 : 0.55,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: showLabel ? 12 : 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: border, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_alt_off, size: 18, color: fg),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
