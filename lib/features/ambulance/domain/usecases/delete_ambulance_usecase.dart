import '../repositories/ambulance_repository.dart';

class DeleteAmbulanceUseCase {
  final AmbulanceRepository repository;

  DeleteAmbulanceUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteAmbulance(id);
  }
}
