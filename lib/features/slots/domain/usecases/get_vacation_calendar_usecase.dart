import '../entities/vendor_vacation_entity.dart';
import '../repositories/slots_repository.dart';

class GetVacationCalendarUseCase {
  final SlotsRepository repository;

  GetVacationCalendarUseCase(this.repository);

  Future<List<VendorVacationEntity>> call({
    required int month,
    required int year,
  }) {
    return repository.getVacationCalendar(month: month, year: year);
  }
}
