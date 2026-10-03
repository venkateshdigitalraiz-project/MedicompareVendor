import '../repositories/appointment_repository.dart';

class UpdateAppointmentOrderStatusUseCase {
  final AppointmentRepository repository;

  UpdateAppointmentOrderStatusUseCase(this.repository);

  Future<void> call({
    required String orderId,
    required String orderStatus,
    String? rejectionReason,
    String? otp,
    String? deliveryOtp,
  }) async {
    return await repository.updateOrderStatus(
      orderId: orderId,
      orderStatus: orderStatus,
      rejectionReason: rejectionReason,
      otp: otp,
      deliveryOtp: deliveryOtp,
    );
  }
}
