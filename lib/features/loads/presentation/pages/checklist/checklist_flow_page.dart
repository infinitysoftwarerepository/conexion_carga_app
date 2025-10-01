// lib/features/loads/presentation/pages/checklist/checklist_flow_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/theme_toggle.dart';
import 'models/checklist_models.dart';
import 'steps/step1_info_basica.dart';
import 'steps/step2_docs_vigencia.dart';
import 'steps/step3_espacios_ocultos.dart';
import 'steps/step4_componentes.dart';
import 'steps/step5_observaciones.dart';
import 'actions/export_actions_page.dart';

class ChecklistFlowPage extends StatefulWidget {
  const ChecklistFlowPage({super.key});

  @override
  State<ChecklistFlowPage> createState() => _ChecklistFlowPageState();
}

class _ChecklistFlowPageState extends State<ChecklistFlowPage> {
  final _state = ChecklistState();
  final _controller = PageController();
  int _index = 0;

  late final List<Widget> _steps;

  @override
  void initState() {
    super.initState();
    _steps = [
      Step1InfoBasica(state: _state),
      Step2DocsVigencia(state: _state),
      Step3EspaciosOcultos(state: _state),
      Step4Componentes(state: _state),
      Step5Observaciones(state: _state),
    ];
  }

  void _next() {
    if (_index < _steps.length - 1) {
      setState(() => _index++);
      _controller.animateToPage(_index,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() => _index--);
      _controller.animateToPage(_index,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  String _progressLabel() => 'Paso ${_index + 1} de ${_steps.length}';

  void _guardarFinal() {
    // Aquí podrías validar todo o persistir local/remote.
    final fecha = _state.fecha == null ? '—' : DateFormat('dd/MM/yyyy').format(_state.fecha!);
    final resumen = 'Fecha: $fecha | Placa: ${_state.placa} | Tipo: ${_state.tipoVehiculo} | Color: ${_state.color}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checklist guardado.\n$resumen')));

    // → Ir a la pantalla de acciones (sexta pantalla)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExportActionsPage(state: _state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _index == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist — Inspección pre-operacional'),
        actions: [
          ThemeToggle(color: cs.onSurface, size: 22),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(_progressLabel()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_index + 1) / _steps.length,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Contenido por pasos (sin swipe manual)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _steps.map((w) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(children: [Expanded(child: w)]),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Navegación inferior
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _index == 0 ? null : _prev,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Anterior'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLast ? _guardarFinal : _next,
                      icon: Icon(isLast ? Icons.task_alt : Icons.chevron_right),
                      label: Text(isLast ? 'Finalizar' : 'Siguiente'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
