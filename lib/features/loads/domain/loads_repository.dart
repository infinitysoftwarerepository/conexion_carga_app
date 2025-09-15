import 'entities.dart';

abstract class LoadsRepository {
  Future<List<Trip>> fetchTrips({String? ownerUserId, TripStatus? status, int page = 1, int pageSize = 20});
  Future<List<Department>> fetchDepartments();
  Future<List<City>> fetchCities();
  Future<List<TipoCarga>> fetchTiposCarga();
  Future<List<TipoVehiculo>> fetchTiposVehiculo();
  Future<List<Comercial>> fetchComerciales();
  Future<List<Empresa>> fetchEmpresas();
}

// Puedes crear un enum de estado del viaje
enum TripStatus { active, completed, cancelled }
