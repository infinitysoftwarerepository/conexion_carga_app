import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:conexion_carga_app/app/theme/theme_conection.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/features/auth/data/profile_api.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/login_page.dart';

class CountryPhoneOption {
  final String iso2;
  final String label;
  final String phoneCode;
  final String flag;

  const CountryPhoneOption({
    required this.iso2,
    required this.label,
    required this.phoneCode,
    required this.flag,
  });
}

const kProfileCountryPhoneOptions = <CountryPhoneOption>[
  CountryPhoneOption(iso2: 'CO', label: 'Colombia', phoneCode: '+57', flag: '🇨🇴'),
  CountryPhoneOption(iso2: 'MX', label: 'México', phoneCode: '+52', flag: '🇲🇽'),
  CountryPhoneOption(iso2: 'AR', label: 'Argentina', phoneCode: '+54', flag: '🇦🇷'),
  CountryPhoneOption(iso2: 'CL', label: 'Chile', phoneCode: '+56', flag: '🇨🇱'),
  CountryPhoneOption(iso2: 'PE', label: 'Perú', phoneCode: '+51', flag: '🇵🇪'),
  CountryPhoneOption(iso2: 'EC', label: 'Ecuador', phoneCode: '+593', flag: '🇪🇨'),
  CountryPhoneOption(iso2: 'VE', label: 'Venezuela', phoneCode: '+58', flag: '🇻🇪'),
  CountryPhoneOption(iso2: 'BO', label: 'Bolivia', phoneCode: '+591', flag: '🇧🇴'),
  CountryPhoneOption(iso2: 'PY', label: 'Paraguay', phoneCode: '+595', flag: '🇵🇾'),
  CountryPhoneOption(iso2: 'UY', label: 'Uruguay', phoneCode: '+598', flag: '🇺🇾'),
  CountryPhoneOption(iso2: 'BR', label: 'Brasil', phoneCode: '+55', flag: '🇧🇷'),
  CountryPhoneOption(iso2: 'PA', label: 'Panamá', phoneCode: '+507', flag: '🇵🇦'),
  CountryPhoneOption(iso2: 'CR', label: 'Costa Rica', phoneCode: '+506', flag: '🇨🇷'),
  CountryPhoneOption(iso2: 'GT', label: 'Guatemala', phoneCode: '+502', flag: '🇬🇹'),
  CountryPhoneOption(iso2: 'SV', label: 'El Salvador', phoneCode: '+503', flag: '🇸🇻'),
  CountryPhoneOption(iso2: 'HN', label: 'Honduras', phoneCode: '+504', flag: '🇭🇳'),
  CountryPhoneOption(iso2: 'NI', label: 'Nicaragua', phoneCode: '+505', flag: '🇳🇮'),
  CountryPhoneOption(iso2: 'US', label: 'Estados Unidos', phoneCode: '+1', flag: '🇺🇸'),
  CountryPhoneOption(iso2: 'DO', label: 'República Dominicana', phoneCode: '+1', flag: '🇩🇴'),
  CountryPhoneOption(iso2: 'ES', label: 'España', phoneCode: '+34', flag: '🇪🇸'),
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _api = const ProfileApi();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _documentCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();

  CountryPhoneOption _selectedCountry = kProfileCountryPhoneOptions.first;
  bool _isCompany = false;
  bool _isDriver = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fillFromSession();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _documentCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  void _fillFromSession() {
    final user = AuthSession.instance.user.value;
    if (user == null) return;

    _emailCtrl.text = user.email;
    _firstNameCtrl.text = user.firstName;
    _lastNameCtrl.text = user.lastName;
    _documentCtrl.text = user.document;
    _isCompany = user.isCompany;
    _isDriver = user.isDriver;
    _companyCtrl.text = user.companyName;
    _setPhone(user.phone);
  }

  void _setPhone(String rawPhone) {
    final phone = rawPhone.trim();
    if (phone.isEmpty || !phone.startsWith('+')) {
      _selectedCountry = kProfileCountryPhoneOptions.first;
      _phoneCtrl.text = phone.replaceAll(RegExp(r'\D+'), '');
      return;
    }

    final countries = [...kProfileCountryPhoneOptions]
      ..sort((a, b) => b.phoneCode.length.compareTo(a.phoneCode.length));
    final country = countries.firstWhere(
      (item) => phone.startsWith(item.phoneCode),
      orElse: () => kProfileCountryPhoneOptions.first,
    );

    _selectedCountry = country;
    _phoneCtrl.text = phone.substring(country.phoneCode.length).replaceAll(
          RegExp(r'\D+'),
          '',
        );
  }

  Future<void> _saveProfile() async {
    if (_saving) return;

    final email = _emailCtrl.text.trim();
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final document = _documentCtrl.text.trim();
    final phoneNumber = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D+'), '');

    if (email.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _showMessage('Completa nombre, apellido y correo.');
      return;
    }

    if (document.isEmpty) {
      _showMessage('Ingresa tu identificación.');
      return;
    }

    if (!RegExp(r'^\d{6,15}$').hasMatch(phoneNumber)) {
      _showMessage('Ingresa un número WhatsApp válido.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _api.updateMe(
        email: email,
        firstName: firstName,
        lastName: lastName,
        document: document,
        phoneCode: _selectedCountry.phoneCode,
        phoneNumber: phoneNumber,
        isCompany: _isCompany,
        isDriver: _isDriver,
        companyName: _companyCtrl.text.trim(),
      );

      if (!mounted) return;
      _showMessage('Cambios guardados.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openDeleteDialog() async {
    final reasonCtrl = TextEditingController();
    var sending = false;
    String? errorText;

    await showDialog<void>(
      context: context,
      barrierDismissible: !sending,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final reason = reasonCtrl.text.trim();
            final canSend = reason.length >= 10 && !sending;

            Future<void> confirmDeletion() async {
              if (!canSend) {
                setDialogState(() {
                  errorText = 'El motivo debe tener al menos 10 caracteres.';
                });
                return;
              }

              final user = AuthSession.instance.user.value;
              if (user == null) return;

              setDialogState(() {
                sending = true;
                errorText = null;
              });

              try {
                await _api.requestAccountDeletion(
                  userId: user.id,
                  email: user.email,
                  motivo: reason,
                );

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }

                await AuthSession.instance.signOut();
                if (!mounted) return;

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tu solicitud fue enviada correctamente. Tu cuenta ha sido desactivada.',
                    ),
                  ),
                );
                navigator.popUntil((route) => route.isFirst);
                await navigator.push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              } catch (error) {
                setDialogState(() {
                  sending = false;
                  errorText = error.toString().replaceFirst('Exception: ', '');
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text('¿Desea solicitar la eliminación de la cuenta?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Esta acción desactivará su cuenta y no podrá acceder nuevamente sin reactivación.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 4,
                    maxLength: 200,
                    onChanged: (_) => setDialogState(() => errorText = null),
                    decoration: InputDecoration(
                      hintText: 'Cuéntanos por qué deseas eliminar tu cuenta...',
                      errorText: errorText,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: sending ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kBrandOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: canSend ? confirmDeletion : null,
                  child: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    reasonCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de usuario'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : cs.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isLight ? kGreySoft : Colors.white12,
                      ),
                    ),
                    child: Column(
                      children: [
                        _ProfileTextField(
                          label: 'Nombres',
                          controller: _firstNameCtrl,
                          icon: Icons.person_outline,
                        ),
                        _ProfileTextField(
                          label: 'Apellidos',
                          controller: _lastNameCtrl,
                          icon: Icons.person_outline,
                        ),
                        _ProfileTextField(
                          label: 'Correo',
                          controller: _emailCtrl,
                          icon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _ProfileTextField(
                          label: 'Identificación',
                          controller: _documentCtrl,
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Número WhatsApp',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 150,
                              child: DropdownButtonFormField<CountryPhoneOption>(
                                value: _selectedCountry,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.flag_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: kProfileCountryPhoneOptions
                                    .map(
                                      (country) => DropdownMenuItem(
                                        value: country,
                                        child: Text(
                                          '${country.flag} ${country.phoneCode}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _selectedCountry = value);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Número de WhatsApp',
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          value: _isCompany,
                          onChanged: (value) => setState(() => _isCompany = value),
                          title: const Text('Trabajo para una empresa'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_isCompany)
                          _ProfileTextField(
                            label: 'Empresa',
                            controller: _companyCtrl,
                            icon: Icons.business_outlined,
                          ),
                        SwitchListTile(
                          value: _isDriver,
                          onChanged: (value) => setState(() => _isDriver = value),
                          title: const Text('Soy conductor'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 46,
                          child: FilledButton(
                            onPressed: _saving ? null : _saveProfile,
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Guardar cambios'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _openDeleteDialog,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar cuenta'),
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

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
