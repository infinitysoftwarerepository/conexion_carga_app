import 'package:flutter/material.dart';

class NewActionFab extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsets? padding;

  const NewActionFab({
    super.key,
    required this.label,
    this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor = const Color(0xFF28A745), // verde del tema
    this.foregroundColor = Colors.white,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(right: 8, bottom: 8),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        icon: Icon(icon),
        label: Text(label),
        shape: const StadiumBorder(),
      ),
    );
  }
}
