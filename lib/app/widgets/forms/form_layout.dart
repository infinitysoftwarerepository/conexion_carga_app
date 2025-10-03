import 'package:flutter/material.dart';

/// Espaciado base coherente entre campos/filas.
const double kFormGap = 12;

/// Scaffold para pantallas de formulario: AppBar + scroll + padding coherente.
/// Mantiene el estilo que ya usas y deja la página lista para pegar filas/campos.
class FormScaffold extends StatelessWidget {
  const FormScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.centerTitle = true,
  });

  final Widget title;
  final List<Widget> children;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        centerTitle: centerTitle,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      ),
    );
  }
}

/// Fila reutilizable con dos campos (Expanded) y separación fija entre ellos.
/// Úsala para las filas 1x2 que ya tienes en tus formularios.
class FormRow2 extends StatelessWidget {
  const FormRow2({
    super.key,
    required this.left,
    required this.right,
    this.gap = 12,
  });

  final Widget left;
  final Widget right;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: gap),
        Expanded(child: right),
      ],
    );
  }
}

/// Separador vertical con el mismo gap que usas en toda la app.
class FormGap extends StatelessWidget {
  const FormGap({super.key, this.size = kFormGap});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

/// Título de sección muy simple y consistente.
class FormSectionTitle extends StatelessWidget {
  const FormSectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: style),
      ),
    );
  }
}
