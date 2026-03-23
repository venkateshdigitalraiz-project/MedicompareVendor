import '../repositories/ambulance_repository.dart';

class CreateAmbulanceUseCase {
  final AmbulanceRepository repository;

  CreateAmbulanceUseCase(this.repository);

  Future<void> call(Map<String, dynamic> payload) {
    return repository.createAmbulance(payload);
  }
}
