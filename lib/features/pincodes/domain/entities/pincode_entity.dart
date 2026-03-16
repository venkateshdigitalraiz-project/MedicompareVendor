class PincodeDataEntity {
  final String id;
  final String vendorId;
  final String pincodeId;
  final String estimatedDelivery;
  final String status;
  final DateTime createdAt;
  final PincodeEntity pincode;

  PincodeDataEntity({
    required this.id,
    required this.vendorId,
    required this.pincodeId,
    required this.estimatedDelivery,
    required this.status,
    required this.createdAt,
    required this.pincode,
  });
}

class PincodeEntity {
  final String id;
  final String name;
  final String status;

  PincodeEntity({
    required this.id,
    required this.name,
    required this.status,
  });
}
