import 'package:flutter/material.dart';

// 🎨 Paleta propia
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

// 🌗 Toggle de tema
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

// Botón SSO reutilizable (iconitos debajo)
import 'package:conexion_carga_app/app/widgets/sso_icon_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// 🔐 Llamadas al backend (login)
import 'package:conexion_carga_app/features/auth/data/auth_api.dart';

/// Pantalla de inicio de sesión:
/// - Email + Password con validación de forma.
/// - Llama a AuthApi.login() y, si es OK, cierra la pantalla con `Navigator.pop(true)`.
/// - StartPage escucha la sesión y mostrará "Bienvenido, {nombre}" automáticamente.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // Mostrar/ocultar password
  bool _showPass = false;

  // Flag de envío para deshabilitar botón y mostrar spinner
  bool _isSubmitting = false;

  // Regex popular para forma de email
  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  // Validaciones rápidas de UI
  bool get _emailOk => _emailRe.hasMatch(_emailCtrl.text.trim());
  bool get _passOk => _passCtrl.text.trim().length >= 3;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Llama al backend. Si responde OK:
  /// - Guarda sesión (AuthApi ya guarda en AuthSession)
  /// - Cierra esta página devolviendo `true`
  Future<void> _trySubmit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty || !_emailOk || !_passOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa usuario y contraseña.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final api = const AuthApi(); // usa Env.baseUrl internamente
      final user = await api.login(email: email, password: pass);

      if (!mounted) return;
      // Vuelve a StartPage; allí el ValueListenable mostrará "Bienvenido, {nombre}".
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido ${user.firstName}!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Gradiente del “cajón” de login
    final Gradient panelGradient = isLight
        ? LinearGradient(
            colors: [kGreenStrong, kGreenStrong.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [kDeepDarkGreen, Color(0xFF0D1F0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        centerTitle: true,
        actions: [
          ThemeToggle(color: cs.onSurface, size: 22),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== CAJÓN LOGIN =====
                  Container(
                    decoration: BoxDecoration(
                      gradient: panelGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isLight ? 0.08 : 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== USUARIO (email)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'USUARIO:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.alternate_email),
                            hintText: 'tucorreo@dominio.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: _emailCtrl.text.isNotEmpty && !_emailOk
                              ? Padding(
                                  key: const ValueKey('mail_error'),
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'Usuario inválido',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('mail_ok')),
                        ),

                        const SizedBox(height: 18),

                        // ===== CONTRASEÑA
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'CONTRASEÑA:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passCtrl,
                          obscureText: !_showPass,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _trySubmit(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _showPass ? 'Ocultar' : 'Mostrar',
                              icon: Icon(
                                _showPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => _showPass = !_showPass),
                            ),
                            hintText: ' escriba su contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: _passCtrl.text.isNotEmpty && !_passOk
                              ? Padding(
                                  key: const ValueKey('pass_error'),
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'Contraseña inválida',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('pass_ok')),
                        ),

                        const SizedBox(height: 22),

                        // ===== ENVIAR
                        SizedBox(
                          width: 160,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _isSubmitting ? null : _trySubmit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'Enviar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== SSO debajo del cajón =====
                  const Text(
                      'O inicia sesión con una de las siguientes cuentas'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SsoIconButton(icon: FontAwesomeIcons.google),
                      SizedBox(width: 16),
                      SsoIconButton(icon: FontAwesomeIcons.microsoft),
                      SizedBox(width: 16),
                      SsoIconButton(icon: FontAwesomeIcons.apple),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
