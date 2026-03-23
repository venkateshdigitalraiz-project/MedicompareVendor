import '../entities/ambulance_entity.dart';
import '../repositories/ambulance_repository.dart';

class GetAmbulanceDetailsUseCase {
  final AmbulanceRepository repository;

  GetAmbulanceDetailsUseCase(this.repository);

  Future<AmbulanceEntity> call(String id) {
    return repository.getAmbulanceDetails(id);
  }
}
