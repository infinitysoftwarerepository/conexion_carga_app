import 'package:flutter/material.dart';

/// ===============================================================
/// 🌟 CustomAppBar
/// Reemplazo drop-in del AppBar de Flutter, pero:
///   - Implementa PreferredSizeWidget (para usarse en Scaffold.appBar)
///   - Permite configurar: altura, colores, centrado, sombra
///   - Acepta cualquier `title` como Widget (p.ej.: Column con 2 líneas)
///   - Leading y actions totalmente libres (íconos reutilizables)
///
/// Uso típico:
///   appBar: CustomAppBar(
///     height: 72,
///     centerTitle: true,
///     title: Text('Mi título'),
///     leading: const BackButton(),
///     actions: [IconButton(...), ...],
///   )
///
/// Si no pasas colores, toma los del Theme/AppBarTheme actuales.
/// ===============================================================
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;

  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.height = 56,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0, required int titleSpacing,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    // Colores: si no se pasan, usa los de AppBarTheme o cae al ColorScheme
    final bg = backgroundColor ?? appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final fg = foregroundColor ?? appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return AppBar(
      // 🔧 Aplicamos los parámetros que queremos controlar siempre
      toolbarHeight: height,
      centerTitle: centerTitle,
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: elevation,

      // 👇 Widgets tal cual los recibimos
      title: title,
      leading: leading,
      actions: actions,
    );
  }
}

/// ===============================================================
/// 🧱 Helper opcional: TwoLineTitle
/// Útil cuando quieres un título de dos líneas consistentemente.
/// Ejemplo:
///   title: TwoLineTitle(
///     top: 'BIENVENIDO',
///     bottom: userName,
///   )
/// ===============================================================
class TwoLineTitle extends StatelessWidget {
  final String top;
  final String bottom;
  final TextStyle? topStyle;
  final TextStyle? bottomStyle;
  final double spacing;

  const TwoLineTitle({
    super.key,
    required this.top,
    required this.bottom,
    this.topStyle,
    this.bottomStyle,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defTop = (theme.textTheme.titleLarge ?? const TextStyle())
        .copyWith(fontWeight: FontWeight.w700, fontSize: 22, color: theme.colorScheme.onBackground);
    final defBottom = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: 13,
      fontStyle: FontStyle.italic,
      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black54,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(top, style: topStyle ?? defTop),
        SizedBox(height: spacing),
        Text(bottom, style: bottomStyle ?? defBottom),
      ],
    );
  }
}
