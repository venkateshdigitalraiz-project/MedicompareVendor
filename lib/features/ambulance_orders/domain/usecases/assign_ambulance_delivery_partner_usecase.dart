import '../repositories/ambulance_orders_repository.dart';

class AssignAmbulanceDeliveryPartnerUseCase {
  final AmbulanceOrdersRepository repository;

  AssignAmbulanceDeliveryPartnerUseCase(this.repository);

  Future<void> call({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'admin',
    String deliveryPartner = 'medicompares',
    String? readyTime = '30',
  }) {
    return repository.assignDeliveryPartner(
      orderId: orderId,
      deliveryPartnerId: deliveryPartnerId,
      deliveryManType: deliveryManType,
      deliveryPartner: deliveryPartner,
      readyTime: readyTime,
    );
  }
}
