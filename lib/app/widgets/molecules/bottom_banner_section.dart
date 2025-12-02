import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <- Clipboard
import 'package:conexion_carga_app/app/widgets/banner_carousel.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

/// Sección fija del final de la StartPage:
/// - Texto de apoyo con un número “enlace” que se puede COPIAR.
/// - Carrusel con el logo u otras imágenes.
///
/// 🔧 Cambios:
///  • `donationNumber` es configurable desde afuera.
///  • El número se muestra azul + subrayado y al tocarlo se copia al portapapeles.
class BottomBannerSection extends StatelessWidget {
  const BottomBannerSection({
    super.key,
    this.prefixText = '¡Apoya este proyecto! Llave Bre-B: ',
    required this.donationNumber,
    this.onTapDonation,
    this.carouselImages = const [
      'assets/images/logo_conexion_carga_oficial_cliente_V1.png',
    ],
    this.carouselHeight = 140, 
  });

  /// Texto antes del número (lo dejamos editable por si un día cambias banco o mensaje).
  final String prefixText;

  /// 📞 El número que se pintará como enlace y se copiará al tocarlo.
  final String donationNumber;
  final VoidCallback? onTapDonation;


  /// Imágenes del carrusel inferior.
  final List<String> carouselImages;

  /// Alto del carrusel.
  final double carouselHeight;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Estilos base: el texto normal y el “link”.
    final baseStyle = TextStyle(
      fontSize: 12,
      color: isLight ? kGreyText : kGreySoft,
    );

    final linkStyle = baseStyle.copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline,
      decorationThickness: 1.5,
    );

    return Column(
      children: [
        // ── Línea de texto con el número-enlace ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Center(
            // Wrap nos permite mezclar un Text “normal” con un botón estilo link,
            // manteniendo el ancho contenido y el centrado.
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(prefixText, textAlign: TextAlign.center, style: baseStyle),

                // Usamos TextButton para controlar el estilo y manejar onPressed,
                // y lo hacemos “plano” (sin padding extra) para que parezca un link.
                TextButton(
                  onPressed: () async {
                    // Si desde afuera nos mandan una acción, la usamos (abrir DonationPage)
                    if (onTapDonation != null) {
                      onTapDonation!();
                      return;
                    }

                    // Fallback: si no hay callback, sigue copiando al portapapeles
                    await Clipboard.setData(ClipboardData(text: donationNumber));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Número copiado: $donationNumber'),
                        ),
                      );
                    }
                  },

                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: linkStyle.color,
                    textStyle: linkStyle, // tamaño y subrayado
                  ),
                  child: Text(donationNumber),
                ),
              ],
            ),
          ),
        ),

        // ── Carrusel ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: BannerCarousel(
            height: carouselHeight,
            imagePaths: carouselImages,
            interval: const Duration(seconds: 5),
            borderRadius: 16,
          ),
        ),
      ],
    );
  }
}
