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
}
