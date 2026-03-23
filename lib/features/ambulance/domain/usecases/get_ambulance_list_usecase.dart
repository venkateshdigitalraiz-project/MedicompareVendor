import '../entities/ambulance_entity.dart';
import '../repositories/ambulance_repository.dart';

class GetAmbulanceListUseCase {
  final AmbulanceRepository repository;

  GetAmbulanceListUseCase(this.repository);

  Future<AmbulanceListEntity> call({
    int page = 1,
    int limit = 10,
    String categoryId = '',
    String search = '',
  }) {
    return repository.getAmbulanceList(
      page: page,
      limit: limit,
      categoryId: categoryId,
      search: search,
    );
  }
}
