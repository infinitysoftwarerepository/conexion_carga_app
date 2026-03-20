import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<Uint8List> captureRepaintBoundaryPngBytes(
  GlobalKey repaintKey, {
  int maxAttempts = 24,
  double pixelRatio = 3,
}) async {
  for (int i = 0; i < maxAttempts; i++) {
    await Future.delayed(const Duration(milliseconds: 90));
    await WidgetsBinding.instance.endOfFrame;

    final ctx = repaintKey.currentContext;
    if (ctx == null) {
      continue;
    }

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      continue;
    }

    if (!renderObject.hasSize) {
      continue;
    }

    final size = renderObject.size;
    if (size.isEmpty || size.width <= 0 || size.height <= 0) {
      continue;
    }

    try {
      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();

      if (byteData == null) {
        continue;
      }

      return byteData.buffer.asUint8List();
    } catch (_) {
      continue;
    }
  }

  throw Exception('No se pudo capturar la tarjeta para exportar.');
}

Future<void> sharePosterBytes({
  required BuildContext context,
  required Uint8List bytes,
  required String fileName,
  String text = 'Detalle del viaje - Conexión Carga',
  String subject = 'Detalle del viaje',
}) async {
  if (kIsWeb) {
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: fileName,
        ),
      ],
      text: text,
      subject: subject,
    );
    return;
  }

  final tempDir = await getTemporaryDirectory();
  final path = '${tempDir.path}/$fileName';

  final tempXFile = XFile.fromData(
    bytes,
    mimeType: 'image/png',
    name: fileName,
  );

  await tempXFile.saveTo(path);

  try {
    await Share.shareXFiles(
      [
        XFile(
          path,
          mimeType: 'image/png',
          name: fileName,
        ),
      ],
      text: text,
      subject: subject,
    );
  } catch (_) {
    final result = await OpenFilex.open(path);

    if (!context.mounted) return;

    final type = result.type.toString().toLowerCase();
    if (type.contains('error') || type.contains('noapp')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La imagen se exportó, pero no se pudo abrir ni compartir automáticamente.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Imagen exportada. Ya puedes compartirla desde el visor.',
          ),
        ),
      );
    }
  }
}