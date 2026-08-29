import '../../../../core/error/failures.dart';
import '../repositories/service_fee_repository.dart';

class UpdateServiceFeeSettingsUseCase {
  final ServiceFeeRepository repository;

  UpdateServiceFeeSettingsUseCase(this.repository);

  Future<Either<Failure, bool>> call(Map<String, dynamic> payload) async {
    return await repository.updateServiceSettings(payload);
  }
}
