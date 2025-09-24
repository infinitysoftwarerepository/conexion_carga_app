
import 'package:flutter/material.dart';

// 🌗 Lunita (toggle claro/oscuro)
import 'package:bolsa_carga_app/features/loads/presentation/widgets/theme_toggle.dart';



/// Página de Términos y Políticas.
/// - El checkbox inicia en false.
/// - Al activar el checkbox, se hace Navigator.pop(context, true).
class TermsPage extends StatefulWidget {
  const TermsPage({super.key});
  

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _accepted = false;

  void _toggleAccepted(bool? v) {
    final newVal = v ?? false;
    setState(() => _accepted = newVal);
    if (newVal) {
      // En cuanto acepta, regresamos informando 'true'
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Políticas'),
        centerTitle: true,
        actions: [
          ThemeToggle(
            color: cs.onSurface,
            size: 22,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: DefaultTextStyle(
                  // 👇 puedes haber cambiado tamaños con TextStyle(fontSize: ...)
                  style: theme.textTheme.bodyMedium!,
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. Introducción',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'Al registrarte y usar esta aplicación aceptas los presentes Términos y '
                          'Políticas de Privacidad. Si no estás de acuerdo, por favor no continúes '
                          'con el registro.',
                        ),
                        const SizedBox(height: 16),

                        Text('2. Uso de la aplicación',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'Te comprometes a utilizar la aplicación de forma lícita, a proporcionar '
                          'información veraz y a no realizar actividades que puedan afectar el '
                          'funcionamiento del servicio o la experiencia de otros usuarios.',
                        ),
                        const SizedBox(height: 16),

                        Text('3. Datos personales y privacidad',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'La información personal que proporciones (por ejemplo, correo electrónico '
                          'e identificación) será tratada conforme a la normativa aplicable y con la '
                          'finalidad de prestarte el servicio. No compartimos tus datos con terceros '
                          'sin tu autorización, salvo obligación legal.',
                        ),
                        const SizedBox(height: 16),

                        Text('4. Tratamiento y conservación de datos',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'Al registrarte autorizas el tratamiento de tus datos para los fines '
                          'operativos de la plataforma. Conservaremos tus datos durante el tiempo '
                          'necesario para cumplir la finalidad y las obligaciones legales.',
                        ),
                        const SizedBox(height: 16),

                        Text('5. Seguridad',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'Aplicamos medidas de seguridad razonables para proteger tu información. '
                          'Sin embargo, ningún sistema es completamente infalible.',
                        ),
                        const SizedBox(height: 16),

                        Text('6. Propiedad intelectual',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'Los contenidos, marcas y elementos distintivos de la aplicación pertenecen '
                          'a sus respectivos titulares. No está permitida su reproducción o uso sin '
                          'autorización.',
                        ),
                        const SizedBox(height: 16),

                        Text('7. Modificaciones',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'Podremos actualizar estos Términos y Políticas en cualquier momento. '
                          'Las modificaciones se publicarán en esta sección.',
                        ),
                        const SizedBox(height: 16),

                        Text('8. Contacto',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'Si tienes dudas sobre estos términos o el manejo de tus datos, '
                          'ponte en contacto con nuestro equipo de soporte.',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Check fijo abajo
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outlineVariant)),
              ),
              child: CheckboxListTile(
                value: _accepted,
                onChanged: _toggleAccepted,
                title: const Text('Acepto Términos y Políticas de Privacidad.'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
