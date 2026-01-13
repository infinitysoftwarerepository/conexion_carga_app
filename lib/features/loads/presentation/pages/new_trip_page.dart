import 'dart:convert' as convert;
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
// para RenderBox en el dropdown
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/app/widgets/custom_app_bar.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/widgets/inputs/app_text_field.dart';
import 'package:conexion_carga_app/app/widgets/inputs/app_multiline_field.dart';
import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/start/start_page.dart';

/// Pantalla para registrar un nuevo viaje (y reutilizar uno existente)
class NewTripPage extends StatefulWidget {
  /// Cuando se pasa un trip, la pantalla se usa como “Reutilizar viaje”
  final Trip? initialTrip;

  const NewTripPage({super.key, this.initialTrip});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  // ---------------------------------------------------------------------------
  // Controladores por campo
  // ---------------------------------------------------------------------------
  final _origenCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  final _tipoVehiculoCtrl = TextEditingController();
  final _tipoCargaCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  final _comercialCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _conductorCtrl = TextEditingController(); // se sigue usando en el body
  final _obsCtrl = TextEditingController();

    // ---------------------------------------------------------------------------
  // Formateo en vivo para el campo "Valor (COP)"
  // ---------------------------------------------------------------------------
  bool _isFormattingValor = false;

  /// Formatea un entero a string con puntos de miles: 1000000 → "1.000.000"
  String _formatCop(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final reverseIndex = s.length - i; // posiciones desde el final
      buffer.write(s[i]);
      // Insertar punto si faltan grupos completos de 3 dígitos
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  /// Listener que se ejecuta cada vez que cambia el texto del campo "Valor"
  void _onValorChanged() {
    if (_isFormattingValor) return; // evita bucles al modificar el texto

    _isFormattingValor = true;
    final raw = _valorCtrl.text;

    // 1) Dejar solo dígitos (quita puntos, comas, espacios, etc.)
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _valorCtrl.clear();
      _isFormattingValor = false;
      return;
    }

    // 2) Parsear a int
    final value = int.tryParse(digits);
    if (value == null) {
      _isFormattingValor = false;
      return;
    }

    // 3) Formatear con separadores de miles
    final formatted = _formatCop(value);

    // 4) Volver a escribir en el controller manteniendo el cursor al final
    _valorCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    _isFormattingValor = false;
  }


  // Viaje estándar/premium
  bool _premium = false;

  /// duration_hours (por defecto 6 para que el primer chip quede seleccionado)
  int _durationHours = 6;

  // Caché de catálogos por endpoint
  final Map<String, List<String>> _cache = {};

  @override
  void initState() {
    super.initState();

    // -------------------------------------------------------------------------
    // Prefills desde usuario autenticado
    // -------------------------------------------------------------------------
    final u = AuthSession.instance.user.value;

    // Comercial por defecto = nombre del usuario
    final fullName = [
      (u?.firstName ?? '').trim(),
      (u?.lastName ?? '').trim(),
    ].where((s) => s.isNotEmpty).join(' ');
    _comercialCtrl.text = fullName;

    // Empresa por defecto (si viene)
    final company = (u?.companyName ?? '').trim();
    if (company.isNotEmpty) _empresaCtrl.text = company;

    // -------------------------------------------------------------------------
    // Si venimos de “Reutilizar viaje”, precargamos los datos
    // -------------------------------------------------------------------------
    final t = widget.initialTrip;
    if (t != null) {
      _origenCtrl.text = t.origin;
      _destinoCtrl.text = t.destination;
      _tipoCargaCtrl.text = t.cargoType;
      _tipoVehiculoCtrl.text = t.vehicle;

      if (t.tons != null) {
        final d = t.tons!.toDouble();
        _pesoCtrl.text =
            d == d.truncateToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(1);
      }

      if ((t.empresa ?? '').trim().isNotEmpty) {
        _empresaCtrl.text = t.empresa!;
      }

      if (t.price != null) {
        _valorCtrl.text = t.price!.toStringAsFixed(0);
      }

      if ((t.comercial ?? '').trim().isNotEmpty) {
        _comercialCtrl.text = t.comercial!;
      }
      if ((t.contacto ?? '').trim().isNotEmpty) {
        _contactoCtrl.text = t.contacto!;
      }
      if ((t.conductor ?? '').trim().isNotEmpty) {
        _conductorCtrl.text = t.conductor!;
      }

      if ((t.observaciones ?? '').trim().isNotEmpty) {
        _obsCtrl.text = t.observaciones!;
      }
    }
  // 👉 Formateo en vivo del campo Valor COP
    _valorCtrl.addListener(_onValorChanged);

    // Si venimos con un valor precargado, lo formateamos una vez
    if (_valorCtrl.text.isNotEmpty) {
      _onValorChanged();
    }
  }

  

