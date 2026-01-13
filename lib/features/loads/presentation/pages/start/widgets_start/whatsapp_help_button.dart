import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';

/// ===============================================================
/// ✅ WhatsAppHelpButton
/// - Botón flotante WhatsApp (izquierda)
/// - Burbuja "¿Necesitas ayuda?" aparece tras publicidad
///
/// 🎯 Personalización:
/// - Cambia bottomOffset si el footer cambia de tamaño
/// - Cambia color del botón (kGreenStrong) o sombra
/// - Cambia el texto "¿Necesitas ayuda?"
/// ===============================================================
class WhatsAppHelpButton extends StatelessWidget {
  const WhatsAppHelpButton({
    super.key,
    required this.showHint,
    required this.helpBubbleBg,
    required this.iconAsset,
    required this.onTap,
    this.bottomOffset = 180,
    this.left = 16,
  });

  final bool showHint;
  final Color helpBubbleBg;
  final String iconAsset;
  final Future<void> Function() onTap;

  /// Ajuste fino de posición respecto al footer
  final double bottomOffset;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottomOffset,
      left: left,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHint)
              Container(
                decoration: BoxDecoration(
                  color: helpBubbleBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(bottom: 6),
                child: const Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            GestureDetector(
              onTap: () => onTap(),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGreenStrong,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(iconAsset, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
