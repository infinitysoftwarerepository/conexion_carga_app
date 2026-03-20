class TripSharePayload {
  final String origin;
  final String destination;
  final String weight;
  final String cargoType;
  final String vehicleType;
  final String price;
  final String company;
  final String observations;
  final String commercial;
  final String contact;
  final String statusText;

  const TripSharePayload({
    required this.origin,
    required this.destination,
    required this.weight,
    required this.cargoType,
    required this.vehicleType,
    required this.price,
    required this.company,
    required this.observations,
    required this.commercial,
    required this.contact,
    required this.statusText,
  });
}