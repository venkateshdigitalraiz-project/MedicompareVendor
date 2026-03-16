import '../../domain/entities/pincode_entity.dart';
import '../../domain/repositories/pincodes_repository.dart';
import '../data_sources/pincodes_remote_data_source.dart';

class PincodesRepositoryImpl implements PincodesRepository {
  final PincodesRemoteDataSource remoteDataSource;

  PincodesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PincodeDataEntity>> getPincodes() async {
    return await remoteDataSource.getPincodes();
  }

  @override
  Future<void> createPincode({
    required String pincode,
    required String estimatedDelivery,
    required String status,
  }) async {
    return await remoteDataSource.createPincode(
      pincode: pincode,
      estimatedDelivery: estimatedDelivery,
      status: status,
    );
  }

  @override
  Future<void> updatePincode({
    required String id,
    required String pincode,
    required String estimatedDelivery,
    required String status,
  }) async {
    return await remoteDataSource.updatePincode(
      id: id,
      pincode: pincode,
      estimatedDelivery: estimatedDelivery,
      status: status,
    );
  }

  @override
  Future<void> deletePincode(String id) async {
    return await remoteDataSource.deletePincode(id);
  }
}
