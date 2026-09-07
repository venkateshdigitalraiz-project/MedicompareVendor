import '../../../appointment/domain/entities/delivery_partner_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderDeliveryPartnersUseCase {
  final OrdersRepository repository;

  GetOrderDeliveryPartnersUseCase(this.repository);

  Future<DeliveryPartnersResultEntity> call({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  }) {
    return repository.getDeliveryPartners(
      deliveryManType: deliveryManType,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }
}
