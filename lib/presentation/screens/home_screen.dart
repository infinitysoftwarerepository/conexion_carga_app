import 'package:bolsa_carga_app/presentation/themes/theme_conection.dart';
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

/// 🏠 Pantalla principal (Home)
/// Muestra saludo, nombre del usuario y accesos a funciones.
/// El color del “Nombre de usuario” se adapta a claro/oscuro.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.userName = 'Deibizon Londoño', // ← luego vendrá del login
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    // 🎨 Estilos dependientes del tema (claro/oscuro)
    final titleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Theme.of(context).colorScheme.onBackground,
        );

    // 👤 “Nombre de usuario” visible en ambos temas
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black54,
        );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 72,
        backgroundColor: Theme.of(context).brightness ==Brightness.dark
          ? Colors.black
          : kOrangeDisabled,

        // 👈 Muñequito solo en Home (leading)
        leading: const ProfileGlyph(
          tooltip: 'Perfil',
        ),

        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BIENVENIDO', style: titleStyle),
            const SizedBox(height: 4),
            Text(userName, style: subtitleStyle),
          ],
        ),

        // 🌗 Toggle del tema a la derecha
        actions: [
          ThemeToggle(
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea( // ✅ protege de los bordes del sistema
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
                  childAspectRatio: 3,  //altura de los botones
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
                      title: 'FACTURAR',
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
            // 📌 Lo subimos un “poquito” con padding y dejamos un SafeArea abajo.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // ← lo sube y separa bordes
              child: BannerCarousel(
                height: 140,
                imagePaths: const [
                  // 1) Logo ConnectionCargo (PNG transparente V2)
                  'assets/images/logo_conexion_carga_oficial_cliente_V1.png',
                  // 2) Banner ejemplo de llantas
                  'assets/images/banner_llantas_30_off.png',
                  // 3) Banner ejemplo de seguros
                  'assets/images/banner_seguros_20.png',
                ],
                // (Opcional) cambia el intervalo si quieres:
                interval: const Duration(seconds: 5),
                // (Opcional) redondeo suave para integrarlo con el fondo
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
