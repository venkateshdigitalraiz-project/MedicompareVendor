import '../../domain/entities/pincode_entity.dart';

class PincodeDataModel extends PincodeDataEntity {
  PincodeDataModel({
    required super.id,
    required super.vendorId,
    required super.pincodeId,
    required super.estimatedDelivery,
    required super.status,
    required super.createdAt,
    required super.pincode,
  });

  factory PincodeDataModel.fromJson(Map<String, dynamic> json) {
    return PincodeDataModel(
      id: json['_id'] ?? '',
      vendorId: json['vendorId'] ?? '',
      pincodeId: json['pincodeId'] ?? '',
      estimatedDelivery: json['estimateddelivery'] ?? '',
      status: json['status'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      pincode: PincodeModel.fromJson(json['pincode'] ?? {}),
    );
  }
}

class PincodeModel extends PincodeEntity {
  PincodeModel({
    required super.id,
    required super.name,
    required super.status,
  });

  factory PincodeModel.fromJson(Map<String, dynamic> json) {
    return PincodeModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
