// lib/features/loads/presentation/pages/checklist/models/checklist_models.dart

class DocCheck {
  DocCheck({
    required this.nombre,
    this.tiene = false,
    this.vigente,
    this.fechaVencimiento,
    this.comentarios = '',
  });

  final String nombre;
  bool tiene;
  bool? vigente; // true/false/null
  DateTime? fechaVencimiento;
  String comentarios;
}

enum TriOption { cumple, noCumple, noAplica }

class CheckItem {
  CheckItem(this.titulo, {this.valor});
  final String titulo;
  TriOption? valor;
}

class ChecklistState {
  // Paso 1
  DateTime? fecha;
  String placa = '';
  String tipoVehiculo = '';
  String color = '';

  // Paso 2 (docs)
  final List<DocCheck> documentos = [
    DocCheck(nombre: 'Licencia de conducción'),
    DocCheck(nombre: 'Licencia de Tránsito o Matrícula Vehículo'),
    DocCheck(nombre: 'Licencia de Tránsito o Matrícula Tráiler (si aplica)'),
    DocCheck(nombre: 'Tecnomecánica'),
    DocCheck(nombre: 'SOAT'),
    DocCheck(nombre: 'Seguridad social'),
    DocCheck(nombre: 'Seguro de daños y/o RCE'),
  ];

  // Paso 3 (espacios ocultos)
  final Map<String, bool> espaciosOcultos = {
    'Espacios donde van las piñas que sujetan los contenedores (si aplica)': false,
    'Tanques de combustible': false,
    'Depuradores de aire (filtros)': false,
    'Piso, tornamesa y vigía del tráiler (si aplica)': false,
    'Techo, desagües, unidad de frío, lados y puertas': false,
    'Quinta rueda (si aplica)': false,
    'Portabaterías o cajas de baterías, bodegas y porta repuestos': false,
    'Tablero de cabina o mandos': false,
    'Bodega interna de la cabina': false,
    'Camarote (si aplica)': false,
    'Porta espejos': false,
    'Tanques de aire': false,
    'Punteras del bomper': false,
    'Chasis': false,
  };

  // Paso 4 (componentes con CUMPLE/NO/NA)
  final List<CheckItem> componentes = [
    CheckItem('Profundidad del labrado y presión de llantas (incluye repuesto)'),
    CheckItem('Plumillas en buen estado'),
    CheckItem('Pitos de mano y reversa. Responden adecuadamente'),
    CheckItem('Niveles de fluidos adecuados. No muestra fugas'),
    CheckItem('Luces internas y externas. Incluye direccionales'),
    CheckItem('Frenos en buen funcionamiento (principal, tráiler, seguridad)'),
    CheckItem('Espejos retrovisores en buen estado'),
    CheckItem('Cinturón de seguridad en buenas condiciones'),
    CheckItem('Equipo de carretera (caja herramientas, gato, conos, linterna, kit derrame, etc.)'),
    CheckItem('Elementos de protección personal (chaleco, casco, botas de seguridad)'),
    CheckItem('Extintores vigentes, en buen estado, presión indicada, tipo ABC'),
  ];

  // Paso 5
  String comentarioGeneral = '';
  String nombreConductor = '';
  String cedulaConductor = '';
}
