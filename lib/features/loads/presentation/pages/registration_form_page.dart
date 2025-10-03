// lib/features/loads/presentation/pages/registration_form_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Reusables (ajusta rutas si tus paths difieren)
import 'package:conexion_carga_app/app/widgets/inputs/app_text_field.dart';
import 'package:conexion_carga_app/app/widgets/sso_icon_button.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/terms_page.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

/// --- Modelo simple para la Ocupación (para poder crecer luego) ---
class OccupationOption {
  final String id;
  final String label;
  final bool requiresCompany;
  const OccupationOption({
    required this.id,
    required this.label,
    required this.requiresCompany,
  });
}

const kOccupationOptions = <OccupationOption>[
  OccupationOption(
    id: 'employee',
    label: 'Trabajo para una empresa',
    requiresCompany: true,
  ),
  OccupationOption(
    id: 'independent',
    label: 'Soy independiente',
    requiresCompany: false,
  ),
  // Agrega más opciones aquí cuando quieras
];

class RegistrationFormPage extends StatefulWidget {
  const RegistrationFormPage({super.key});
  @override
  State<RegistrationFormPage> createState() => _RegistrationFormPageState();
}

class _RegistrationFormPageState extends State<RegistrationFormPage> {
  // ── Estado de los 2 campos superiores ───────────────────────────────────────
  OccupationOption? _selectedOccupation; // ⬅️ SIN valor inicial → muestra hint
  final _companyCtrl = TextEditingController();

  bool get _needsCompany =>
      _selectedOccupation != null && _selectedOccupation!.requiresCompany;

  // ── Resto de campos del formulario ─────────────────────────────────────────
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
    _companyCtrl.dispose();
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
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Fondo de “bloque destacado” para los 2 campos de arriba.
    final headerColor = isLight
        ? kBrandGreen.withOpacity(0.35)
        : kDeepDarkGreen.withOpacity(0.7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarme'),
        actions: const [ThemeToggle(size: 22), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────────────
            // 1) BLOQUE SUPERIOR: Ocupación + Empresa
            //    • Etiquetas por fuera (encima del cajón)
            //    • Empresa desactivada hasta elegir “Trabajo para una empresa”
            // ─────────────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Primero cuéntanos sobre tu ocupación',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // ---------- Etiqueta fuera del campo (no flotante) ----------
                  Text(
                    'Ocupación:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: cs.onSurface.withOpacity(0.75),
                        ),
                  ),
                  const SizedBox(height: 6),

                  // ---------- Dropdown Ocupación (sin valor inicial) ----------
                  DropdownButtonFormField<OccupationOption>(
                    value: _selectedOccupation, // null → muestra hint
                    decoration: InputDecoration(
                      hintText: '¿A qué te dedicas?', // ⬅️ como pediste
                      prefixIcon: const Icon(Icons.work_outline),
                      filled: true,
                      fillColor: isLight
                          ? Colors.white
                          : cs.surface.withOpacity(0.95),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: kOccupationOptions
                        .map(
                          (o) => DropdownMenuItem(
                            value: o,
                            child: Text(o.label),
                          ),
                        )
                        .toList(),
                    onChanged: (o) {
                      setState(() {
                        _selectedOccupation = o;
                        // Si NO requiere empresa, limpiar y asegurar bloqueado:
                        if (!_needsCompany) {
                          _companyCtrl.clear();
                          // quitar foco por si estaba activo
                          FocusScope.of(context).unfocus();
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // ---------- Etiqueta empresa (por fuera) ----------
                  Text(
                    'Nombre de la empresa:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: cs.onSurface.withOpacity(0.75),
                        ),
                  ),
                  const SizedBox(height: 6),

                  // ---------- TextField Empresa (totalmente desactivado) ----------
                  TextField(
                    controller: _companyCtrl,
                    enabled:
                        _needsCompany, // false → no se puede escribir ni enfocar
                    decoration: InputDecoration(
                      hintText: '¿En qué empresa trabajas?',
                      prefixIcon: const Icon(Icons.apartment_outlined),
                      filled: true,
                      fillColor: _needsCompany
                          ? (isLight ? Colors.white : cs.surface)
                          : (isLight
                              ? Colors.white.withOpacity(0.55)
                              : cs.surface.withOpacity(0.55)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─────────────────────────────────────────────────────────────────
            // 2) FORMULARIO PRINCIPAL (sin cambios de fondo)
            // ─────────────────────────────────────────────────────────────────
            AppTextField(
              label: 'Correo Electrónico*',
              hint: 'tucorreo@dominio.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: 'Tipo de identificación*',
              hint: 'Cédula de ciudadanía, NIT, etc.',
              controller: _tipoIdCtrl,
              icon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: 'Número de identificación*',
              hint: 'Tu número de documento',
              controller: _numIdCtrl,
              keyboardType: TextInputType.number,
              icon: Icons.confirmation_number_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: 'Nombres*',
              hint: 'Nombres',
              controller: _nombresCtrl,
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: 'Apellidos*',
              hint: 'Apellidos',
              controller: _apellidosCtrl,
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

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
            const SizedBox(height: 12),

            AppTextField(
              label: 'Confirmar Contraseña*',
              hint: 'Repítela',
              controller: _confirmCtrl,
              icon: Icons.lock_outline,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                tooltip: _obscureConfirm ? 'Mostrar' : 'Ocultar',
                icon:
                    Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),

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
            const SizedBox(height: 12),

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
          ],
        ),
      ),
    );
  }
}
