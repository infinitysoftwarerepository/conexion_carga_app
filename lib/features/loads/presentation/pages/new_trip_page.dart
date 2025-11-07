// lib/features/loads/presentation/pages/new_trip_page.dart
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/widgets/inputs/app_text_field.dart';
import 'package:conexion_carga_app/app/widgets/inputs/app_multiline_field.dart';

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/core/auth_session.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({super.key});
  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  // Controladores
  final _origenCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  final _tipoCargaCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _comercialCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _conductorCtrl = TextEditingController();
  // final _vehiculoCtrl = TextEditingController(); // eliminado
  final _tipoVehiculoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  bool _premium = false;
  int _durationHours = 24;

  // Caché de catálogos por endpoint
  final Map<String, List<String>> _cache = {};

  @override
  void initState() {
    super.initState();
    final u = AuthSession.instance.user.value;
    final fullName = [
      (u?.firstName ?? '').trim(),
      (u?.lastName ?? '').trim(),
    ].where((s) => s.isNotEmpty).join(' ');
    _comercialCtrl.text = fullName;
  }

  @override
  void dispose() {
    _origenCtrl.dispose();
    _destinoCtrl.dispose();
    _tipoCargaCtrl.dispose();
    _pesoCtrl.dispose();
    _valorCtrl.dispose();
    _comercialCtrl.dispose();
    _contactoCtrl.dispose();
    _conductorCtrl.dispose();
    // _vehiculoCtrl.dispose(); // eliminado
    _tipoVehiculoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  // -------------------- FALLBACKS LOCALES --------------------
  static const _fallbackMunicipios = <String>[
    'Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena', 'Bucaramanga',
    'Cúcuta', 'Pereira', 'Manizales', 'Ibagué', 'Villavicencio', 'Santa Marta'
  ];
  static const _fallbackTiposCarga = <String>[
    'Granel sólido','Granel líquido','Contenedor FCL','Contenedor LCL',
    'Fraccionada','Peligrosa','Refrigerada','Perecedera','Material de construcción'
  ];
  static const _fallbackTiposVehiculo = <String>[
    'Tracto','Sencillo','Doble troque','Turbo sencillo','NHR','NPR',
    'Vehículo rígido de dos ejes','Vehículo rígido de tres ejes'
  ];

  List<String> _fallbackFor(String endpoint) {
    if (endpoint.contains('municipios')) return _fallbackMunicipios;
    if (endpoint.contains('tipos-carga')) return _fallbackTiposCarga;
    if (endpoint.contains('tipos-vehiculo')) return _fallbackTiposVehiculo;
    return const <String>[];
  }

  // -------------------- FETCH CATÁLOGOS --------------------
  Future<List<String>> _fetchCatalog(String endpoint) async {
    if (_cache.containsKey(endpoint)) return _cache[endpoint]!;

    final tok = AuthSession.instance.token ?? '';
    final uri = Uri.parse('${Env.baseUrl}$endpoint?limit=10000');

    // ignore: avoid_print
    print('[CAT] GET $uri');

    try {
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
        if (tok.isNotEmpty) 'Authorization': 'Bearer $tok',
      });

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      dynamic json;
      try {
        json = convert.jsonDecode(res.body);
      } catch (_) {
        json = res.body;
      }

      List<dynamic> list = const [];
      if (json is List) {
        list = json;
      } else if (json is Map) {
        final keys = ['data','items','rows','result','results','municipios','tipos','catalogo','catalogos'];
        for (final k in keys) {
          if (json[k] is List) { list = json[k] as List; break; }
        }
        if (list.isEmpty) {
          List<dynamic> biggest = const [];
          json.forEach((k, v) {
            if (v is List && v.length > biggest.length) biggest = v;
          });
          list = biggest;
        }
      }

      final names = list
          .map((e) {
            if (e is String) return e;
            if (e is Map) {
              return (e['nombre'] ?? e['name'] ?? e['label'] ?? e['title'] ?? e['descripcion'] ?? '').toString();
            }
            return '';
          })
          .where((s) => s.trim().isNotEmpty)
          .cast<String>()
          .toList();

      final result = names.isEmpty ? _fallbackFor(endpoint) : names;
      _cache[endpoint] = result;

      // ignore: avoid_print
      print('[CAT] 200 $endpoint → ${result.length} items');
      return result;
    } catch (e) {
      final fb = _fallbackFor(endpoint);
      _cache[endpoint] = fb;
      // ignore: avoid_print
      print('[CAT][ERR] $endpoint → ${e.toString()} | fallback=${fb.length}');
      return fb;
    }
  }

  // -------------------- GUARDAR --------------------
  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (_origenCtrl.text.isEmpty ||
        _destinoCtrl.text.isEmpty ||
        _tipoCargaCtrl.text.isEmpty ||
        _pesoCtrl.text.isEmpty ||
        _valorCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Completa los campos obligatorios.')));
      return;
    }

    final tok = AuthSession.instance.token ?? '';
    final uri = Uri.parse('${Env.baseUrl}/api/loads');

    final body = {
      "empresa_id": null,
      "origen": _origenCtrl.text.trim(),
      "destino": _destinoCtrl.text.trim(),
      "tipo_carga": _tipoCargaCtrl.text.trim(),
      "peso": double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0.0,
      "valor": int.tryParse(_valorCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0,
      "conductor": _conductorCtrl.text.trim().isEmpty ? null : _conductorCtrl.text.trim(),
      // "vehiculo_id": _vehiculoCtrl.text.trim().isEmpty ? null : _vehiculoCtrl.text.trim(), // eliminado
      "tipo_vehiculo": _tipoVehiculoCtrl.text.trim().isEmpty ? null : _tipoVehiculoCtrl.text.trim(),
      "observaciones": _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      "duration_hours": _durationHours,
      "premium_trip": _premium,
    };

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', if (tok.isNotEmpty) 'Authorization': 'Bearer $tok'},
        body: convert.jsonEncode(body),
      );

      if (res.statusCode != 201) {
        String msg = 'No se pudo registrar el viaje (${res.statusCode}).';
        try {
          final m = convert.jsonDecode(res.body);
          if (m is Map && m['detail'] != null) msg = m['detail'].toString();
        } catch (_) {}
        throw Exception(msg);
      }

      if (!mounted) return;
      final me = AuthSession.instance.user.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Viaje registrado para ${me?.firstName ?? 'ti'}')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final form = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _Row2(
            left: DropdownCatalogField(
              label: 'Origen',
              hint: 'Ciudad de origen',
              controller: _origenCtrl,
              icon: Icons.location_on_outlined,
              endpoint: '/api/catalogos/municipios',
              loader: _fetchCatalog,
            ),
            right: DropdownCatalogField(
              label: 'Destino',
              hint: 'Ciudad de destino',
              controller: _destinoCtrl,
              icon: Icons.flag_outlined,
              endpoint: '/api/catalogos/municipios',
              loader: _fetchCatalog,
            ),
          ),
          const SizedBox(height: 6),
          _Row2(
            left: DropdownCatalogField(
              label: 'Tipo de carga',
              hint: 'Granel, Contenedor, etc.',
              controller: _tipoCargaCtrl,
              icon: Icons.inventory_2_outlined,
              endpoint: '/api/catalogos/tipos-carga',
              loader: _fetchCatalog,
            ),
            right: AppTextField(
              label: 'Peso (T)',
              hint: 'Ej: 32',
              controller: _pesoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              icon: Icons.scale_outlined,
            ),
          ),
          const SizedBox(height: 6),
          _Row2(
            left: AppTextField(
              label: 'Valor (COP)',
              hint: 'Ej: 10000000',
              controller: _valorCtrl,
              keyboardType: TextInputType.number,
              icon: Icons.attach_money,
            ),
            right: AppTextField(
              label: 'Comercial',
              hint: 'Nombre del comercial',
              controller: _comercialCtrl,
              icon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 6),
          _Row2(
            left: AppTextField(
              label: 'Contacto (teléfono)',
              hint: 'Cel del comercial',
              controller: _contactoCtrl,
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
            ),
            right: AppTextField(
              label: 'Conductor',
              hint: 'Nombre del conductor',
              controller: _conductorCtrl,
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 6),
          _Row2(
            // Aquí antes estaba “Vehículo (placa)”; se quita.
            left: DropdownCatalogField(
              label: 'Tipo de vehículo',
              hint: 'Tracto, Sencillo, …',
              controller: _tipoVehiculoCtrl,
              icon: Icons.agriculture_outlined,
              endpoint: '/api/catalogos/tipos-vehiculo',
              loader: _fetchCatalog,
            ),
            right: const SizedBox.shrink(), // mantiene la grilla estable
          ),
          const SizedBox(height: 6),
          AppMultilineField(
            label: 'Observaciones',
            controller: _obsCtrl,
            hint: 'Detalles adicionales…',
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 6),

          // Bloque tipo de viaje + duración
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? cs.surfaceVariant.withOpacity(0.30)
                  : cs.surfaceVariant.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo de viaje', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Row(children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _premium,
                        onChanged: (_) {},
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text('Viaje estándar'),
                    ]),
                    const SizedBox(width: 8),
                    Opacity(
                      opacity: 0.45,
                      child: Row(children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _premium,
                          onChanged: null,
                          visualDensity: VisualDensity.compact,
                        ),
                        const Text('Viaje premium'),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('El viaje se borrará automáticamente en:',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                _DurationChips(
                  value: _durationHours,
                  onChanged: (v) => setState(() => _durationHours = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('¡ Publicar !'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: CustomAppBar(
        titleSpacing: 0,
        height: 56,
        centerTitle: true,
        title: const Text('Registrar nuevo viaje'),
        actions: [ThemeToggle(size: 22), const SizedBox(width: 8)],
      ),
      body: LayoutBuilder(
        builder: (ctx, c) {
          const estimatedMin = 690.0;
          final needsScroll = c.maxHeight < estimatedMin;
          final content = form;
          return needsScroll
              ? SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(ctx).bottom + 8,
                  ),
                  child: content,
                )
              : content;
        },
      ),
    );
  }
}

