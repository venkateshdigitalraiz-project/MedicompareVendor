import '../entities/pincode_entity.dart';

abstract class PincodesRepository {
  Future<List<PincodeDataEntity>> getPincodes();
  Future<void> createPincode({
    required String pincode,
    required String estimatedDelivery,
    required String status,
  });
  Future<void> updatePincode({
    required String id,
    required String pincode,
    required String estimatedDelivery,
    required String status,
  });
  Future<void> deletePincode(String id);
}
