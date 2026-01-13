import 'package:conexion_carga_app/app/widgets/role_option_title.dart';
import 'package:flutter/material.dart';
import 'package:conexion_carga_app/features/loads/domain/user_role.dart';

import 'package:conexion_carga_app/features/loads/presentation/pages/registration_form_page.dart';
// 🌙 Toggle reutilizable
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  List<UserRole> get _roles => const [
        UserRole.comercial,
        UserRole.conductor,
        UserRole.empresa,
        UserRole.propietario,
      ];

  void _goToForm(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RegistrationFormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
      title: const Text(
        'Elige un perfil de registro',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 20,                 // 👈 tamaño
          fontWeight: FontWeight.w800,  // 👈 negrita
          letterSpacing: 0.2,
        ),
      ),
      centerTitle: true,
      actions: const [ThemeToggle(size: 22), SizedBox(width: 8)],
    ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selecciona tu rol para personalizar tu experiencia.',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),

              // Aviso en cajita → usa secondaryContainer (verde de marca)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Podrás cambiar o ampliar tu rol más adelante desde tu perfil.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSecondaryContainer,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.separated(
                  itemCount: _roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final role = _roles[i];
                    return RoleOptionTile(
                      icon: role.icon,
                      title: role.title,
                      subtitle: role.subtitle,
                      onTap: () => _goToForm(context, role),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