/* -------------------- fila 2 columnas -------------------- */
class _Row2 extends StatelessWidget {
  const _Row2({required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Expanded(child: left), const SizedBox(width: 10), Expanded(child: right)],
    );
  }
}

/* -------------------- chips duración -------------------- */
class _DurationChips extends StatelessWidget {
  const _DurationChips({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int hours, {bool enabled = true}) {
      final selected = value == hours;
      return Opacity(
        opacity: enabled ? 1 : 0.45,
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: enabled ? (_) => onChanged(hours) : null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        chip('6 horas', 6),
        chip('12 horas', 12),
        chip('24 horas', 24),
        chip('3 horas', 3, enabled: false),
        chip('18 horas', 18, enabled: false),
        chip('48 horas', 48, enabled: false),
      ],
    );
  }
}

/* -------------------- dropdown en cascada -------------------- */
class DropdownCatalogField extends StatefulWidget {
  const DropdownCatalogField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.endpoint,
    required this.loader,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final String endpoint;
  final Future<List<String>> Function(String endpoint) loader;

  @override
  State<DropdownCatalogField> createState() => _DropdownCatalogFieldState();
}

class _DropdownCatalogFieldState extends State<DropdownCatalogField> {
  final _link = LayerLink();
  OverlayEntry? _entry;

