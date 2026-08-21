import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentsUseCase {
  final AppointmentRepository repository;

  GetAppointmentsUseCase(this.repository);

  Future<AppointmentsListEntity> call({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String branch = '',
  }) {
    return repository.getAppointments(
      page: page,
      limit: limit,
      status: status,
      search: search,
      branch: branch,
    );
  }
}
