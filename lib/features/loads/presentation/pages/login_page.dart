import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Aquí irá tu formulario de login.\n(placeholder temporal)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
