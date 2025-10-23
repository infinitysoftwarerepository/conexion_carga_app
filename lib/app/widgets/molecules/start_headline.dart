import 'package:flutter/material.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

class StartHeadline extends StatelessWidget {
  const StartHeadline({super.key, required this.subtitle});
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'CONEXIÓN CARGA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
            color: isLight ? kGreyText : kGreySoft,
          ),
        ),
      ],
    );
  }
}
