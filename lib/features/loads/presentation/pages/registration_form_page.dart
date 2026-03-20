// lib/features/loads/presentation/pages/registration_form_page.dart
import 'dart:math' as math;



import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Reusables
import 'package:conexion_carga_app/app/widgets/inputs/app_text_field.dart';
import 'package:conexion_carga_app/app/widgets/sso_icon_button.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/terms_page.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

// Controlador de registro + modelo de respuesta
import 'package:conexion_carga_app/features/auth/presentation/registration_controller.dart';
import 'package:conexion_carga_app/features/auth/data/models/user_out.dart';

// API de verificación y pantalla de verificación
import 'package:conexion_carga_app/features/auth/data/verification_api.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/verify_code_page.dart';

// ✅ IMPORTANTE: “puente” por plataforma para evitar que Chrome se congele.
// - En WEB/DEBUG devuelve placeholder y NO abre WebView.
// - En ANDROID RELEASE abre un BottomSheet con WebView para el reCAPTCHA real.
import 'package:conexion_carga_app/features/auth/presentation/recaptcha/recaptcha_platform.dart'
    as recaptcha;



/// ---------------- Ocupación ----------------
class OccupationOption {
  final String id;
  final String label;
  final bool requiresCompany;
  final bool isDriver;

  const OccupationOption({
    required this.id,
    required this.label,
    required this.requiresCompany,
    this.isDriver = false,
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
  OccupationOption(
    id: 'driver',
    label: 'Soy conductor',
    requiresCompany: false,
    isDriver: true,
  ),
];

/// ---------------- Tipo de documento (Colombia) ----------------
class DocTypeOption {
  final String id; // 'CC', 'CE', 'NIT', 'PA', 'TI', 'PPT'
  final String label;
  const DocTypeOption(this.id, this.label);
}

const kDocTypes = <DocTypeOption>[
  DocTypeOption('CC', 'Cédula de ciudadanía'),
  DocTypeOption('CE', 'Cédula de extranjería'),
  DocTypeOption('NIT', 'NIT'),
  DocTypeOption('PA', 'Pasaporte'),
  DocTypeOption('TI', 'Tarjeta de identidad'),
  DocTypeOption('PPT', 'Permiso por Protección Temporal (PPT)'),
];

class RegistrationFormPage extends StatefulWidget {
  final String? initialReferrerEmail;

  const RegistrationFormPage({
    super.key,
    this.initialReferrerEmail,
  });

  @override
  State<RegistrationFormPage> createState() => _RegistrationFormPageState();
}

class _RegistrationFormPageState extends State<RegistrationFormPage> {
  static const bool _enableRecaptchaDefine =
      bool.fromEnvironment('ENABLE_RECAPTCHA', defaultValue: false);

  static const String _recaptchaSiteKey =
      String.fromEnvironment('RECAPTCHA_SITE_KEY', defaultValue: '');

  bool get _shouldUseRealRecaptcha {
    if (kIsWeb) return false;
    if (kDebugMode) return false;
    if (!_enableRecaptchaDefine) return false;
    if (_recaptchaSiteKey.trim().isEmpty) return false;
    return true;
  }

  final _controller = RegistrationController();
  final _verificationApi = const VerificationApi();

  OccupationOption? _selectedOccupation;
  final _companyCtrl = TextEditingController();

  DocTypeOption? _selectedDocType;

  final _emailCtrl = TextEditingController();
  final _numIdCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _referrerEmailCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acepto = false;
  bool _isLoading = false;

  String? _captchaToken;

  bool _didApplyInitialReferrer = false;

  bool get _needsCompany =>
      _selectedOccupation != null && _selectedOccupation!.requiresCompany;

  bool _isStrongPassword(String value) {
    final hasMinLength = value.length >= 8;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);
    final hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(value);
    return hasMinLength && hasLetter && hasNumber && hasSymbol;
  }

  void _applyInitialReferrer(String? rawValue) {
    if (_didApplyInitialReferrer) return;

    final value = (rawValue ?? '').trim();
    if (value.isEmpty) return;

    _referrerEmailCtrl.text = value;
    _didApplyInitialReferrer = true;
  }

  @override
  void initState() {
    super.initState();
    _applyInitialReferrer(widget.initialReferrerEmail);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didApplyInitialReferrer) return;

    final routeName = ModalRoute.of(context)?.settings.name ?? '';
    final routeUri = Uri.tryParse(routeName);
    final refFromRoute = routeUri?.queryParameters['ref'];

    _applyInitialReferrer(refFromRoute);
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _numIdCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _referrerEmailCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------
  // 5) Acción: abrir reCAPTCHA (solo release)
  // ---------------------------------------
  Future<void> _verifyRecaptcha() async {
    if (!_shouldUseRealRecaptcha) return;

    // ✅ Abrimos BottomSheet (sin teclado, sin overflow)
    // ✅ En web/debug esto no se ejecuta.
    try {
     final token = await recaptcha.openRecaptcha(
      context: context,
      siteKey: _recaptchaSiteKey,
    );


      if (!mounted) return;

      if (token == null || token.trim().isEmpty) {
        // usuario canceló o falló
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se completó el reCAPTCHA.')),
        );
        return;
      }

      setState(() => _captchaToken = token.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ reCAPTCHA verificado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reCAPTCHA: $e')),
      );
    }
  }

