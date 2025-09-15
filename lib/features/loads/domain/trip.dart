class Trip {
  final String origin;
  final String destination;
  final double tons;
  final String cargoType;
  final String vehicle;
  final int price;
  final String notes;

  const Trip({
    required this.origin,
    required this.destination,
    required this.tons,
    required this.cargoType,
    required this.vehicle,
    required this.price,
    this.notes = '',
  });
}

const mockTrips = <Trip>[
  Trip(origin: 'Medellín', destination: 'Bogotá',  tons: 40, cargoType: 'Granel sólido', vehicle: 'Tractocamión sencillo', price: 8500000, notes: 'Cargue mañana 7am'),
  Trip(origin: 'Cartagena', destination: 'Bogotá', tons: 56, cargoType: 'Contenedor',    vehicle: 'Doble troque',        price: 12000000, notes: 'Entrega en Zona Franca'),
  Trip(origin: 'Cali', destination: 'Barranquilla', tons: 32, cargoType: 'Paletizado', vehicle: 'Tracto 3 ejes', price: 9200000),
  Trip(origin: 'Bucaramanga', destination: 'Medellín', tons: 28, cargoType: 'Cemento', vehicle: 'Sencillo', price: 6800000),
  Trip(origin: 'Santa Marta', destination: 'Cúcuta', tons: 34, cargoType: 'Carbón', vehicle: 'Patineta', price: 10400000),
  Trip(origin: 'Barrancabermeja', destination: 'Yopal', tons: 25, cargoType: 'Granel líquido', vehicle: 'Cisterna', price: 7600000),
];
