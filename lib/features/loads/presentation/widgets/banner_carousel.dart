import 'dart:async';
import 'package:conexion_carga_app/features/loads/presentation/widgets/nav_arrow_button.dart';
import 'package:flutter/material.dart';

// Si ya creaste las flechas como widget reutilizable, deja este import.
// Si las tienes en otra ruta, ajusta el import:


class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.imagePaths,
    this.height = 140,
    this.interval = const Duration(seconds: 10), // ← Cambia aquí el tiempo
    this.borderRadius = 16,
    this.backgroundColor,
    this.showArrows = true,
    this.showDots = true,
  });

  /// Rutas de assets (png/webp/jpg).
  final List<String> imagePaths;

  /// Alto del área del banner.
  final double height;

  /// Intervalo del auto-slide.
  final Duration interval;

  /// Bordes redondeados del contenedor.
  final double borderRadius;

  /// Color de fondo del banner (por defecto usa el del tema).
  final Color? backgroundColor;

  /// Mostrar flechas de navegación.
  final bool showArrows;

  /// Mostrar indicadores (puntos).
  final bool showDots;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageCtrl;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _restartTimer(); // arranca el auto-slide
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  // Reinicia el temporizador (útil cuando el usuario pasa con flechas).
  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) => _goNext());
  }

  void _goNext() {
    if (!mounted) return;
    final total = widget.imagePaths.length;
    final next = (_index + 1) % total;
    _animateTo(next);
  }

  void _goPrev() {
    if (!mounted) return;
    final total = widget.imagePaths.length;
    final prev = (_index - 1 + total) % total;
    _animateTo(prev);
  }

  void _animateTo(int page) {
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8), // separa del borde inferior
      child: SizedBox(
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fondo + PageView
            Material(
              color: widget.backgroundColor ?? theme.colorScheme.surface,
              elevation: 0,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    _restartTimer(); // ← vuelve a contar 10s desde cero
                  },
                  itemCount: widget.imagePaths.length,
                  itemBuilder: (context, i) {
                    final path = widget.imagePaths[i];
                    return Container(
                      // Un poco de padding para que no “pegue” a los bordes
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      color: Colors
                          .transparent, // por si las imágenes tienen transparencia
                      child: FittedBox(
                        fit: BoxFit
                            .contain, // ← muestra la IMAGEN COMPLETA sin recortes
                        child: Image.asset(
                          path,
                          // Para PNG con transparencia, no hace falta más.
                          // Si quieres asegurar que respete gamma/antialias, puedes
                          // añadir filterQuality:
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Flechas (muy transparentes)
            if (widget.showArrows) ...[
              Positioned(
                left: 6,
                child: ArrowButton(
                  direction: AxisDirection.left,
                  // círculo MUY translúcido
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.08),
                  iconColor: theme.colorScheme.onSurface.withOpacity(0.85),
                  onTap: () {
                    _goPrev();
                    _restartTimer();
                  },
                ),
              ),
              Positioned(
                right: 6,
                child: ArrowButton(
                  direction: AxisDirection.right,
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.08),
                  iconColor: theme.colorScheme.onSurface.withOpacity(0.85),
                  onTap: () {
                    _goNext();
                    _restartTimer();
                  },
                ),
              ),
            ],

            // Indicadores (puntos)
            if (widget.showDots)
              Positioned(
                bottom: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.imagePaths.length, (i) {
                    final isActive = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: isActive ? 16 : 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
