import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/service_fee.dart';
import '../../domain/repositories/service_fee_repository.dart';
import '../datasources/service_fee_remote_data_source.dart';

class ServiceFeeRepositoryImpl implements ServiceFeeRepository {
  final ServiceFeeRemoteDataSource remoteDataSource;

  ServiceFeeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ServiceFee>> getServiceFee() async {
    try {
      final remoteData = await remoteDataSource.getServiceFee();
      return Right(remoteData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
