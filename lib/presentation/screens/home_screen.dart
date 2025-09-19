import 'package:flutter/material.dart';

// ✅ Pantalla que lista los viajes (clase: LoadsPage)
import 'package:bolsa_carga_app/presentation/screens/my_loads_screen.dart';

// ✅ Botón de mosaico reutilizable
import 'package:bolsa_carga_app/presentation/widgets/feature_button.dart';

// ✅ Toggle de tema (sol/luna)
import 'package:bolsa_carga_app/presentation/widgets/theme_toggle.dart';

// ✅ Muñequito de perfil reutilizable
import 'package:bolsa_carga_app/presentation/widgets/profile_glyph.dart';

// ✅ Carrusel reutilizable del banner inferior
import 'package:bolsa_carga_app/presentation/widgets/banner_carousel.dart';

// ✅ NUEVO: AppBar reutilizable
import 'package:bolsa_carga_app/presentation/widgets/custom_app_bar.dart';

/// 🏠 Pantalla principal (Home)
/// Mantiene el look exacto: título en dos líneas centrado,
/// muñequito a la izquierda, luna a la derecha.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.userName = 'Deibizon Londoño', // ← luego vendrá del login
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleSpacing: 0,
        height: 72,                 // 👈 mismo alto que usabas
        centerTitle: true,
        // 👈 Muñequito solo en Home (leading)
        leading: const ProfileGlyph(tooltip: 'Perfil'),
        // 👈 Título en dos líneas como lo tenías
        title: TwoLineTitle(
          top: 'BIENVENIDO',
          bottom: userName,
        ),
        // 👈 Toggle de tema a la derecha
        actions: [
          ThemeToggle(
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // =================== GRID DE MÓDULOS ===================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  // 👇 ajustas esto si quieres tiles más bajitos/altos
                  childAspectRatio: 3,
                  children: [
                    // ✅ Activo: navega a la bolsa de carga
                    FeatureButton(
                      title: 'BOLSA DE CARGA',
                      subtitle: 'Registro de viajes',
                      enabled: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoadsPage()),
                        );
                      },
                    ),

                    // ⛔ Aún deshabilitados
                    const FeatureButton(
                      title: 'ESTOY DISPONIBLE',
                      subtitle: 'Próximamente',
                      enabled: false,
                    ),
                    const FeatureButton(
                      title: 'CUMPLIDOS',
                      subtitle: 'Próximamente',
                      enabled: false,
                    ),
                    const FeatureButton(
                      title: 'FACTURACIÓN',
                      subtitle: 'Próximamente',
                      enabled: false,
                    ),
                    const FeatureButton(
                      title: 'HOJAS DE VIDA\nVEHÍCULOS',
                      subtitle: 'Próximamente',
                      enabled: false,
                    ),
                    const FeatureButton(
                      title: 'HOJAS DE VIDA\nCONDUCTORES',
                      subtitle: 'Próximamente',
                      enabled: false,
                    ),
                    const FeatureButton(
                      title: 'LIQUIDACIÓN DE\nVIAJES',
                      subtitle: 'Próximamente',
                      enabled: false,
                    ),
                  
                  ],
                ),
              ),
            ),

            // =================== BANNER INFERIOR ===================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: BannerCarousel(
                height: 140,
                imagePaths: const [
                  'assets/images/logo_conexion_carga_oficial_cliente_V1.png',
                  'assets/images/banner_llantas_30_off.png',
                  'assets/images/banner_seguros_20.png',
                ],
                interval: const Duration(seconds: 5),
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
