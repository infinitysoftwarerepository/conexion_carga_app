import '../domain/entities.dart';

// 🔹 Ejemplo de departamentos
final kDepartments = <Department>[
  Department(id: 'd1', name: 'Antioquia'),
  Department(id: 'd2', name: 'Cundinamarca'),
];

// 🔹 Ejemplo de ciudades
final kCities = <City>[
  City(id: 'c1', name: 'Medellín', departmentId: 'd1'),
  City(id: 'c2', name: 'Bogotá', departmentId: 'd2'),
  City(id: 'c3', name: 'Cartagena', departmentId: 'd1'),
];

// 🔹 Ejemplo de tipos de carga
final kTiposCarga = <TipoCarga>[
  TipoCarga(id: 'tc1', nombre: 'Granel sólido'),
  TipoCarga(id: 'tc2', nombre: 'Contenedor'),
];

// 🔹 Ejemplo de tipos de vehículo
final kTiposVehiculo = <TipoVehiculo>[
  TipoVehiculo(id: 'tv1', nombre: 'Tractocamión sencillo'),
  TipoVehiculo(id: 'tv2', nombre: 'Doble troque'),
];

// 🔹 Ejemplo de comerciales
final kComerciales = <Comercial>[
  Comercial(id: 'com1', nombre: 'David Toro'),
  Comercial(id: 'com2', nombre: 'Jaime Llano'),
];

// 🔹 Ejemplo de empresas
final kEmpresas = <Empresa>[
  Empresa(id: 'e1', razonSocial: 'Transportes GYH'),
  Empresa(id: 'e2', razonSocial: 'Jamar'),
];

// 🔹 Ejemplo de viajes
final kTrips = <Trip>[
  Trip(
    id: 't1',
    origin: kCities[0], // Medellín
    destination: kCities[1], // Bogotá
    tons: 40,
    price: 8500,
    tipoCarga: kTiposCarga[0], // Granel sólido
    tipoVehiculo: kTiposVehiculo[0], // Tractocamión sencillo
    comercial: kComerciales[0], // David Toro
    empresa: kEmpresas[0], // Transportes GYH
  ),
  Trip(
    id: 't2',
    origin: kCities[2], // Cartagena
    destination: kCities[1], // Bogotá
    tons: 56,
    price: 12000,
    tipoCarga: kTiposCarga[1], // Contenedor
    tipoVehiculo: kTiposVehiculo[1], // Doble troque
    comercial: kComerciales[1], // Jaime Llano
    empresa: kEmpresas[1], // Jamar
  ),
];
