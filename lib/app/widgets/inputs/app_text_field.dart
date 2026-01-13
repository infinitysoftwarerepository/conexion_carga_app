import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';

/// ---------------------------------------------------------------------------
///  AppTextField  (SIMPLE)
/// ---------------------------------------------------------------------------
/// - Usa TextField (NO Form). Ideal para entradas sueltas o pantallas sin Form.
/// - No tiene `validator`. Si quieres validar, hazlo en el `onChanged` o al
///   enviar usando los TextEditingController desde la pantalla.
/// - Mantiene compatibilidad con el uso actual en tu proyecto.
///
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool obscureText; // 👈 para contraseñas
  final TextInputAction? textInputAction;
  final Widget? suffixIcon; // 👈 por si quieres un ojo para mostrar/ocultar

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.obscureText = false,
    this.textInputAction,
    this.suffixIcon, required List<TextInputFormatter> inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          obscureText: obscureText,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
///  AppFormTextField  (CON VALIDACIÓN – PARA FUTURO)
/// ---------------------------------------------------------------------------
/// - Usa TextFormField dentro de un Form. Incluye `validator`.
/// - No lo estás usando todavía; queda listo para cuando necesites validación
///   a nivel campo (UX pro: muestra el error debajo del input).
///
class AppFormTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  /// Validador opcional (null = válido).
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  const AppFormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.obscureText = false,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          obscureText: obscureText,
          textInputAction: textInputAction,
          autovalidateMode: autovalidateMode,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
