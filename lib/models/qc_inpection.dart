class Vehicle {
  final String model;
  final customer_name;
  final String vin;
  final String id;
  final String lot;
  final String created_at;
  final String job;
  final String route;
  final String component_moved;
  final String cabin_cockpit_moved;
  final String chasis_moved;
  final unitRemaining;

  Vehicle({
    required this.model,
    required this.customer_name,
    required this.vin,
    required this.id,
    required this.lot,
    required this.created_at,
    required this.job,
    required this.route,
    required this.component_moved,
    required this.cabin_cockpit_moved,
    required this.chasis_moved,
    required this.unitRemaining,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      model: json['model']['model_name'].toString(),
      customer_name:
          json['client_id'] != null ? json['client']['name'].toString() : null,
      vin: json['vin_no'].toString(),
      id: json['id'].toString(),
      lot: json['lot_no'].toString(),
      created_at: json['created_at'].toString(),
      job: json['job_no'].toString(),
      route: json['route'].toString(),
      component_moved: json['component_moved'].toString(),
      cabin_cockpit_moved: json['cabin_cockpit_moved'].toString(),
      chasis_moved: json['chasis_moved'].toString(),
      unitRemaining: json['component_moved'].toString(),
    );
  }
}

class Vehicle2 {
  final String model;
  final String vin;
  final String lot;
  final String job;
  final String component_moved;
  final String cabin_cockpit_moved;
  final String chasis_moved;
  final unitRemaining;

  Vehicle2({
    required this.model,
    required this.vin,
    required this.lot,
    required this.job,
    required this.component_moved,
    required this.cabin_cockpit_moved,
    required this.chasis_moved,
    required this.unitRemaining,
  });

  factory Vehicle2.fromJson(Map<String, dynamic> json) {
    return Vehicle2(
      model: json['vehicle']['model']['model_name'].toString(),
      vin: json['vehicle']['vin_no'].toString(),
      lot: json['vehicle']['lot_no'].toString(),
      job: json['vehicle']['job_no'].toString(),
      component_moved: json['vehicle']['component_moved'].toString(),
      cabin_cockpit_moved: json['vehicle']['cabin_cockpit_moved'].toString(),
      chasis_moved: json['vehicle']['chasis_moved'].toString(),
      unitRemaining: json['vehicle']['component_moved'].toString(),
    );
  }
}

class AuditsHome {
  final id;
  final String vehicle_type;
  final String title;
  final String description;
  final String audit_time;
  final String position;
  var queries;
  final auditdone;

  AuditsHome({
    required this.id,
    required this.vehicle_type,
    required this.title,
    required this.description,
    required this.audit_time,
    required this.position,
    required this.queries,
    required this.auditdone,
  });

  factory AuditsHome.fromJson(Map<String, dynamic> json) {
    return AuditsHome(
      id: json['id'].toString(),
      vehicle_type: json['vehicle_type'].toString(),
      title: json['title'].toString(),
      audit_time: json['audit_time'].toString(),
      position: json['position'].toString(),
      description: json['description'].toString(),
      queries: json['queries'],
      auditdone: json['auditdone'],
    );
  }
}
