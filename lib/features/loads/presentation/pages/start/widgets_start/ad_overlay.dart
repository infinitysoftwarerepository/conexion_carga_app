import 'package:flutter/material.dart';

/// ===============================================================
/// ✅ AdOverlay
/// - Publicidad full-screen SOLO en vertical
/// - Sale con AnimatedSlide + AnimatedOpacity
///
/// 🎯 Personalización:
/// - Cambia duración/curvas
/// - Cambia el color del fondo oscuro
/// ===============================================================
class AdOverlay extends StatelessWidget {
  const AdOverlay({
    super.key,
    required this.isPortrait,
    required this.showAd,
    required this.imageAsset,
  });

  final bool isPortrait;
  final bool showAd;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    if (!isPortrait) return const SizedBox.shrink();

    return AnimatedSlide(
      offset: showAd ? Offset.zero : const Offset(0, 1.2),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: showAd ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 1800),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          alignment: Alignment.center,
          child: Image.asset(imageAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
