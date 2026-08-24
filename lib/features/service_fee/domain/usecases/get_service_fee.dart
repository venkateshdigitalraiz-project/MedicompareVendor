import '../../../../core/error/failures.dart';
import '../entities/service_fee.dart';
import '../repositories/service_fee_repository.dart';

class GetServiceFee {
  final ServiceFeeRepository repository;

  GetServiceFee(this.repository);

  Future<Either<Failure, ServiceFee>> call() {
    return repository.getServiceFee();
  }
}
