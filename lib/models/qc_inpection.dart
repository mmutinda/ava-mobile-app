class Vehicle {
  final String model;
  final String vin;
  final String lot;
  final String job;
  final int unitRemaining;

  Vehicle({
    required this.model,
    required this.vin,
    required this.lot,
    required this.job,
    required this.unitRemaining,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      model: json['model'],
      vin: json['vin'],
      lot: json['lot'],
      job: json['job'],
      unitRemaining: json['unitRemaining'],
    );
  }
}
