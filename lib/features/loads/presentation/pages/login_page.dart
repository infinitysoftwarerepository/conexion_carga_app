import 'package:flutter/material.dart';

// 🎨 Paleta propia
import 'package:bolsa_carga_app/app/theme/theme_conection.dart';

// 🌗 Toggle de tema
import 'package:bolsa_carga_app/features/loads/presentation/widgets/theme_toggle.dart';

// 🏠 Pantalla de destino cuando el login “pasa”
import 'package:bolsa_carga_app/features/loads/presentation/pages/home_page.dart';

/// Login UI minimalista, listo para conectar backend.
/// - Email + Password con validación en vivo de forma, sin bloquear el flujo.
/// - Botón “Enviar” habilitado si los dos campos son válidos.
/// - Gradiente verde (dark/ligth) en el panel.
/// - Lunita en AppBar para cambiar tema.
/// IMPORTANTE: Aquí NO se hace autenticación real.
///             Conectar backend dentro de `_trySubmit()` cuando corresponda.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  // Mostrar/ocultar password
  bool _showPass = false;

  // Regex “popular” para forma de email a nivel de UI (rápida y suficiente).
  // Acepta cualquier usuario + @ + dominio + TLD (no fuerza .com para ser realista).
  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  // Flags derivados (se recalculan en build vía getters)
  bool get _emailOk => _emailRe.hasMatch(_emailCtrl.text.trim());
  bool get _passOk  => _passCtrl.text.trim().length >= 3;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Punto único para conectar el backend más adelante.
  /// - Aquí harás la llamada a tu API, manejo de tokens, errores, etc.
  /// - Si la API responde OK, navegas a Home.
  Future<void> _trySubmit() async {
    if (!_emailOk || !_passOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa usuario y contraseña.')),
      );
      return;
    }

    // TODO(backend): reemplazar este bloque por la llamada real (await auth.login(...))
    // Simulación de éxito inmediato:
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(userName: 'Deibizon Londoño'),
      ),
    );
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
        : LinearGradient(
            colors: [kDeepDarkGreen, const Color(0xFF0D1F0F)],
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
              child: Container(
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
                      onChanged: (_) => setState(() {}), // re-renderiza para error en vivo
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.alternate_email),
                        hintText: 'tucorreo@dominio.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                            _showPass ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() {
                            _showPass = !_showPass;
                          }),
                        ),
                        hintText: ' escriba su contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                        onPressed: _trySubmit,
                        child: const Text(
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
            ),
          ),
        ),
      ),
    );
  }
}
