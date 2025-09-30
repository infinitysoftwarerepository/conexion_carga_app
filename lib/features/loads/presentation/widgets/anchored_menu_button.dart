import 'package:flutter/material.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/features/loads/presentation/widgets/new_action_fab.dart';

/// Acción de menú (texto + ícono + callback)
class MenuAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const MenuAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

/// Botón con ícono (muñequito) que al tocar abre un popup anclado al botón.
/// Reutilizable: pásale tantas acciones como quieras.
class AnchoredMenuButton extends StatelessWidget {
  const AnchoredMenuButton({
    super.key,
    required this.actions,
    this.tooltip = 'Perfil',
    this.icon = Icons.person_outline,
    this.iconSize = 24,
    this.iconColor,
  });

  final List<MenuAction> actions;
  final String tooltip;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final GlobalKey anchorKey = GlobalKey();

    Future<void> openMenu() async {
      final renderObject = anchorKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox) return;

      final box = renderObject;
      final Offset topLeft = box.localToGlobal(Offset.zero);
      final Size size = box.size;

      final RelativeRect position = RelativeRect.fromLTRB(
        topLeft.dx,
        topLeft.dy + size.height,
        topLeft.dx + size.width,
        topLeft.dy,
      );

      final bool isLight = Theme.of(context).brightness == Brightness.light;
      final Color bg = isLight ? kGreenStrong : kDeepDarkGreen;
      final Color fg = isLight ? Colors.white : kGreyText;

      await showMenu<void>(
        context: context,
        position: position,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        items: [
          for (int i = 0; i < actions.length; i++)
            PopupMenuItem<void>(
              padding: EdgeInsets.zero,
              child: Padding(
                // primer ítem con más padding arriba
                padding: EdgeInsets.fromLTRB(12, i == 0 ? 12 : 4, 12, 8),
                child: NewActionFab(
                  label: actions[i].label,
                  icon: actions[i].icon,
                  backgroundColor: bg,
                  foregroundColor: fg,
                  onTap: () {
                    Navigator.pop(context); // cierra popup
                    // ejecuta la acción fuera del frame del popup
                    Future.microtask(actions[i].onPressed);
                  },
                ),
              ),
            ),
        ],
      );
    }

    return IconButton(
      key: anchorKey,
      tooltip: tooltip,
      icon: Icon(icon, size: iconSize, color: iconColor),
      onPressed: openMenu,
    );
  }
}
