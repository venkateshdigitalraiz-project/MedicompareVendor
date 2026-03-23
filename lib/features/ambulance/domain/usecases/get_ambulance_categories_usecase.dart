import '../entities/ambulance_entity.dart';
import '../repositories/ambulance_repository.dart';

class GetAmbulanceCategoriesUseCase {
  final AmbulanceRepository repository;

  GetAmbulanceCategoriesUseCase(this.repository);

  Future<List<AmbulanceCategoryEntity>> call() {
    return repository.getAmbulanceCategories();
  }
}
