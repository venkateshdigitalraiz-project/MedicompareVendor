import '../repositories/orders_repository.dart';

class AssignOrderDeliveryPartnerUseCase {
  final OrdersRepository repository;

  AssignOrderDeliveryPartnerUseCase(this.repository);

  Future<void> call({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'admin',
    String deliveryPartner = 'medicompares',
    String? readyTime,
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
