// lib/features/loads/presentation/pages/signin_page.dart
import 'package:flutter/material.dart';

// Inputs reutilizables (sin validator por ahora)
import 'package:bolsa_carga_app/core/widgets/inputs/app_text_field.dart';

// 🌗 Lunita (toggle claro/oscuro)
import 'package:bolsa_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

// Botón SSO reutilizable
import 'package:bolsa_carga_app/features/loads/presentation/widgets/sso_icon_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ⬇️ importa tu página de términos
import 'package:bolsa_carga_app/features/loads/presentation/pages/terms_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Controllers
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro enviado (diseño listo).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const spacing = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarme'),
        centerTitle: true,
        actions: [
          ThemeToggle(color: theme.colorScheme.onSurface, size: 22),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
              const SizedBox(height: spacing),

              // Tipo de identificación
              AppTextField(
                label: 'Tipo de identificación*',
                hint: 'Cédula de ciudadanía, NIT, etc.',
                controller: _tipoIdCtrl,
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: spacing),

              // Número de identificación
              AppTextField(
                label: 'Número de identificación*',
                hint: 'Tu número de documento',
                controller: _numIdCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.confirmation_number_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: spacing),

              // Nombres
              AppTextField(
                label: 'Nombres*',
                hint: 'Nombres',
                controller: _nombresCtrl,
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: spacing),

              // Apellidos
              AppTextField(
                label: 'Apellidos*',
                hint: 'Apellidos',
                controller: _apellidosCtrl,
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: spacing),

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
              const SizedBox(height: spacing),

              // Confirmar contraseña
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
              const SizedBox(height: spacing),

              // Acepto términos
              Row(
                children: [
                  Checkbox(
                    value: _acepto,
                    onChanged: (v) => setState(() => _acepto = v ?? false),
                  ),
                  const Expanded(
                    child: Text('Acepto Términos y Políticas de Privacidad.'),
                  ),
                ],
              ),

              // Ver términos — centrado
              Center(
                child: TextButton(
                  onPressed: () async {
                    // ⬇️ Navega a TermsPage y espera el resultado (true si aceptó)
                    final accepted = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => const TermsPage()),
                    );
                    if (accepted == true) {
                      setState(() => _acepto = true);
                    }
                  },
                  child: const Text('Ver términos.'),
                ),
              ),
              const SizedBox(height: spacing),

              // "reCAPTCHA" placeholder — un poco más alto
              Container(
                width: double.infinity,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('reCAPTCHA'),
              ),
              const SizedBox(height: 16),

              // Botón Continuar — compacto y centrado
              Center(
                child: SizedBox(
                  width: 220,
                  height: 44,
                  child: FilledButton(
                    onPressed: _continuar,
                    child: const Text('Continuar'),
                  ),
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
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Google sign-in (pronto)')),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  SsoIconButton(
                    icon: FontAwesomeIcons.microsoft,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Microsoft sign-in (pronto)')),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  SsoIconButton(
                    icon: FontAwesomeIcons.apple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Apple sign-in (pronto)')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
