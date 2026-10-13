import '../entities/vendor_vacation_entity.dart';
import '../repositories/slots_repository.dart';

class SaveVacationUseCase {
  final SlotsRepository repository;

  SaveVacationUseCase(this.repository);

  Future<bool> call(VendorVacationEntity entity) {
    return repository.saveVacation(entity);
  }
}
