// lib/features/loads/domain/trip.dart

class Trip {
  final String id;
  final String origin;
  final String destination;
  final double? tons;        // peso
  final String cargoType;    // tipo_carga
  final String vehicle;      // tipo_vehiculo
  final num? price;          // valor (tarifa)
  final String? estado;
  final bool activo;
  final String? comercialId;

  // Opcionales extra
  final String? comercial;
  final String? contacto;
  final String? conductor;

  // Para manejar vencimiento
  final DateTime? createdAt;
  final int? durationHours; // duración elegida en horas (6, 12, 24, etc.)

  Trip({
    required this.id,
    required this.origin,
    required this.destination,
    this.tons,
    required this.cargoType,
    required this.vehicle,
    this.price,
    this.estado,
    this.activo = true,
    this.comercialId,
    this.comercial,
    this.contacto,
    this.conductor,
    this.createdAt,
    this.durationHours,
  });

  /// Fecha/hora exacta de vencimiento
  DateTime? get expiresAt {
    if (createdAt == null || durationHours == null) return null;
    final baseUtc = createdAt!.toUtc();
    return baseUtc.add(Duration(hours: durationHours!));
  }

  /// Tiempo que falta para vencerse a partir de *ahora*
  Duration? get remaining {
    final exp = expiresAt;
    if (exp == null) return null;
    final nowUtc = DateTime.now().toUtc();
    final diff = exp.difference(nowUtc);
    if (diff.isNegative) return Duration.zero;
    return diff;
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.'));
      return null;
    }

    num? _toNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      if (v is String) {
        return num.tryParse(
          v.replaceAll('.', '').replaceAll(',', '.'),
        );
      }
      return null;
    }

    DateTime? _toDateTime(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    int? _parseDurationHours(dynamic raw) {
      if (raw == null) return null;

      if (raw is int) return raw;
      if (raw is num) return raw.toInt();

      if (raw is String) {
        final s = raw.trim();
        if (s.isEmpty) return null;

        // Formatos posibles desde Postgres INTERVAL:
        // "06:00:00"
        // "1 day"
        // "1 day 06:00:00"
        // o directamente "6"
        int days = 0;
        int hours = 0;

        final dayMatch = RegExp(r'(\d+)\s+day').firstMatch(s);
        if (dayMatch != null) {
          days = int.tryParse(dayMatch.group(1)!) ?? 0;
        }

        final timeMatch =
            RegExp(r'(\d{1,2}):(\d{2})(?::(\d{2}))?').firstMatch(s);
        if (timeMatch != null) {
          hours = int.tryParse(timeMatch.group(1)!) ?? 0;
        }

        if (days == 0 && hours == 0) {
          final asInt = int.tryParse(s);
          if (asInt != null) return asInt;
        }

        return days * 24 + hours;
      }

      return null;
    }

    // 🔴 Aquí estaba el problema:
    // antes: json['duration_hours'] ?? json['duracion_publicacion']
    // Si el backend manda duration_hours=24 y duracion_publicacion='06:00:00'
    // nos quedábamos con 24. Ahora preferimos SIEMPRE el interval.
    final durationRaw =
        json['duracion_publicacion'] ?? json['duration_hours'];

    return Trip(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      origin: (json['origen'] ?? json['origin'] ?? '').toString(),
      destination: (json['destino'] ?? json['destination'] ?? '').toString(),
      tons: _toDouble(json['peso'] ?? json['tons'] ?? json['tonelaje']),
      cargoType: (json['tipo_carga'] ?? json['cargoType'] ?? '').toString(),
      vehicle: (json['tipo_vehiculo'] ?? json['vehicle'] ?? '').toString(),
      price: _toNum(json['valor'] ?? json['price'] ?? json['tarifa']),
      estado: (json['estado'] ?? json['status'])?.toString(),
      activo: ((json['activo'] ?? true).toString().toLowerCase() == 'true'),
      comercialId: (json['comercial_id'] ?? json['created_by'])?.toString(),
      comercial: (json['comercial'] ?? '').toString(),
      contacto: (json['contacto'] ?? '').toString(),
      conductor: (json['conductor'] ?? json['driver'] ?? '').toString(),
      createdAt: _toDateTime(json['created_at']),
      durationHours: _parseDurationHours(durationRaw),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'origen': origin,
        'destino': destination,
        'peso': tons,
        'tipo_carga': cargoType,
        'tipo_vehiculo': vehicle,
        'valor': price,
        'estado': estado,
        'activo': activo,
        'comercial_id': comercialId,
        'comercial': comercial,
        'contacto': contacto,
        'conductor': conductor,
        'created_at': createdAt?.toIso8601String(),
        'duration_hours': durationHours,
      };
}