  List<String>? _items;
  List<String> _filtered = const [];
  String? _error;
  bool _loading = false;

  TextEditingController get _textCtrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(_onTyped);
  }

  @override
  void dispose() {
    _removeEntry();
    _textCtrl.removeListener(_onTyped);
    super.dispose();
  }

  void _onTyped() {
    if (_items == null) return;
    final q = _textCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty ? List<String>.from(_items!) : _items!.where((e) => e.toLowerCase().contains(q)).toList();
    });
    _entry?.markNeedsBuild();
  }

  Future<void> _ensureData() async {
    if (_items != null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.loader(widget.endpoint);
      _items = data;
      _filtered = List<String>.from(data);
    } catch (e) {
      _error = e.toString();
      _items = const [];
      _filtered = const [];
    } finally {
      _loading = false;
      if (mounted) setState(() {});
    }
  }

  void _open() async {
    await _ensureData();
    _removeEntry();

    _entry = OverlayEntry(builder: (context) {
      final maxWidth = (context.findAncestorRenderObjectOfType<RenderBox>())?.size.width ?? 320;

      return Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeEntry,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: const Offset(0, 44),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minWidth: maxWidth,
                  maxHeight: 260,
                ),
                child: _popupBody(),
              ),
            ),
          ),
        ),
      );
    });

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  Widget _popupBody() {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if ((_items?.isEmpty ?? true)) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('Sin resultados')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final opt = _filtered[i];
        return ListTile(
          dense: true,
          title: Text(opt),
          onTap: () {
            _textCtrl.text = opt;
            _textCtrl.selection = TextSelection.collapsed(offset: opt.length);
            _removeEntry();
          },
        );
      },
    );
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AppTextField(
            label: widget.label,
            hint: widget.hint,
            controller: _textCtrl,
            icon: widget.icon,
            readOnly: false,
            onTap: _open,
            onChanged: (_) => _entry?.markNeedsBuild(),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.arrow_drop_down_rounded, size: 22),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 36,
                height: 40,
                child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _open),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
