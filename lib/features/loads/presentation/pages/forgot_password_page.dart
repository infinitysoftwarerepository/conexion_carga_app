// lib/features/loads/presentation/pages/forgot_password_page.dart
import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/features/auth/data/verification_api.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/login_page.dart';
import 'package:conexion_carga_app/features/auth/data/auth_api.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/start/start_page.dart';


class ForgotPasswordPage extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _api = const VerificationApi();

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  int _step = 1; // 1 = pedir código, 2 = cambiar contraseña

  bool _sending = false;
  bool _changing = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isStrongPassword(String value) {
    final hasMinLength = value.length >= 8;
    final hasLetter    = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasNumber    = RegExp(r'\d').hasMatch(value);
    final hasSymbol    = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(value);

    return hasMinLength && hasLetter && hasNumber && hasSymbol;
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo electrónico.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      // 👉 Nuevo método en VerificationApi (abajo te lo pongo)
      await _api.requestPasswordReset(email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te enviamos un código a $email')),
      );
      setState(() => _step = 2);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _changePassword() async {
    final email   = _emailCtrl.text.trim();
    final code    = _codeCtrl.text.trim();
    final pass    = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (code.length != 6 || int.tryParse(code) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un código de 6 dígitos.')),
      );
      return;
    }

    if (!_isStrongPassword(pass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener mínimo 8 caracteres, '
            'letras, números y al menos un símbolo.',
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

    setState(() => _changing = true);
    try {
      // 👉 Nuevo método en VerificationApi (abajo te lo pongo)
      await _api.resetPassword(
        email: email,
        code: code,
        newPassword: pass,
      );

      if (!mounted) return;

      
      try {
      await const AuthApi().login(email: email, password: pass);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Contraseña actualizada. ¡Bienvenido!')),
      );

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StartPage()),
        (route) => false,
      );
    } catch (e) {
      // si por alguna razón no deja loguear, lo mandas a login como antes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada. Ahora inicia sesión.')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        actions: const [ThemeToggle(size: 22), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            24 + MediaQuery.viewInsetsOf(context).bottom, // 👈 suma teclado
          ),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Olvidaste tu contraseña?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Primero envíanos tu correo y te mandaremos un código para que puedas crear una nueva contraseña.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_step == 1) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          onPressed: _sending ? null : _sendCode,
                          child: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Enviar código'),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Código de verificación',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _codeCtrl,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '••••••',
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Nueva contraseña de mínimo 8 caracteres, letras (mayúsculas o minúsculas), números y un símbolo',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu nueva contraseña',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'Confirma tu nueva contraseña',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          onPressed: _changing ? null : _changePassword,
                          child: _changing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Cambiar contraseña'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
