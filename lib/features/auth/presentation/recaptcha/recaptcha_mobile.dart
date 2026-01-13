import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<String?> openRecaptcha({
  required BuildContext context,
  required String siteKey, // (puedes no usarlo, tu backend ya tiene el suyo)
}) async {
  final token = await showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: true,
    isDismissible: true,
    builder: (sheetCtx) {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'Recaptcha',
          onMessageReceived: (msg) {
            final t = msg.message.trim();
            if (t.isNotEmpty) {
              Navigator.of(sheetCtx).pop(t); // ✅ CIERRA y DEVUELVE token
            }
          },
        )
        ..loadRequest(Uri.parse('https://conexioncarga.com/recaptcha'));

      final h = MediaQuery.of(sheetCtx).size.height;

      return SizedBox(
        height: h * 0.82,
        child: Column(
          children: [
            // header con X por si el usuario quiere cerrar
            Row(
              children: [
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Verificación reCAPTCHA',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(sheetCtx).pop(null),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(child: WebViewWidget(controller: controller)),
          ],
        ),
      );
    },
  );

  final clean = token?.trim();
  if (clean == null || clean.isEmpty) return null;
  return clean;
}
