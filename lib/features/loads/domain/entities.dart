class Department {
  final String id;
  final String name;

  Department({required this.id, required this.name});
}

class City {
  final String id;
  final String name;
  final String departmentId;

  City({required this.id, required this.name, required this.departmentId});
}

class TipoCarga {
  final String id;
  final String nombre;

  TipoCarga({required this.id, required this.nombre});
}

class TipoVehiculo {
  final String id;
  final String nombre;

  TipoVehiculo({required this.id, required this.nombre});
}

class Comercial {
  final String id;
  final String nombre;

  Comercial({required this.id, required this.nombre});
}

class Empresa {
  final String id;
  final String razonSocial;

  Empresa({required this.id, required this.razonSocial});
}

class Trip {
  final String id;
  final City origin;
  final City destination;
  final double tons;
  final double price;
  final TipoCarga tipoCarga;
  final TipoVehiculo tipoVehiculo;
  final Comercial comercial;
  final Empresa empresa;

  Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.tons,
    required this.price,
    required this.tipoCarga,
    required this.tipoVehiculo,
    required this.comercial,
    required this.empresa,
  });

  get observacion => null;

  get cargoType => null;

  get vehicle => null;

  get notes => null;
}
