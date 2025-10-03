import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/widgets/forms/form_layout.dart';

// Reutilizamos tu AppTextField multilineo para comentarios:
import 'package:conexion_carga_app/app/widgets/inputs/app_multiline_field.dart';

/// Modelo simple de estado por documento.
class DocCheck {
  DocCheck({
    required this.nombre,
    this.tiene = false,
    this.vigente, // true/false/null
    this.fechaVencimiento,
    this.comentarios = '',
  });

  final String nombre;
  bool tiene;
  bool? vigente;
  DateTime? fechaVencimiento;
  String comentarios;
}

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final _docs = <DocCheck>[
    DocCheck(nombre: 'Licencia de conducción'),
    DocCheck(nombre: 'Licencia de Tránsito o Matrícula Vehículo'),
    DocCheck(nombre: 'Licencia de Tránsito o Matrícula Tráiler (si aplica)'),
    DocCheck(nombre: 'Tecnomecánica'),
    DocCheck(nombre: 'SOAT'),
    DocCheck(nombre: 'Seguridad social'),
    DocCheck(nombre: 'Seguro de daños y/o RCE'),
  ];

  final _comentarioGeneralCtrl = TextEditingController();

  @override
  void dispose() {
    _comentarioGeneralCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      initialDate: _docs[index].fechaVencimiento ?? now,
    );
    if (picked != null) setState(() => _docs[index].fechaVencimiento = picked);
  }

  void _guardar() {
    // TODO: Conectar con backend. Por ahora sólo mostramos un resumen básico.
    final resumen = _docs.map((d) {
      final vig = d.vigente == null
          ? '—'
          : (d.vigente! ? 'Vigente' : 'No vigente');
      final fv = d.fechaVencimiento == null
          ? ''
          : ' (vence: ${DateFormat('dd/MM/yyyy').format(d.fechaVencimiento!)})';
      return '${d.tiene ? "✔" : "✖"} ${d.nombre} · $vig$fv';
    }).join('\n');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checklist guardado:\n$resumen')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FormScaffold(
      title: const Text('Checklist — Inspección pre-operacional'),
      actions: [
        ThemeToggle(color: cs.onSurface, size: 22),
        const SizedBox(width: 8),
      ],
      children: [
        const FormSectionTitle('VERIFICACIÓN DE LA TENENCIA DE DOCUMENTOS Y SU VIGENCIA'),
        const SizedBox(height: 8),

        // Lista de ítems
        ...List.generate(_docs.length, (i) {
          final doc = _docs[i];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tenencia
                  Row(
                    children: [
                      Checkbox(
                        value: doc.tiene,
                        onChanged: (v) => setState(() => doc.tiene = v ?? false),
                      ),
                      Expanded(
                        child: Text(
                          doc.nombre,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),

                  // Vigencia
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        const Text('Vigencia:  '),
                        ChoiceChip(
                          label: const Text('Sí'),
                          selected: doc.vigente == true,
                          onSelected: (_) =>
                              setState(() => doc.vigente = true),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('No'),
                          selected: doc.vigente == false,
                          onSelected: (_) =>
                              setState(() => doc.vigente = false),
                        ),
                        const SizedBox(width: 12),
                        // Fecha (sólo si no vigente o si el usuario quiere registrarla)
                        if (doc.vigente == false)
                          TextButton.icon(
                            onPressed: () => _pickDate(i),
                            icon: const Icon(Icons.event_outlined),
                            label: Text(
                              doc.fechaVencimiento == null
                                  ? 'Fecha de vencimiento'
                                  : DateFormat('dd/MM/yyyy')
                                      .format(doc.fechaVencimiento!),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Comentarios por documento
                  if (doc.vigente == false || doc.tiene == false) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: doc.comentarios,
                      onChanged: (v) => doc.comentarios = v,
                      decoration: const InputDecoration(
                        labelText: 'Comentarios sobre este documento',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        const FormSectionTitle('Comentario general'),
        AppMultilineField(
          label: 'Observaciones',
          controller: _comentarioGeneralCtrl,
          hint: 'Notas generales de la inspección…',
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
