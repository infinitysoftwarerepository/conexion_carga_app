import 'package:flutter/material.dart';

// ✅ Pantalla que lista los viajes (clase: LoadsPage)
import 'package:bolsa_carga_app/features/loads/presentation/pages/my_loads_page.dart';

// ✅ Botón de mosaico reutilizable
import 'package:bolsa_carga_app/features/loads/presentation/widgets/feature_button.dart';

// ✅ Toggle de tema (sol/luna)
import 'package:bolsa_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

// ✅ Carrusel reutilizable del banner inferior
import 'package:bolsa_carga_app/features/loads/presentation/widgets/banner_carousel.dart';

// ✅ NUEVO: AppBar reutilizable
import 'package:bolsa_carga_app/features/loads/presentation/widgets/custom_app_bar.dart';

// ✅ NUEVO: Menú del muñequito reutilizable
import 'package:bolsa_carga_app/features/loads/presentation/widgets/anchored_menu_button.dart';

// ✅ Para regresar a StartPage al cerrar sesión
import 'package:bolsa_carga_app/features/loads/presentation/pages/start_page.dart';

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
        height: 72,
        centerTitle: true,

        // 👤 Menú del muñequito (leading) — reutilizable
        leading: AnchoredMenuButton(
          actions: [
            MenuAction(
              label: 'Ver/editar perfil',
              icon: Icons.person,
              onPressed: () {
                // TODO: Abrir pantalla de perfil cuando exista
              },
            ),
            MenuAction(
              label: 'Cerrar sesión',
              icon: Icons.logout,
              onPressed: () {
                // Limpia el stack y vuelve a StartPage
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const StartPage()),
                  (_) => false,
                );
              },
            ),
          ],
        ),

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
                interval: Duration(seconds: 5),
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
