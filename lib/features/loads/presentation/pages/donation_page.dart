// lib/features/loads/presentation/pages/donation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

const _donationQrPath = 'assets/images/donation_qr_breb.png';
// Si tu archivo es .jpg usa esta línea en cambio:
// const _donationQrPath = 'assets/images/donation_qr_breb.jpg';

const _donationNumber = '0091262121';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  // Copiar la llave al portapapeles
  Future<void> _copyNumber(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _donationNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Llave copiada al portapapeles.')),
    );
  }

  // Compartir (placeholder por ahora, sin depender de paquetes extra)
  void _shareDonation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Por ahora puedes compartir tomando captura o copiando la llave.',
        ),
      ),
    );
  }

  // Guardar imagen (placeholder, sin implementar almacenamiento real)
  void _saveImage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'En una próxima versión podrás guardar la imagen directamente.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apoya este proyecto'),
        centerTitle: true,
        actions: const [
          ThemeToggle(size: 22),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ConstrainedBox(
                // Hace que como mínimo ocupe todo el alto disponible,
                // pero permite scroll en pantallas bajas (Galaxy S8+, etc.)
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mensaje superior
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '¡Con tu apoyo seguiremos mejorando Conexión Carga!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Tarjeta central con el QR (ancho máximo adaptativo)
                    Center(
                      child: LayoutBuilder(
                        builder: (context, inner) {
                          final maxWidth = inner.maxWidth;
                          // Limito el ancho para que se vea bien en todo lado
                          final cardWidth = maxWidth > 380
                              ? 380.0
                              : (maxWidth < 260 ? 260.0 : maxWidth);

                          return Container(
                            width: cardWidth,
                            decoration: BoxDecoration(
                              color: cs.surfaceVariant.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding:
                                const EdgeInsets.fromLTRB(16, 20, 16, 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Imagen del QR (relación de aspecto fija)
                                AspectRatio(
                                  aspectRatio: 3 / 5,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      _donationQrPath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text(
                                          'No se pudo cargar el código QR.\n'
                                          'Verifica el asset en pubspec.yaml.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: cs.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  'Llave Bre-B',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface.withOpacity(0.85),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),

                                // Píldora con el número
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    _donationNumber,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Escanéalo o usa la llave en tu app Bre-B / Bancolombia.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        cs.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botones inferiores: Compartir / Guardar / Copiar
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.share,
                            label: 'Compartir',
                            onTap: () => _shareDonation(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.download,
                            label: 'Guardar',
                            onTap: () => _saveImage(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.copy,
                            label: 'Copiar',
                            onTap: () => _copyNumber(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cs.primary.withOpacity(0.7)),
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        // FittedBox hace que el texto se ajuste sin cortarse (evita "Com...")
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
