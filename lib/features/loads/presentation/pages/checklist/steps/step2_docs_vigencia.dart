// lib/features/loads/presentation/pages/checklist/steps/step2_docs_vigencia.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/checklist_models.dart';

class Step2DocsVigencia extends StatefulWidget {
  const Step2DocsVigencia({super.key, required this.state});
  final ChecklistState state;

  @override
  State<Step2DocsVigencia> createState() => _Step2DocsVigenciaState();
}

class _Step2DocsVigenciaState extends State<Step2DocsVigencia> {
  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      initialDate: widget.state.documentos[index].fechaVencimiento ?? now,
    );
    if (picked != null) {
      setState(() => widget.state.documentos[index].fechaVencimiento = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = widget.state.documentos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VERIFICACIÓN DE LA TENENCIA DE DOCUMENTOS Y SU VIGENCIA',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: doc.tiene,
                            onChanged: (v) => setState(() => doc.tiene = v ?? false),
                          ),
                          Expanded(child: Text(doc.nombre, style: Theme.of(context).textTheme.bodyLarge)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            const Text('Vigencia:  '),
                            ChoiceChip(
                              label: const Text('Sí'),
                              selected: doc.vigente == true,
                              onSelected: (_) => setState(() => doc.vigente = true),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('No'),
                              selected: doc.vigente == false,
                              onSelected: (_) => setState(() => doc.vigente = false),
                            ),
                            const SizedBox(width: 12),
                            if (doc.vigente == false)
                              TextButton.icon(
                                onPressed: () => _pickDate(i),
                                icon: const Icon(Icons.event_outlined),
                                label: Text(
                                  doc.fechaVencimiento == null
                                      ? 'Fecha de vencimiento'
                                      : DateFormat('dd/MM/yyyy').format(doc.fechaVencimiento!),
                                ),
                              ),
                          ],
                        ),
                      ),
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
            },
          ),
        ),
      ],
    );
  }
}
