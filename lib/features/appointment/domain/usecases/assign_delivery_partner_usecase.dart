import '../repositories/appointment_repository.dart';

class AssignDeliveryPartnerUseCase {
  final AppointmentRepository repository;

  AssignDeliveryPartnerUseCase(this.repository);

  Future<void> call({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'vendor',
    String deliveryPartner = 'self',
    String? readyTime,
  }) async {
    return await repository.assignDeliveryPartner(
      orderId: orderId,
      deliveryPartnerId: deliveryPartnerId,
      deliveryManType: deliveryManType,
      deliveryPartner: deliveryPartner,
      readyTime: readyTime,
    );
  }
}
