// lib/app/widgets/organisms/ad_banner_full_width.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Banner de inicio a TODO lo ancho:
/// - NO recorta (BoxFit.contain)
/// - Altura = ancho disponible * aspectRatio, CLAMP a la altura disponible
/// - Centrado en X **y también en Y**
/// - Esquinas redondeadas, botón ✕ y animación (slide + fade)
class AdBannerFullWidth extends StatefulWidget {
  const AdBannerFullWidth({
    super.key,
    required this.imageAsset,
    this.imageAspectRatio = 1.25,           // alto/ancho (tu PNG ~1080x1350 → 1.25)
    this.autoCloseAfter = const Duration(seconds: 5),
    this.borderRadius = 16,
    this.horizontalPadding = 8,
  });

  final String imageAsset;
  final double imageAspectRatio;            // alto/ancho
  final Duration? autoCloseAfter;
  final double borderRadius;
  final double horizontalPadding;

  @override
  State<AdBannerFullWidth> createState() => _AdBannerFullWidthState();
}

class _AdBannerFullWidthState extends State<AdBannerFullWidth>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();

    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _fade  = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(begin: const Offset(0, .05), end: Offset.zero).animate(curved);

    if (widget.autoCloseAfter != null) {
      _timer = Timer(widget.autoCloseAfter!, _close);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _close() {
    if (!_visible) return;
    _ctrl.reverse().whenComplete(() {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ancho disponible menos un pequeño “respiro” lateral
        final width = constraints.maxWidth - (widget.horizontalPadding * 2);

        // Altura deseada por proporción
        final desiredHeight = width * widget.imageAspectRatio;

        // Altura máxima que nos permite el contenedor padre
        final maxHeight = constraints.maxHeight;

        // ✅ Altura final: no exceder el alto disponible
        final height = math.min(desiredHeight, maxHeight);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: Stack(
                  children: [
                    // Fondo por si queda “aire” (con contain)
                    Container(color: Theme.of(context).colorScheme.surface),

                    // ✅ Centrado también en Y
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: height,
                        child: Image.asset(
                          widget.imageAsset,
                          fit: BoxFit.contain,           // NO recorta
                          alignment: Alignment.center,   // centrado en X e Y
                        ),
                      ),
                    ),

                    // Botón ✕
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black.withOpacity(0.35),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: _close,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.close, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
