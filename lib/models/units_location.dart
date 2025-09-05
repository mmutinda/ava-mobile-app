// Import the existing Vehicle model for compatibility
import 'package:isuze_pqcs/models/qc_inpection.dart';

class UnitsLocationResponse {
  final int id;
  final String currentPosition;
  final int vehicleId;
  final int shopId;
  final int currentShop;
  final int routeId;
  final int routeNumber;
  final String datetimeIn;
  final String datetimeOut;
  final String doneBy;
  final String? status;
  final int appuserId;
  final String? stdHrs;
  final String? swapId;
  final String? swapReference;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final VehicleInfo vehicle;

  UnitsLocationResponse({
    required this.id,
    required this.currentPosition,
    required this.vehicleId,
    required this.shopId,
    required this.currentShop,
    required this.routeId,
    required this.routeNumber,
    required this.datetimeIn,
    required this.datetimeOut,
    required this.doneBy,
    this.status,
    required this.appuserId,
    this.stdHrs,
    this.swapId,
    this.swapReference,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.vehicle,
  });

  factory UnitsLocationResponse.fromJson(Map<String, dynamic> json) {
    return UnitsLocationResponse(
      id: json['id'],
      currentPosition: json['current_position'] ?? '',
      vehicleId: json['vehicle_id'],
      shopId: json['shop_id'],
      currentShop: json['current_shop'],
      routeId: json['route_id'],
      routeNumber: json['route_number'],
      datetimeIn: json['datetime_in'] ?? '',
      datetimeOut: json['datetime_out'] ?? '',
      doneBy: json['done_by'] ?? '',
      status: json['status'],
      appuserId: json['appuser_id'],
      stdHrs: json['std_hrs'],
      swapId: json['swap_id'],
      swapReference: json['swap_reference'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      vehicle: VehicleInfo.fromJson(json['vehicle']),
    );
  }

  // Convert to the existing Vehicle model for compatibility
  Vehicle toVehicle() {
    return Vehicle(
      model: vehicle.model.modelName,
      customer_name: null, // Not available in this response
      vin: vehicle.vinNo,
      id: vehicle.id.toString(),
      model_id: vehicle.modelId.toString(),
      lot: vehicle.lotNo,
      created_at: vehicle.createdAt,
      job: vehicle.jobNo,
      route: vehicle.route.toString(),
      component_moved: vehicle.componentMoved.toString(),
      cabin_cockpit_moved: vehicle.cabinCockpitMoved.toString(),
      chasis_moved: vehicle.chasisMoved.toString(),
      unitRemaining: vehicle.componentMoved.toString(),
      vehicle_line: vehicle.vehicleLine,
    );
  }

  String calculateAgeing() {
    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdDate);

      if (difference.inDays > 0) {
        return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "Unknown";
    }
  }
}

class VehicleInfo {
  final int id;
  final String lotNo;
  final String vinNo;
  final String engineNo;
  final String jobNo;
  final int clientId;
  final int modelId;
  final String? color;
  final String productionStartDate;
  final String currentShop;
  final int status;
  final int route;
  final String vehicleLine;
  final int totalComponents;
  final int componentMoved;
  final String? productionEndDate;
  final int cabinCockpitMoved;
  final int chasisMoved;
  final int tipperMoved;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int? qfl3Selected;
  final ModelInfo model;

  VehicleInfo({
    required this.id,
    required this.lotNo,
    required this.vinNo,
    required this.engineNo,
    required this.jobNo,
    required this.clientId,
    required this.modelId,
    this.color,
    required this.productionStartDate,
    required this.currentShop,
    required this.status,
    required this.route,
    required this.vehicleLine,
    required this.totalComponents,
    required this.componentMoved,
    this.productionEndDate,
    required this.cabinCockpitMoved,
    required this.chasisMoved,
    required this.tipperMoved,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.qfl3Selected,
    required this.model,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      id: json['id'],
      lotNo: json['lot_no']?.toString() ?? '',
      vinNo: json['vin_no']?.toString() ?? '',
      engineNo: json['engine_no']?.toString() ?? '',
      jobNo: json['job_no']?.toString() ?? '',
      clientId: json['client_id'] ?? 0,
      modelId: json['model_id'] ?? 0,
      color: json['color'],
      productionStartDate: json['production_start_date']?.toString() ?? '',
      currentShop: json['current_shop']?.toString() ?? '',
      status: json['status'] ?? 0,
      route: json['route'] ?? 0,
      vehicleLine: json['vehicle_line']?.toString() ?? '',
      totalComponents: json['total_components'] ?? 0,
      componentMoved: json['component_moved'] ?? 0,
      productionEndDate: json['production_end_date'],
      cabinCockpitMoved: json['cabin_cockpit_moved'] ?? 0,
      chasisMoved: json['chasis_moved'] ?? 0,
      tipperMoved: json['tipper_moved'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deletedAt: json['deleted_at'],
      qfl3Selected: json['qfl3_selected'],
      model: ModelInfo.fromJson(json['model']),
    );
  }
}

class ModelInfo {
  final int id;
  final String modelName;
  final String modelNumber;
  final int clientId;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  ModelInfo({
    required this.id,
    required this.modelName,
    required this.modelNumber,
    required this.clientId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'],
      modelName: json['model_name']?.toString() ?? '',
      modelNumber: json['model_number']?.toString() ?? '',
      clientId: json['client_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deletedAt: json['deleted_at'],
    );
  }
}
