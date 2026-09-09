import '../entities/delivery_order_entity.dart';
import '../repositories/delivery_orders_repository.dart';

class GetDeliveryOrdersUseCase {
  final DeliveryOrdersRepository repository;

  GetDeliveryOrdersUseCase(this.repository);

  Future<DeliveryOrdersResponseEntity> call({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    return await repository.getDeliveryOrders(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }
}
