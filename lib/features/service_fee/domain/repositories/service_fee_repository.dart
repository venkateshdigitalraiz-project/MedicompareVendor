import '../../../../core/error/failures.dart';
import '../entities/service_fee.dart';

abstract class ServiceFeeRepository {
  Future<Either<Failure, ServiceFee>> getServiceFee();
  Future<Either<Failure, bool>> updateServiceSettings(Map<String, dynamic> payload);
}
