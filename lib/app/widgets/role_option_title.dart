import 'package:flutter/material.dart';

/// Botón/Tile de selección de rol.
/// Cambiado para usar `secondaryContainer` (verde de marca) en el fondito
/// del icono y `onSecondaryContainer` para el color del ícono.
class RoleOptionTile extends StatelessWidget {
  const RoleOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ✅ Contenedor del ícono con el verde de marca (light) / deep green (dark)
              Container(
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,           // << verde de marca
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  icon,
                  size: 28,
                  color: cs.onSecondaryContainer,         // << contraste correcto
                ),
              ),
              const SizedBox(width: 16),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
