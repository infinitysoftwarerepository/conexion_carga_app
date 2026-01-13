import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


// 🌗 Lunita (toggle claro/oscuro)
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';

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
      Navigator.of(context).pop(true);
    }
  }

  // Lanzar PDFs dentro de assets
// ✅ NUEVO: abre PDFs desde el BACK (URL pública)
Future<void> _openPdfUrl(String url) async {
  try {
    final uri = Uri.parse(url);

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // abre en navegador / visor del sistema
    );

    if (!ok) {
      throw Exception('No se pudo abrir: $url');
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo abrir el documento: $e')),
    );
  }
}




  // Lanzar correo
  Future<void> _sendEmail() async {
    final uri = Uri(scheme: "mailto", path: "conexioncarga@gmail.com");
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo abrir el correo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y condiciones de uso', 
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700 )),
        centerTitle: true,
        actions: [
          ThemeToggle(color: cs.onSurface, size: 22),
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
                  style: theme.textTheme.bodyMedium!,
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Introducción',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Al registrarte y usar esta aplicación aceptas los presentes Términos y '
                          'Políticas de Privacidad. Si no estás de acuerdo, por favor no continúes '
                          'con el registro.\n\n'
                          'Conexión Carga únicamente facilita la comunicación entre las partes y no '
                          'asume responsabilidad alguna por la negociación o cumplimiento de los '
                          'acuerdos.',
                        ),
                        const SizedBox(height: 16),

                        // 2. Uso de la aplicación
                        Text(
                          'Uso de la aplicación',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium,
                            children: [
                              const TextSpan(
                                text:
                                    'Te comprometes a utilizar la aplicación de forma lícita, a proporcionar '
                                    'información veraz y a no realizar actividades que puedan afectar el '
                                    'funcionamiento del servicio o la experiencia de otros usuarios.\n\n',
                              ),
                              TextSpan(
                                text: 'Ver términos y condiciones de uso',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _openPdfUrl("https://conexioncarga.com/terminos");

                                  },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 3. Datos y privacidad
                        Text(
                          'Política de privacidad',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium,
                            children: [
                              const TextSpan(
                                text:
                                
                                    'CONEXIÓN CARGA es el responsable del tratamiento de sus datos. La recolección de esta información se '
                                    'llevará a cabo con la participación activa de las personas que se registren en nuestro sistema. La '
                                    'información recopilada se utilizará exclusivamente con fines comerciales, tales como: el envío de '
                                    'promociones y ofertas personalizadas, la promoción de nuestros productos y servicios, así como los de '
                                    'terceros, la difusión de nuevos servicios en el sector del transporte y la entrega de información relevante '
                                    'relacionada con este sector. Esto también incluye el desarrollo de aplicaciones o programas dirigidos a '
                                    'mejorar el ámbito del transporte. '
                                    'Los titulares de los datos tienen derecho a conocer, actualizar y rectificar su información personal, así '
                                    'como a revocar la autorización otorgada y solicitar la eliminación de sus datos personales. Para más '
                                    'detalles, consulte nuestra Política de Privacidad..\n\n',
                              ),
                              TextSpan(
                                text: 'Ver política de privacidad',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _openPdfUrl("https://conexioncarga.com/privacidad");

                                  },
                              ),
                            ],
                          ),
                        ),



                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Check abajo
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
