import '../domain/entities.dart';
import '../domain/loads_repository.dart';
import 'mock_data.dart';

class MockLoadsRepository implements LoadsRepository {
  @override
  Future<List<Trip>> fetchTrips({String? ownerUserId, TripStatus? status, int page = 1, int pageSize = 20}) async {
    return kTrips;
  }

  @override
  Future<List<Department>> fetchDepartments() async => kDepartments;

  @override
  Future<List<City>> fetchCities() async => kCities;

  @override
  Future<List<TipoCarga>> fetchTiposCarga() async => kTiposCarga;

  @override
  Future<List<TipoVehiculo>> fetchTiposVehiculo() async => kTiposVehiculo;

  @override
  Future<List<Comercial>> fetchComerciales() async => kComerciales;

  @override
  Future<List<Empresa>> fetchEmpresas() async => kEmpresas;
}
