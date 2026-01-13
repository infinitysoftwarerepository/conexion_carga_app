import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/widgets/molecules/bottom_banner_section.dart';

/// ===============================================================
/// ✅ StartFooterBanner
/// - Banner inferior fijo
/// - NO usa altura fija para evitar overflow (igual que antes)
///
/// 🎯 Personalización:
/// - Cambia elevation para más/menos sombra
/// - Cambia donationNumber o el callback
/// ===============================================================
class StartFooterBanner extends StatelessWidget {
  const StartFooterBanner({
    super.key,
    required this.donationNumber,
    required this.onTapDonation,
  });

  final String donationNumber;
  final VoidCallback onTapDonation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 12,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: BottomBannerSection(
          donationNumber: donationNumber,
          onTapDonation: onTapDonation,
        ),
      ),
    );
  }
}
