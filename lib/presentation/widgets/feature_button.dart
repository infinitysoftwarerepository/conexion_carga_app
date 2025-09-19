import 'package:flutter/material.dart';
import '../themes/theme_conection.dart';

/// Botón “pastilla” inspirado en el mock.
/// Versión compacta: altura reducida, texto a la izquierda,
/// cápsula naranja a la derecha (no invade el texto).
class FeatureButton extends StatelessWidget {
  const FeatureButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const double radius = 100;
    const double height = 72; // ← más bajo que antes

    // Colores según estado habilitado
    final Color green = enabled ? kGreenStrong : kGreenDisabled;
    final Color orange = enabled ? kBrandOrange : kOrangeDisabled;
    final Color titleColor = enabled ? Colors.white : Colors.black54;
    final Color subColor =
        enabled ? Colors.white70 : Colors.black.withOpacity(0.4);

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: enabled ? onTap : null,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(1, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // ===========================
            // Zona de texto (70%)
            // ===========================
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(radius),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🅰️ Título
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 🅱️ Subtítulo
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subColor,
                        fontSize: 8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===========================
            // Cápsula naranja (30%)
            // ===========================
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(radius),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
