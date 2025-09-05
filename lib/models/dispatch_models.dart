class CompleteUnit {
  final String? vehicleId;
  final String? chassisNo;
  final String? engineNo;
  final String? model;
  final String? completionDate;
  final String? status;

  CompleteUnit({
    this.vehicleId,
    this.chassisNo,
    this.engineNo,
    this.model,
    this.completionDate,
    this.status,
  });

  factory CompleteUnit.fromJson(Map<String, dynamic> json) {
    return CompleteUnit(
      vehicleId: json['vehicle_id']?.toString(),
      chassisNo: json['chassis_no']?.toString(),
      engineNo: json['engine_no']?.toString(),
      model: json['model']?.toString(),
      completionDate: json['completion_date']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'chassis_no': chassisNo,
      'engine_no': engineNo,
      'model': model,
      'completion_date': completionDate,
      'status': status,
    };
  }
}

class MovementHistory {
  final int? id;
  final String? currentPosition;
  final int? vehicleId;
  final int? shopId;
  final int? currentShop;
  final int? routeId;
  final int? routeNumber;
  final String? datetimeIn;
  final String? datetimeOut;
  final String? doneBy;
  final String? status;
  final int? appuserId;
  final String? stdHrs;
  final String? createdAt;
  final String? updatedAt;
  final Shop? shop;
  final User? user;

  MovementHistory({
    this.id,
    this.currentPosition,
    this.vehicleId,
    this.shopId,
    this.currentShop,
    this.routeId,
    this.routeNumber,
    this.datetimeIn,
    this.datetimeOut,
    this.doneBy,
    this.status,
    this.appuserId,
    this.stdHrs,
    this.createdAt,
    this.updatedAt,
    this.shop,
    this.user,
  });

  factory MovementHistory.fromJson(Map<String, dynamic> json) {
    return MovementHistory(
      id: json['id']?.toInt(),
      currentPosition: json['current_position']?.toString(),
      vehicleId: json['vehicle_id']?.toInt(),
      shopId: json['shop_id']?.toInt(),
      currentShop: json['current_shop']?.toInt(),
      routeId: json['route_id']?.toInt(),
      routeNumber: json['route_number']?.toInt(),
      datetimeIn: json['datetime_in']?.toString(),
      datetimeOut: json['datetime_out']?.toString(),
      doneBy: json['done_by']?.toString(),
      status: json['status']?.toString(),
      appuserId: json['appuser_id']?.toInt(),
      stdHrs: json['std_hrs']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'current_position': currentPosition,
      'vehicle_id': vehicleId,
      'shop_id': shopId,
      'current_shop': currentShop,
      'route_id': routeId,
      'route_number': routeNumber,
      'datetime_in': datetimeIn,
      'datetime_out': datetimeOut,
      'done_by': doneBy,
      'status': status,
      'appuser_id': appuserId,
      'std_hrs': stdHrs,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'shop': shop?.toJson(),
      'user': user?.toJson(),
    };
  }
}

class Shop {
  final int? id;
  final String? shopName;
  final int? shopNo;
  final String? reportName;
  final int? checkShop;
  final int? checkPoint;
  final String? colorCode;
  final String? createdAt;
  final String? updatedAt;

  Shop({
    this.id,
    this.shopName,
    this.shopNo,
    this.reportName,
    this.checkShop,
    this.checkPoint,
    this.colorCode,
    this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id']?.toInt(),
      shopName: json['shop_name']?.toString(),
      shopNo: json['shop_no']?.toInt(),
      reportName: json['report_name']?.toString(),
      checkShop: json['check_shop']?.toInt(),
      checkPoint: json['check_point']?.toInt(),
      colorCode: json['color_code']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'shop_no': shopNo,
      'report_name': reportName,
      'check_shop': checkShop,
      'check_point': checkPoint,
      'color_code': colorCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class User {
  final int? id;
  final int? shopId;
  final String? phoneNo;
  final String? name;
  final String? staffNo;
  final String? email;
  final String? username;
  final String? userType;
  final int? clientId;
  final int? status;
  final String? deviceToken;

  User({
    this.id,
    this.shopId,
    this.phoneNo,
    this.name,
    this.staffNo,
    this.email,
    this.username,
    this.userType,
    this.clientId,
    this.status,
    this.deviceToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toInt(),
      shopId: json['shop_id']?.toInt(),
      phoneNo: json['phone_no']?.toString(),
      name: json['name']?.toString(),
      staffNo: json['staff_no']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      userType: json['user_type']?.toString(),
      clientId: json['client_id']?.toInt(),
      status: json['status']?.toInt(),
      deviceToken: json['device_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'phone_no': phoneNo,
      'name': name,
      'staff_no': staffNo,
      'email': email,
      'username': username,
      'user_type': userType,
      'client_id': clientId,
      'status': status,
      'device_token': deviceToken,
    };
  }
}

class RoutingHistory {
  final String? routeName;
  final String? destination;
  final String? startTime;
  final String? endTime;
  final String? distance;
  final String? duration;
  final String? status;

  RoutingHistory({
    this.routeName,
    this.destination,
    this.startTime,
    this.endTime,
    this.distance,
    this.duration,
    this.status,
  });

  factory RoutingHistory.fromJson(Map<String, dynamic> json) {
    return RoutingHistory(
      routeName: json['route_name']?.toString(),
      destination: json['destination']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      distance: json['distance']?.toString(),
      duration: json['duration']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_name': routeName,
      'destination': destination,
      'start_time': startTime,
      'end_time': endTime,
      'distance': distance,
      'duration': duration,
      'status': status,
    };
  }
}
