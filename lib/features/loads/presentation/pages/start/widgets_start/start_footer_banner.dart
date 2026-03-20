import 'dart:async';

import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';

class StartFooterBanner extends StatefulWidget {
  const StartFooterBanner({
    super.key,
    required this.donationNumber,
    required this.onTapDonation,
  });

  final String donationNumber;
  final VoidCallback onTapDonation;

  @override
  State<StartFooterBanner> createState() => _StartFooterBannerState();
}

class _StartFooterBannerState extends State<StartFooterBanner> {
  static const String _prefixText =
      '¿Desearías apoyar este proyecto? Llave Bre-B: ';

  static const List<String> _carouselImages = [
    'assets/images/como_participar.png',
    'assets/images/logo_conexion_carga_oficial_cliente_V1.png',
    'assets/images/gana_premios_tres_pasos.png',
    'assets/images/gana_premios_con_conexion_carga.png',
    'assets/images/proximamente_V2.png',
    'assets/images/con_tu_apoyo.png',
    'assets/images/qr_inferior.png',
  ];

  static const double _carouselHeight = 122;

  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();

    if (_carouselImages.length <= 1) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || !_pageController.hasClients) return;

      final nextIndex = (_currentIndex + 1) % _carouselImages.length;

      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  void _restartAutoPlay() {
    _autoPlayTimer?.cancel();
    _startAutoPlay();
  }

  void _goToPrevious() {
    if (!_pageController.hasClients) return;

    final prev = _currentIndex == 0
        ? _carouselImages.length - 1
        : _currentIndex - 1;

    _pageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _restartAutoPlay();
  }

  void _goToNext() {
    if (!_pageController.hasClients) return;

    final next = (_currentIndex + 1) % _carouselImages.length;

    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _restartAutoPlay();
  }

  void _openImagePreview(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.white,
        pageBuilder: (_, __, ___) => _BannerImagePreviewPage(
          images: _carouselImages,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.22),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surfaceColor = Theme.of(context).scaffoldBackgroundColor;

    final textStyle = TextStyle(
      fontSize: 12,
      color: isLight ? kGreyText : kGreySoft,
    );

    final linkStyle = textStyle.copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    final activeDotColor = isLight ? kBrandOrange : kBrandGreen;
    final inactiveDotColor = isLight ? kGreySoft : Colors.white24;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 12,
        color: surfaceColor,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _prefixText,
                          textAlign: TextAlign.center,
                          style: textStyle,
                        ),
                        GestureDetector(
                          onTap: widget.onTapDonation,
                          child: Text(
                            widget.donationNumber,
                            style: linkStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: _carouselHeight,
                    width: double.infinity,
                    color: isLight ? Colors.white : kDeepDarkGray,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _carouselImages.length,
                          onPageChanged: (index) {
                            if (!mounted) return;
                            setState(() => _currentIndex = index);
                            _restartAutoPlay();
                          },
                          itemBuilder: (context, index) {
                            final imagePath = _carouselImages[index];

                            return GestureDetector(
                              onTap: () => _openImagePreview(index),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: isLight ? Colors.white : kDeepDarkGray,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          left: 6,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _arrowButton(
                              icon: Icons.chevron_left,
                              onTap: _goToPrevious,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _arrowButton(
                              icon: Icons.chevron_right,
                              onTap: _goToNext,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_carouselImages.length, (index) {
                    final isActive = index == _currentIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? activeDotColor : inactiveDotColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerImagePreviewPage extends StatefulWidget {
  const _BannerImagePreviewPage({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_BannerImagePreviewPage> createState() => _BannerImagePreviewPageState();
}

class _BannerImagePreviewPageState extends State<_BannerImagePreviewPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  /// true = horizontal (rotada 90°)
  /// false = vertical/original
  bool _isHorizontal = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    final prev = _currentIndex == 0
        ? widget.images.length - 1
        : _currentIndex - 1;

    _pageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  void _goToNext() {
    final next = (_currentIndex + 1) % widget.images.length;

    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  Widget _overlayCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.black12,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: iconColor ?? Colors.black,
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quarterTurns = _isHorizontal ? 1 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return _ZoomableBannerImage(
                  assetPath: widget.images[index],
                  quarterTurns: quarterTurns,
                );
              },
            ),

            Positioned(
              top: 8,
              left: 8,
              child: _overlayCircleButton(
                icon: Icons.close,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: _overlayCircleButton(
                icon: _isHorizontal
                    ? Icons.stay_current_portrait
                    : Icons.stay_current_landscape,
                onTap: () {
                  setState(() {
                    _isHorizontal = !_isHorizontal;
                  });
                },
              ),
            ),

            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _overlayCircleButton(
                  icon: Icons.chevron_left,
                  onTap: _goToPrevious,
                  iconColor: Colors.black87,
                ),
              ),
            ),

            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _overlayCircleButton(
                  icon: Icons.chevron_right,
                  onTap: _goToNext,
                  iconColor: Colors.black87,
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isHorizontal
                          ? 'Vista horizontal · usa dos dedos o doble toque'
                          : 'Vista vertical · usa dos dedos o doble toque',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.images.length, (index) {
                      final isActive = index == _currentIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? kBrandOrange : Colors.black12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomableBannerImage extends StatefulWidget {
  const _ZoomableBannerImage({
    required this.assetPath,
    required this.quarterTurns,
  });

  final String assetPath;
  final int quarterTurns;

  @override
  State<_ZoomableBannerImage> createState() => _ZoomableBannerImageState();
}

class _ZoomableBannerImageState extends State<_ZoomableBannerImage> {
  late final TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void didUpdateWidget(covariant _ZoomableBannerImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.quarterTurns != widget.quarterTurns) {
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final currentMatrix = _transformationController.value;

    if (!currentMatrix.isIdentity()) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    final position = _doubleTapDetails?.localPosition;
    if (position == null) return;

    const double scale = 2.2;

    final zoomed = Matrix4.identity()
      ..translate(-position.dx * (scale - 1), -position.dy * (scale - 1))
      ..scale(scale);

    _transformationController.value = zoomed;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rotated = widget.quarterTurns % 2 != 0;

        final imageWidth = rotated
            ? constraints.maxHeight - 32
            : constraints.maxWidth - 32;

        final imageHeight = rotated
            ? constraints.maxWidth - 32
            : constraints.maxHeight - 32;

        return GestureDetector(
          onDoubleTapDown: _handleDoubleTapDown,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1.0,
            maxScale: 5.0,
            boundaryMargin: const EdgeInsets.all(100),
            panEnabled: true,
            scaleEnabled: true,
            child: Center(
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: widget.quarterTurns,
                    child: SizedBox(
                      width: imageWidth,
                      height: imageHeight,
                      child: Image.asset(
                        widget.assetPath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}