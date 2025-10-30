// lib/features/loads/domain/trip.dart
import 'dart:convert';

class Trip {
  final String id;

  // Campos de la carga
  final String origin;                 // origen
  final String destination;            // destino
  final double tons;                   // peso
  final String cargoType;              // tipo_carga
  final String vehicle;                // tipo_vehiculo (o vehiculo_id como fallback)
  final int price;                     // valor

  final String? notes;                 // observaciones
  final String? contacto;              // contacto
  final String? comercialName;         // comercial (texto libre)
  final String comercialId;            // comercial_id

  final DateTime fechaSalida;          // fecha_salida
  final DateTime? fechaLlegadaEstimada;// fecha_llegada_estimada
  final DateTime createdAt;            // created_at

  final String estado;                 // 'publicado' | 'caducado' | 'eliminado'...
  final bool activo;                   // true/false
  final bool premium;                  // premium_trip

  const Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.tons,
    required this.cargoType,
    required this.vehicle,
    required this.price,
    required this.comercialId,
    required this.fechaSalida,
    required this.createdAt,
    required this.estado,
    required this.activo,
    required this.premium,
    this.fechaLlegadaEstimada,
    this.notes,
    this.contacto,
    this.comercialName,
  });

  factory Trip.fromJson(Map<String, dynamic> j) {
    double _asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }

    int _asInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    DateTime? _asDT(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    final peso = _asDouble(j['peso']);
    final veh = (j['tipo_vehiculo'] ?? j['vehiculo_id'] ?? '').toString();

    return Trip(
      id: j['id'].toString(),
      origin: (j['origen'] ?? '').toString(),
      destination: (j['destino'] ?? '').toString(),
      tons: peso,
      cargoType: (j['tipo_carga'] ?? '').toString(),
      vehicle: veh,
      price: _asInt(j['valor']),
      notes: (j['observaciones'] ?? '').toString().trim().isEmpty
          ? null
          : j['observaciones'].toString(),
      contacto: j['contacto']?.toString(),
      comercialName: j['comercial']?.toString(),
      comercialId: (j['comercial_id'] ?? '').toString(),
      fechaSalida: _asDT(j['fecha_salida']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      fechaLlegadaEstimada: _asDT(j['fecha_llegada_estimada']),
      createdAt: _asDT(j['created_at']) ?? DateTime.now(),
      estado: (j['estado'] ?? (j['activo'] == true ? 'publicado' : 'caducado')).toString(),
      activo: j['activo'] == true,
      premium: j['premium_trip'] == true,
    );
  }

  static List<Trip> listFromResponse(String body) {
    final data = jsonDecode(body);
    if (data is List) {
      return data.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => Trip.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const <Trip>[];
  }

  // Helpers para UI
  bool get isMine => comercialId.isNotEmpty; // el check real lo haces con tu user.id
  bool get isExpired => estado.toLowerCase() != 'publicado' || !activo;

  /// Tiempo restante de “publicado” (24h desde createdAt).
  Duration get timeLeft {
    final deadline = createdAt.add(const Duration(hours: 24));
    return deadline.difference(DateTime.now());
  }
}
