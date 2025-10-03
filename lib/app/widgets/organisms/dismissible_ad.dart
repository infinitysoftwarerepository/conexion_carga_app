import 'dart:async';
import 'package:flutter/material.dart';

class DismissibleAd extends StatefulWidget {
  const DismissibleAd({
    super.key,
    required this.imageAsset,
    this.aspectRatio = 1080/1350, // 4:5 aprox
    this.borderRadius = 16,
    this.autoDismiss = const Duration(seconds: 5),
    this.slideEnd = const Offset(0, 0.55),
    this.scaleEnd = 0.95,
    this.onDismissed,
    this.backgroundColor,
  });

  final String imageAsset;
  final double aspectRatio;
  final double borderRadius;
  final Duration autoDismiss;
  final Offset slideEnd;
  final double scaleEnd;
  final VoidCallback? onDismissed;
  final Color? backgroundColor;

  @override
  State<DismissibleAd> createState() => _DismissibleAdState();
}

class _DismissibleAdState extends State<DismissibleAd> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  Timer? _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _fade  = Tween(begin: 1.0, end: 0.0).animate(curved);
    _scale = Tween(begin: 1.0, end: widget.scaleEnd).animate(curved);
    _slide = Tween(begin: Offset.zero, end: widget.slideEnd).animate(curved);
    _timer = Timer(widget.autoDismiss, _startDismiss);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage(widget.imageAsset), context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _startDismiss() {
    if (!_visible || _ctrl.isAnimating) return;
    _ctrl.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _visible = false);
      widget.onDismissed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: widget.aspectRatio,
                        child: Image.asset(
                          widget.imageAsset,
                          fit: BoxFit.contain,  // se ve completa
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withOpacity(0.35),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _startDismiss,
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
  }
}
