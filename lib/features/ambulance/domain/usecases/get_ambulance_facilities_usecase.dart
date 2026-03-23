import '../entities/ambulance_entity.dart';
import '../repositories/ambulance_repository.dart';

class GetAmbulanceFacilitiesUseCase {
  final AmbulanceRepository repository;

  GetAmbulanceFacilitiesUseCase(this.repository);

  Future<List<AmbulanceFacilityEntity>> call() {
    return repository.getFacilitiesList();
  }
}
