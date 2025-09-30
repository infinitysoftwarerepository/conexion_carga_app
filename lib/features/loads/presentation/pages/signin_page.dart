import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Inputs tuyos
import 'package:conexion_carga_app/core/widgets/inputs/app_text_field.dart';

// Toggle tema
import 'package:conexion_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

// Botón SSO
import 'package:conexion_carga_app/features/loads/presentation/widgets/sso_icon_button.dart';

// Reutilizables de layout
import 'package:conexion_carga_app/core/widgets/forms/form_layout.dart';

// Términos
import 'package:conexion_carga_app/features/loads/presentation/pages/terms_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailCtrl = TextEditingController();
  final _tipoIdCtrl = TextEditingController();
  final _numIdCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acepto = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tipoIdCtrl.dispose();
    _numIdCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_acepto) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Debes aceptar los términos.')));
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Registro enviado (diseño listo).')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FormScaffold(
      title: const Text('Registrarme'),
      actions: [
        ThemeToggle(color: cs.onSurface, size: 22),
        const SizedBox(width: 8),
      ],
      children: [
        // Correo
        AppTextField(
          label: 'Correo Electrónico*',
          hint: 'tucorreo@dominio.com',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
          textInputAction: TextInputAction.next,
        ),
        const FormGap(),

        // Tipo id
        AppTextField(
          label: 'Tipo de identificación*',
          hint: 'Cédula de ciudadanía, NIT, etc.',
          controller: _tipoIdCtrl,
          icon: Icons.badge_outlined,
          textInputAction: TextInputAction.next,
        ),
        const FormGap(),

        // Número id
        AppTextField(
          label: 'Número de identificación*',
          hint: 'Tu número de documento',
          controller: _numIdCtrl,
          keyboardType: TextInputType.number,
          icon: Icons.confirmation_number_outlined,
          textInputAction: TextInputAction.next,
        ),
        const FormGap(),

        // Nombres
        AppTextField(
          label: 'Nombres*',
          hint: 'Nombres',
          controller: _nombresCtrl,
          icon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const FormGap(),

        // Apellidos
        AppTextField(
          label: 'Apellidos*',
          hint: 'Apellidos',
          controller: _apellidosCtrl,
          icon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const FormGap(),

        // Contraseña
        AppTextField(
          label: 'Contraseña*',
          hint: 'Mínimo 8 caracteres',
          controller: _passCtrl,
          icon: Icons.lock_outline,
          obscureText: _obscurePass,
          suffixIcon: IconButton(
            tooltip: _obscurePass ? 'Mostrar' : 'Ocultar',
            icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
          textInputAction: TextInputAction.next,
        ),
        const FormGap(),

        // Confirmar
        AppTextField(
          label: 'Confirmar Contraseña*',
          hint: 'Repítela',
          controller: _confirmCtrl,
          icon: Icons.lock_outline,
          obscureText: _obscureConfirm,
          suffixIcon: IconButton(
            tooltip: _obscureConfirm ? 'Mostrar' : 'Ocultar',
            icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          textInputAction: TextInputAction.done,
        ),
        const FormGap(),

        // Acepto
        Row(
          children: [
            Checkbox(
              value: _acepto,
              onChanged: (v) => setState(() => _acepto = v ?? false),
            ),
            const Expanded(child: Text('Acepto Términos y Políticas de Privacidad.')),
          ],
        ),

        // Ver términos
        Center(
          child: TextButton(
            onPressed: () async {
              final accepted = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const TermsPage()),
              );
              if (accepted == true) setState(() => _acepto = true);
            },
            child: const Text('Ver términos.'),
          ),
        ),
        const FormGap(),

        // reCAPTCHA placeholder
        Container(
          width: double.infinity,
          height: 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('reCAPTCHA'),
        ),
        const SizedBox(height: 16),

        // Continuar
        Center(
          child: SizedBox(
            width: 220,
            height: 44,
            child: FilledButton(onPressed: _continuar, child: const Text('Continuar')),
          ),
        ),
        const SizedBox(height: 16),

        // SSO
        const Text('O inicia sesión con una de las siguientes cuentas'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SsoIconButton(
              icon: FontAwesomeIcons.google,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google sign-in (pronto)')),
              ),
            ),
            const SizedBox(width: 16),
            SsoIconButton(
              icon: FontAwesomeIcons.microsoft,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Microsoft sign-in (pronto)')),
              ),
            ),
            const SizedBox(width: 16),
            SsoIconButton(
              icon: FontAwesomeIcons.apple,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Apple sign-in (pronto)')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
