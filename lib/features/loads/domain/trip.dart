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

  // 🔵 Opcionales
  final String? comercial;
  final String? contacto;
  final String? conductor;   // 👈 nuevo

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
    this.conductor, // 👈 nuevo
  });

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
      // 🔵 nuevos
      comercial: (json['comercial'] ?? '').toString(),
      contacto: (json['contacto'] ?? '').toString(),
      conductor:
          (json['conductor'] ?? json['driver'] ?? '').toString(), // 👈 nuevo
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
        // 🔵 nuevos
        'comercial': comercial,
        'contacto': contacto,
        'conductor': conductor, // 👈 nuevo
      };
}
