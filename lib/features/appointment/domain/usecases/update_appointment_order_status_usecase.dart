import '../repositories/appointment_repository.dart';

class UpdateAppointmentOrderStatusUseCase {
  final AppointmentRepository repository;

  UpdateAppointmentOrderStatusUseCase(this.repository);

  Future<void> call({
    required String orderId,
    required String orderStatus,
  }) async {
    return await repository.updateOrderStatus(
      orderId: orderId,
      orderStatus: orderStatus,
    );
  }
}
