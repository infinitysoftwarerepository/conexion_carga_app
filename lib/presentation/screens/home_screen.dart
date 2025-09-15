import 'package:flutter/material.dart';
import 'package:bolsa_carga_app/presentation/screens/my_loads_screen.dart';
import '../widgets/feature_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.userName = 'Nombre de usuario', // ← mañana vendrá del login
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 22,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: 13,
          color: Colors.black54,
          fontStyle: FontStyle.italic,
        );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 72,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BIENVENIDO', style: titleStyle),
            const SizedBox(height: 4),
            Text(userName, style: subtitleStyle),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.25,
          children: [
            // ✅ Activo: navega al listado de viajes
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

            // ⛔ Deshabilitados
            const FeatureButton(
              title: 'ESTOY DISPONIBLE',
              subtitle: 'Próximamente',
              enabled: false,
            ),
            const FeatureButton(
              title: 'CUMPLIDOS Y\nFACTURACIÓN',
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
    );
  }
}