  // ------------------------
  // 6) Continuar / Registrar
  // ------------------------
  Future<void> _continuar() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    // 1) Validar email
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo electrónico.')),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo electrónico válido.')),
      );
      return;
    }

    // 2) Validar documento
    if (_selectedDocType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el tipo de identificación.')),
      );
      return;
    }

    if ((_numIdCtrl.text.trim()).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu número de identificación.')),
      );
      return;
    }

    // 3) Validar términos
    if (!_acepto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos.')),
      );
      return;
    }

    // 4) Validar contraseña
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (!_isStrongPassword(pass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener mínimo 8 caracteres, '
            'incluir letras, números y al menos un símbolo.',
          ),
        ),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    // 5) ✅ Si es RELEASE + reCAPTCHA real activo, exigimos token antes de registrar
    if (_shouldUseRealRecaptcha && (_captchaToken == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el reCAPTCHA antes de continuar.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isCompany = _selectedOccupation?.requiresCompany == true;
      final isDriver = _selectedOccupation?.isDriver == true;

      // ✅ Si quieres que el backend valide el captcha:
      // Debes enviar _captchaToken en el body del registro.
      // (Esto requiere ajustar UserApi/Backend; lo explico en la guía.)
      final UserOut user = await _controller.submit(
        context: context,
        email: email,
        firstName: _nombresCtrl.text.trim(),
        lastName: _apellidosCtrl.text.trim(),
        phone: _numIdCtrl.text.trim(),
        isCompany: isCompany,
        isDriver: isDriver,
        companyName: _companyCtrl.text.trim(),
        password: pass,
        confirmPassword: confirm,
        acceptedTerms: _acepto,
        referrerEmail: _referrerEmailCtrl.text.trim().isEmpty
            ? null
            : _referrerEmailCtrl.text.trim(),
        // 👇 Si agregas captcha al submit, iría aquí:
        // recaptchaToken: _captchaToken,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyCodePage(
            email: user.email,
            displayName: user.firstName,
            password: pass,
          ),
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');

      // Caso: ya existe el usuario -> reenviar código y llevar a verify
      if (msg.toLowerCase().contains('correo ya registrado') ||
          msg.toLowerCase().contains('el usuario ya se encuentra registrado')) {
        try {
          await _verificationApi.requestEmailCode(email);
        } catch (_) {}

        if (!mounted) return;

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerifyCodePage(
              email: email,
              displayName: _nombresCtrl.text.trim(),
              password: _passCtrl.text,
            ),
          ),
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------------
  // 7) UI: “bloque reCAPTCHA”
  // ------------------------
  Widget _buildRecaptchaBlock(BuildContext context) {
    final border = Border.all(color: Theme.of(context).dividerColor);
    final radius = BorderRadius.circular(10);

    // ✅ WEB/DEBUG: placeholder, nunca rompe Chrome.
    if (!_shouldUseRealRecaptcha) {
      return Container(
        width: double.infinity,
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: const Text('reCAPTCHA'),
      );
    }

    // ✅ RELEASE Android: muestra estado + botón para abrir BottomSheet.
    final verified = (_captchaToken != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: border, borderRadius: radius),
      child: Row(
        children: [
          Icon(
            verified ? Icons.verified : Icons.shield_outlined,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              verified ? 'reCAPTCHA verificado' : 'Verifica que no eres un robot',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _verifyRecaptcha,
              child: Text(verified ? 'Re-verificar' : 'Verificar'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final headerColor = isLight
        ? kBrandGreen.withOpacity(0.35)
        : kDeepDarkGreen.withOpacity(0.7);

    // ✅ Clave anti-overflow con teclado:
    // padding inferior dinámico: viewInsets.bottom + margen
    final bottomPad = math.max(24.0, MediaQuery.of(context).viewInsets.bottom + 24.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Registrarme'),
        actions: const [ThemeToggle(size: 22), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
          child: Column(
            children: [
              // ── Bloque superior: Ocupación + Empresa ─────────────────────────
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

                    Text(
                      'Ocupación:',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.onSurface.withOpacity(0.75),
                          ),
                    ),
                    const SizedBox(height: 6),

                    DropdownButtonFormField<OccupationOption>(
                      initialValue: _selectedOccupation,
                      decoration: InputDecoration(
                        hintText: '¿A qué te dedicas?',
                        prefixIcon: const Icon(Icons.work_outline),
                        filled: true,
                        fillColor:
                            isLight ? Colors.white : cs.surface.withOpacity(0.95),
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
                          .map((o) => DropdownMenuItem(
                                value: o,
                                child: Text(o.label),
                              ))
                          .toList(),
                      onChanged: (o) {
                        setState(() {
                          _selectedOccupation = o;
                          if (!_needsCompany) {
                            _companyCtrl.clear();
                            FocusScope.of(context).unfocus();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Nombre de la empresa:',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.onSurface.withOpacity(0.75),
                          ),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: _companyCtrl,
                      enabled: _needsCompany,
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

              // ── Formulario principal ─────────────────────────────────────────
              AppTextField(
                label: 'Correo Electrónico*',
                hint: 'tucorreo@dominio.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tipo de identificación*',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.onSurface.withOpacity(0.75),
                      ),
                ),
              ),
              const SizedBox(height: 6),

              DropdownButtonFormField<DocTypeOption>(
                initialValue: _selectedDocType,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: isLight ? Colors.white : cs.surface.withOpacity(0.95),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                hint: const Text(
                  'Seleccione el tipo de documento',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                icon: const Icon(Icons.arrow_drop_down),
                items: kDocTypes
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(
                            d.label,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDocType = v),
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Número de identificación*',
                hint: 'Tu número de documento',
                controller: _numIdCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.confirmation_number_outlined,
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Nombres*',
                hint: 'Nombres',
                controller: _nombresCtrl,
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Apellidos*',
                hint: 'Apellidos',
                controller: _apellidosCtrl,
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
              ),
              const SizedBox(height: 12),

              AppTextField(
                label:
                    'Contraseña de mínimo 8 caracteres, letras, números y un símbolo*',
                hint: 'Ej: Clave123!',
                controller: _passCtrl,
                icon: Icons.lock_outline,
                obscureText: _obscurePass,
                suffixIcon: IconButton(
                  tooltip: _obscurePass ? 'Mostrar' : 'Ocultar',
                  icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
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
                  icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: const [],
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Referido por',
                hint: 'Correo del usuario que te refirió (opcional)',
                controller: _referrerEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.alternate_email_outlined,
                textInputAction: TextInputAction.next,
                inputFormatters: const [],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Checkbox(
                    value: _acepto,
                    onChanged: (v) => setState(() => _acepto = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Al registrarte, aceptas nuestros Términos y Condiciones de Uso y la Política de Privacidad',
                    ),
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

              // ✅ reCAPTCHA (placeholder en web/debug, real en release android)
              _buildRecaptchaBlock(context),
              const SizedBox(height: 16),

              Center(
                child: SizedBox(
                  width: 220,
                  height: 44,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _continuar,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continuar'),
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
      ),
    );
  }
}
