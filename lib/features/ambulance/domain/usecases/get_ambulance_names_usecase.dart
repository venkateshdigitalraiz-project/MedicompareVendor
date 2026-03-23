import '../entities/ambulance_entity.dart';
import '../repositories/ambulance_repository.dart';

class GetAmbulanceNamesUseCase {
  final AmbulanceRepository repository;

  GetAmbulanceNamesUseCase(this.repository);

  Future<List<AmbulanceNameOptionEntity>> call(String query) {
    return repository.getAmbulanceNames(query);
  }
}
