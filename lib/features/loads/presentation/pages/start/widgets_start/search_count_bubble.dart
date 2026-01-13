import 'package:flutter/material.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

/// ===============================================================
/// ✅ SearchCountBubble
/// - Burbuja que muestra resultados: "Sin resultados", "1 viaje encontrado", "N viajes..."
///
/// 🎯 Personalización:
/// - Cambia el ícono
/// - Cambia tamaños de fuente
/// - Cambia opacidades
/// ===============================================================
class SearchCountBubble extends StatelessWidget {
  const SearchCountBubble({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bg = kGreenStrong.withOpacity(isLight ? 0.12 : 0.28);
    final border = kGreenStrong.withOpacity(isLight ? 0.5 : 0.7);
    final textColor = isLight ? Colors.black87 : Colors.white;

    final String label;
    if (count == 0) {
      label = 'Sin resultados';
    } else if (count == 1) {
      label = '1 viaje encontrado';
    } else {
      label = '$count viajes encontrados';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping_outlined, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
