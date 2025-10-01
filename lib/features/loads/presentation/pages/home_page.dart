import 'package:conexion_carga_app/features/loads/presentation/pages/checklist/checklist_flow_page.dart';
import 'package:flutter/material.dart';

// ✅ Pantalla que lista los viajes (clase: LoadsPage)
import 'package:conexion_carga_app/features/loads/presentation/pages/my_loads_page.dart';

// ✅ Botón de mosaico reutilizable
import 'package:conexion_carga_app/features/loads/presentation/widgets/feature_button.dart';

// ✅ Toggle de tema (sol/luna)
import 'package:conexion_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

// ✅ Carrusel reutilizable del banner inferior
import 'package:conexion_carga_app/features/loads/presentation/widgets/banner_carousel.dart';

// ✅ NUEVO: AppBar reutilizable
import 'package:conexion_carga_app/features/loads/presentation/widgets/custom_app_bar.dart';

// ✅ NUEVO: Menú del muñequito reutilizable
import 'package:conexion_carga_app/features/loads/presentation/widgets/anchored_menu_button.dart';

// ✅ Para regresar a StartPage al cerrar sesión
import 'package:conexion_carga_app/features/loads/presentation/pages/start_page.dart';

// ⬇️ IMPORTA LA NUEVA PÁGINA
import 'package:conexion_carga_app/features/loads/presentation/pages/checklist_page.dart';

import 'package:conexion_carga_app/features/loads/presentation/pages/home_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.userName = 'Nombre Apellido Usuario',
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleSpacing: 0,
        height: 72,
        centerTitle: true,
        leading: AnchoredMenuButton(
          actions: [
            MenuAction(
              label: 'Ver/editar perfil',
              icon: Icons.person,
              onPressed: () {},
            ),
            MenuAction(
              label: 'Cerrar sesión',
              icon: Icons.logout,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const StartPage()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
        title: TwoLineTitle(
          top: 'BIENVENIDO',
          bottom: userName,
        ),
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
                    // ✅ BOLSA DE CARGA
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

                    // ✅ CHECKLIST (AHORA CON onTap Y SIN const)
                    FeatureButton(
                      title: 'CHECKLIST',
                      subtitle: 'Inspección pre-operacional',
                      enabled: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChecklistFlowPage()),
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
