import '../entities/appointment_details_entity.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentDetailsUseCase {
  final AppointmentRepository repository;

  GetAppointmentDetailsUseCase(this.repository);

  Future<AppointmentDetailsEntity> call(String id) async {
    return await repository.getAppointmentDetails(id);
  }
}
