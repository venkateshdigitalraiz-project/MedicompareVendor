import '../repositories/ambulance_repository.dart';

class UpdateAmbulanceUseCase {
  final AmbulanceRepository repository;

  UpdateAmbulanceUseCase(this.repository);

  Future<void> call(String id, Map<String, dynamic> payload) {
    return repository.updateAmbulance(id, payload);
  }
}
