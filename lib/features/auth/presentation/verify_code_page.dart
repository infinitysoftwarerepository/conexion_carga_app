// lib/features/auth/presentation/verify_code_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:conexion_carga_app/features/auth/data/verification_api.dart';

/// Pantalla para ingresar el código de verificación enviado por email.
/// Muestra: correo, input de 6 dígitos, botón verificar y reenviar con cooldown.
class VerifyCodePage extends StatefulWidget {
  final String email;        // correo que acabas de registrar
  final String? displayName; // opcional: para saludar por nombre

  const VerifyCodePage({super.key, required this.email, this.displayName});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _api = const VerificationApi();
  final _codeCtrl = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  // Cooldown para “Reenviar código”
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Arranca el cooldown inicial (asumiendo que ya se envió en el registro)
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _startCooldown({int seconds = 30}) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _verify() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un código de 6 dígitos.')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      await _api.verifyEmailCode(email: widget.email, code: code);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Correo verificado con éxito!')),
      );

      // Aquí decides a dónde ir: login o home
      Navigator.of(context).pop(true); // o pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    setState(() => _isResending = true);
    try {
      await _api.requestEmailCode(widget.email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nuevo código enviado a ${widget.email}')),
      );
      _startCooldown(seconds: 45); // próximo cooldown
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Verifica tu correo')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola${widget.displayName != null ? ", ${widget.displayName}" : ""} 👋',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Te enviamos un código de verificación a:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mail_outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.email,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text('Código de 6 dígitos', style: Theme.of(context).textTheme.labelLarge),
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

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: _isVerifying ? null : _verify,
                    child: _isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verificar'),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Text(
                      _secondsLeft == 0
                          ? '¿No recibiste el código?'
                          : 'Podrás reenviar en $_secondsLeft s',
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: (_secondsLeft == 0 && !_isResending) ? _resend : null,
                      icon: const Icon(Icons.refresh),
                      label: _isResending
                          ? const Text('Enviando...')
                          : const Text('Reenviar código'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