  @override
  void dispose() {
    _origenCtrl.dispose();
    _destinoCtrl.dispose();
    _tipoVehiculoCtrl.dispose();
    _tipoCargaCtrl.dispose();
    _valorCtrl.dispose();
    _pesoCtrl.dispose();
    _empresaCtrl.dispose();
    _comercialCtrl.dispose();
    _contactoCtrl.dispose();
    _conductorCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // FALLBACKS LOCALES (por si el backend falla)
  // ---------------------------------------------------------------------------
  static const _fallbackMunicipios = <String>[
    'Abejorral',
    'Abriaquí',
    'Amagá',
    'Andes',
    'Angelópolis',
    'Apartadó',
    'Armenia',
    'Barbosa',
    'Barrancabermeja',
    'Barranquilla',
    'Bello',
    'Bello Oriente',
    'Bogotá',
    'Bucaramanga',
    'Buenaventura',
    'Caldas',
    'Cali',
    'Cañas Gordas',
    'Cartagena',
    'Cartago',
    'Caucasia',
    'Cereté',
    'Ciénaga',
    'Ciénaga de Oro',
    'Copacabana',
    'Corozal',
    'Cúcuta',
    'Don Matías',
    'Doradal',
    'Dosquebradas',
    'El Bagre',
    'El Carmen de Viboral',
    'El Junco',
    'Entrerríos',
    'Envigado',
    'Floridablanca',
    'Frontino',
    'Galapa',
    'Girardota',
    'Girón',
    'Guarne',
    'Ibagué',
    'Itagüí',
    'Jamundí',
    'La Ceja',
    'La Dorada',
    'La Estrella',
    'La Pintada',
    'La Tebaida',
    'Magangué',
    'Manizales',
    'Medellín',
    'Montelíbano',
    'Montería',
    'Neiva',
    'Pailitas',
    'Palmira',
    'Pasto',
    'Pereira',
    'Piedecuesta',
    'Pitalito',
    'Planeta Rica',
    'Popayán',
    'Puerto Berrío',
    'Puerto Boyacá',
    'Puerto Parra',
    'Puerto Tejada',
    'Puerto Triunfo',
    'Quibdó',
    'Rionegro',
    'Sabana de Torres',
    'Sabaneta',
    'Sahagún',
    'Salgar',
    'San Alberto',
    'San Carlos',
    'San Cristóbal',
    'San Marcos',
    'San Onofre',
    'Santa Marta',
    'Santa Rosa de Cabal',
    'Santa Rosa de Osos',
    'Santander de Quilichao',
    'Sincelejo',
    'Sincé',
    'Sitio Nuevo',
    'Sogamoso',
    'Tocancipá',
    'Tuluá',
    'Turbo',
    'Turbaco',
    'Urabá',
    'Valledupar',
    'Villavicencio',
    'Yarumal',
    'Yopal',
    'Zarzal',
  ];

  static const _fallbackTiposCarga = <String>[
    'Granel sólido',
    'Granel líquido',
    'Contenedor FCL',
    'Contenedor LCL',
    'Fraccionada',
    'Peligrosa',
    'Refrigerada',
    'Perecedera',
    'Material de construcción',
  ];

  static const _fallbackTiposVehiculo = <String>[
  // Cabeza tractora / combinaciones
  'Tractocamión',
  'Tractomula',
  'Tractocamión 4x2',
  'Tractocamión 6x2',
  'Tractocamión 6x4',
  'Tractomula 2S',
  'Tractomula 3S',
  'Tractomula 2S3',
  'Tractomula 3S3',

  // Rígidos pesados
  'Camión rígido',
  'Camión 2 ejes',
  'Camión 3 ejes',
  'Camión 4 ejes',
  'Camión pesado',

  // Doble troque
  'Doble troque',
  'Doble troque 3 ejes',
  'Doble troque 4 ejes',

  // Medianos y livianos
  'Turbo',
  'Turbo sencillo',
  'Camión mediano',
  'Camión liviano',
  'Camioneta de carga',
  'Furgón',
  'Van de carga',

  // Tipo de carrocería / uso logístico
  'Furgón carrozado',
  'Furgón refrigerado',
  'Plataforma',
  'Estacas',
  'Cama baja',
  'Cama cuna',
  'Cisterna',
  'Tolva',
  'Portacontenedor',
  'Porta vehículos',
  'Porta vidrio',
  'Porta ganado',

  // Remolques
  'Remolque',
  'Semirremolque',
  'Plataforma remolque',
  'Furgón remolque',
  'Refrigerado remolque',
  'Cisterna remolque',
  'Tolva remolque',

  // Términos regionales
  'Mula',
  'Gandola',
  'Camión con acoplado',
  'Patineta',

  // Referencias comerciales comunes
  'NHR',
  'NPR',
  'NKR',
];


  List<String> _fallbackFor(String endpoint) {
    if (endpoint.contains('municipios')) return _fallbackMunicipios;
    if (endpoint.contains('tipos-carga')) return _fallbackTiposCarga;
    if (endpoint.contains('tipos-vehiculo')) return _fallbackTiposVehiculo;
    return const <String>[];
  }

  // ---------------------------------------------------------------------------
  // FETCH CATÁLOGOS (con caché + fallbacks)
  // ---------------------------------------------------------------------------
  Future<List<String>> _fetchCatalog(String endpoint) async {
    if (_cache.containsKey(endpoint)) return _cache[endpoint]!;

    final tok = AuthSession.instance.token ?? '';
    final uri = Uri.parse('${Env.baseUrl}$endpoint?limit=10000');

    // ignore: avoid_print
    print('[CAT] GET $uri');

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (tok.isNotEmpty) 'Authorization': 'Bearer $tok',
        },
      );

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
        const keys = [
          'data',
          'items',
          'rows',
          'result',
          'results',
          'municipios',
          'tipos',
          'catalogo',
          'catalogos',
        ];
        for (final k in keys) {
          if (json[k] is List) {
            list = json[k] as List;
            break;
          }
        }
        if (list.isEmpty) {
          List<dynamic> biggest = const [];
          json.forEach((_, v) {
            if (v is List && v.length > biggest.length) biggest = v;
          });
          list = biggest;
        }
      }

      final names = list
          .map((e) {
            if (e is String) return e;
            if (e is Map) {
              return (e['nombre'] ??
                      e['name'] ??
                      e['label'] ??
                      e['title'] ??
                      e['descripcion'] ??
                      '')
                  .toString();
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

  // ---------------------------------------------------------------------------
  // GUARDAR VIAJE
  // ---------------------------------------------------------------------------
  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_origenCtrl.text.isEmpty ||
        _destinoCtrl.text.isEmpty ||
        _tipoCargaCtrl.text.isEmpty ||
        _pesoCtrl.text.isEmpty ||
        _valorCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios.')),
      );
      return;
    }

    // ignore: avoid_print
    print('[NEW TRIP] duration_hours seleccionado = $_durationHours');

    final tok = AuthSession.instance.token ?? '';
    final uri = Uri.parse('${Env.baseUrl}/api/loads');

    final body = {
      "empresa":
          _empresaCtrl.text.trim().isEmpty ? null : _empresaCtrl.text.trim(),
      "origen": _origenCtrl.text.trim(),
      "destino": _destinoCtrl.text.trim(),
      "tipo_carga": _tipoCargaCtrl.text.trim(),
      "peso": double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0.0,
      "valor": int.tryParse(
              _valorCtrl.text.replaceAll('.', '').replaceAll(',', '')) ??
          0,
      "conductor": _conductorCtrl.text.trim().isEmpty
          ? null
          : _conductorCtrl.text.trim(),
      "tipo_vehiculo": _tipoVehiculoCtrl.text.trim().isEmpty
          ? null
          : _tipoVehiculoCtrl.text.trim(),
      "observaciones":
          _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      "duration_hours": _durationHours,
      "premium_trip": _premium,
      "comercial": _comercialCtrl.text.trim(),
      "contacto": _contactoCtrl.text.trim(),
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (tok.isNotEmpty) 'Authorization': 'Bearer $tok',
        },
        body: convert.jsonEncode(body),
      );

      // ignore: avoid_print
      print('[NEW TRIP] Respuesta ${res.statusCode}: ${res.body}');

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartPage()),
          (route) => false,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Config UI centralizada (para que sea fácil tunear después)
    const fieldUi = FieldUi(
      iconSize: 20,
      prefixIconMinWidth: 40,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixIconBox: 40,
      radius: 10,
      labelGap: 6,
      rowGap: 12,
      sectionGap: 14,
      maxWidth: 560, // ancho máximo del formulario
      breakpointTwoCols: 420, // < 420px -> 1 columna, >= 420px -> 2 columnas
    );

    return Scaffold(
      resizeToAvoidBottomInset: true, // importante para Android viejos
      appBar: CustomAppBar(
        titleSpacing: 0,
        height: 56,
        centerTitle: true,
        title: const Text('Publicar nuevo viaje'),
        actions: [ThemeToggle(size: 22), const SizedBox(width: 8)],
      ),
      body: SafeArea(
        // ListView = scroll siempre (S8+, Honor, iPhone, etc.)
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            12,
            12,
            12,
            12 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                // 👇 AQUÍ estaba el error: quité el `const`
                constraints: BoxConstraints(maxWidth: fieldUi.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // -----------------------------------------------------------------
                    // ORDEN DE CAMPOS (fácil de mover/editar)
                    // -----------------------------------------------------------------

                    // 1) Origen / 2) Destino
                    Adaptive2(
                      breakpoint: fieldUi.breakpointTwoCols,
                      gap: fieldUi.rowGap,
                      left: DropdownCatalogField(
                        ui: fieldUi,
                        label: 'Origen',
                        hint: 'Ciudad de origen',
                        controller: _origenCtrl,
                        icon: Icons.location_on_outlined,
                        endpoint: '/api/catalogos/municipios',
                        loader: _fetchCatalog,
                      ),
                      right: DropdownCatalogField(
                        ui: fieldUi,
                        label: 'Destino',
                        hint: 'Ciudad de destino',
                        controller: _destinoCtrl,
                        icon: Icons.flag_outlined,
                        endpoint: '/api/catalogos/municipios',
                        loader: _fetchCatalog,
                      ),
                    ),
                    SizedBox(height: fieldUi.sectionGap),

                    // 3) Tipo de vehículo / 4) Tipo de carga
                    Adaptive2(
                      breakpoint: fieldUi.breakpointTwoCols,
                      gap: fieldUi.rowGap,
                      left: DropdownCatalogField(
                        ui: fieldUi,
                        label: 'Tipo vehículo',
                        hint: 'Tracto, Sencillo, …',
                        controller: _tipoVehiculoCtrl,
                        icon: Icons.agriculture_outlined,
                        endpoint: '/api/catalogos/tipos-vehiculo',
                        loader: _fetchCatalog,
                      ),
                      right: DropdownCatalogField(
                        ui: fieldUi,
                        label: 'Tipo de carga',
                        hint: 'Granel, Contenedor, etc.',
                        controller: _tipoCargaCtrl,
                        icon: Icons.inventory_2_outlined,
                        endpoint: '/api/catalogos/tipos-carga',
                        loader: _fetchCatalog,
                      ),
                    ),
                    SizedBox(height: fieldUi.sectionGap),

                    // 5) Valor / 6) Peso
                    Adaptive2(
                      breakpoint: fieldUi.breakpointTwoCols,
                      gap: fieldUi.rowGap,
                      left: AppTextField(
                        label: 'Valor (COP)',
                        hint: 'Ej: 10.000.000',
                        controller: _valorCtrl,
                        keyboardType: TextInputType.number,
                        icon: Icons.attach_money,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // 👈 solo números
                        ],
                      ),
                      right: AppTextField(
                        label: 'Peso (T)',
                        hint: 'Ej: 32',
                        controller: _pesoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        icon: Icons.scale_outlined, inputFormatters: [],
                      ),
                    ),

                    SizedBox(height: fieldUi.rowGap),

                    // 7) Empresa / 8) Comercial
                    Adaptive2(
                      breakpoint: fieldUi.breakpointTwoCols,
                      gap: fieldUi.rowGap,
                      left: AppTextField(
                        label: 'Empresa',
                        hint: 'Nombre de la empresa',
                        controller: _empresaCtrl,
                        icon: Icons.apartment_outlined, inputFormatters: [],
                      ),
                      right: AppTextField(
                        label: 'Comercial',
                        hint: 'Nombre del comercial',
                        controller: _comercialCtrl,
                        icon: Icons.badge_outlined, inputFormatters: [],
                      ),
                    ),
                    SizedBox(height: fieldUi.rowGap),

                    // 9) Contacto (a lo ancho)
                    AppTextField(
                      label: 'Contacto (teléfono)',
                      hint: 'Cel del comercial',
                      controller: _contactoCtrl,
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_outlined, inputFormatters: [],
                    ),
                    SizedBox(height: fieldUi.rowGap),

                    // 10) Observaciones (multilínea)
                    AppMultilineField(
                      label: 'Observaciones',
                      controller: _obsCtrl,
                      hint: 'Detalles adicionales…',
                      minLines: 2,
                      maxLines: 4,
                    ),
                    SizedBox(height: fieldUi.sectionGap),

                    // -----------------------------------------------------------------
                    // Tarjeta de "Tipo de viaje" + duración
                    // -----------------------------------------------------------------
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? cs.surfaceContainerHighest.withOpacity(0.30)
                            : cs.surfaceContainerHighest.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de viaje',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: false,
                                    groupValue: _premium,
                                    onChanged: (_) =>
                                        setState(() => _premium = false),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Text('Viaje estándar'),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Opacity(
                                opacity: 0.45,
                                child: Row(
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: _premium,
                                      onChanged: null,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const Text('Viaje premium'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'El viaje se borrará automáticamente en:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          _DurationChips(
                            value: _durationHours,
                            onChanged: (v) => setState(() {
                              _durationHours = v;
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // -----------------------------------------------------------------
                    // Botones inferiores
                    // -----------------------------------------------------------------
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Config de UI para inputs (un solo lugar para tunear todo el look)
// -----------------------------------------------------------------------------
class FieldUi {
  final double iconSize;
  final double prefixIconMinWidth;
  final EdgeInsets contentPadding;
  final double suffixIconBox;
  final double radius;
  final double labelGap;
  final double rowGap;
  final double sectionGap;
  final double maxWidth;
  final double breakpointTwoCols;

  const FieldUi({
    required this.iconSize,
    required this.prefixIconMinWidth,
    required this.contentPadding,
    required this.suffixIconBox,
    required this.radius,
    required this.labelGap,
    required this.rowGap,
    required this.sectionGap,
    required this.maxWidth,
    required this.breakpointTwoCols,
  });
}

// -----------------------------------------------------------------------------
// Layout 2 columnas → 1 columna según ancho
// -----------------------------------------------------------------------------
class Adaptive2 extends StatelessWidget {
  const Adaptive2({
    super.key,
    required this.left,
    required this.right,
    required this.breakpoint,
    required this.gap,
  });

  final Widget left;
  final Widget right;
  final double breakpoint;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final oneCol = c.maxWidth < breakpoint;

        if (oneCol) {
          return Column(
            children: [
              left,
              SizedBox(height: gap),
              right,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: left),
            SizedBox(width: gap),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Chips de duración
// -----------------------------------------------------------------------------
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
      spacing: 8,
      runSpacing: 8,
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

// -----------------------------------------------------------------------------
// Dropdown con catálogo (mismo look que AppTextField)
// -----------------------------------------------------------------------------
class DropdownCatalogField extends StatefulWidget {
  const DropdownCatalogField({
    super.key,
    required this.ui,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.endpoint,
    required this.loader,
  });

  final FieldUi ui;
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
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey(); // para capturar ancho real del campo

  List<String>? _items;
  bool _loading = false;
  String? _error;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();

    // Si el user empieza a escribir, deja de forzar showAll
    widget.controller.addListener(() {
      if (_showAll && _focusNode.hasFocus) {
        setState(() => _showAll = false);
      }
    });

    // Al ganar foco, carga catálogo si hace falta
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) _ensureData();
    });

        
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _ensureData() async {
    if (_items != null || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await widget.loader(widget.endpoint);
      if (!mounted) return;
      setState(() => _items = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      _items = const [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Iterable<String> _filterOptions(TextEditingValue value) {
    final items = _items ?? const <String>[];
    if (_loading || _error != null) return const Iterable<String>.empty();

    final q = value.text.trim().toLowerCase();

    if (_showAll || q.isEmpty) return items.take(40);
    return items.where((e) => e.toLowerCase().contains(q)).take(40);
  }

  // Ancho actual del TextField para que el overlay no desborde
  double _fieldWidth() {
    final ctx = _fieldKey.currentContext;
    if (ctx == null) return 260;
    final r = ctx.findRenderObject();
    if (r is RenderBox && r.hasSize) return r.size.width;
    return 260;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = widget.ui;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MISMO label que AppTextField
        Text(widget.label, style: theme.textTheme.labelLarge),
        SizedBox(height: ui.labelGap),

        RawAutocomplete<String>(
          textEditingController: widget.controller,
          focusNode: _focusNode,
          displayStringForOption: (o) => o,
          optionsBuilder: _filterOptions,
          onSelected: (opt) {
            widget.controller.text = opt;
            widget.controller.selection =
                TextSelection.collapsed(offset: opt.length);

            // Mantener foco => evita bugs de teclado en algunos Android
            Future.microtask(() {
              if (_focusNode.canRequestFocus) _focusNode.requestFocus();
            });
          },
          fieldViewBuilder: (ctx, textCtrl, focusNode, onFieldSubmitted) {
            return KeyedSubtree(
              key: _fieldKey,
              child: TextField(
                controller: textCtrl,
                focusNode: focusNode,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hint,

                  // Icono con tamaño fijo y caja fija => spacing consistente
                  prefixIcon: Icon(widget.icon, size: ui.iconSize),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: ui.prefixIconMinWidth,
                    minHeight: ui.prefixIconMinWidth,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ui.radius),
                  ),
                  contentPadding: ui.contentPadding,

                  // Suffix consistente (sin padding raro)
                  suffixIcon: SizedBox(
                    width: ui.suffixIconBox,
                    height: ui.suffixIconBox,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      onPressed: () async {
                        await _ensureData();
                        if (focusNode.canRequestFocus) {
                          focusNode.requestFocus();
                        }
                        setState(() => _showAll = true);

                        final cur = textCtrl.text;
                        textCtrl.value = TextEditingValue(
                          text: cur,
                          selection:
                              TextSelection.collapsed(offset: cur.length),
                        );
                      },
                    ),
                  ),
                ),
                onTap: () => setState(() => _showAll = true),
              ),
            );
          },
          optionsViewBuilder: (ctx, onSelected, options) {
            final w = _fieldWidth();

            Widget child;
            if (_loading) {
              child = const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (_error != null) {
              child = Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Error: $_error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            } else if ((_items?.isEmpty ?? true)) {
              child = const SizedBox(
                height: 80,
                child: Center(child: Text('Sin resultados')),
              );
            } else {
              final list = options.toList();
              child = ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final opt = list[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      opt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelected(opt),
                  );
                },
              );
            }

            // Overlay del ancho exacto del campo (no overflow)
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: w,
                    maxWidth: w,
                    maxHeight: 280,
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
