import '../repositories/slots_repository.dart';

class DeleteVacationUseCase {
  final SlotsRepository repository;

  DeleteVacationUseCase(this.repository);

  Future<bool> call(String id) {
    return repository.deleteVacation(id);
  }
}
