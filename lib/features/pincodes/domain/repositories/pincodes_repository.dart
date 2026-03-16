import '../entities/pincode_entity.dart';

abstract class PincodesRepository {
  Future<List<PincodeDataEntity>> getPincodes();
}
