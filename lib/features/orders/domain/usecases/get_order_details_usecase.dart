import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailsUseCase {
  final OrdersRepository repository;

  GetOrderDetailsUseCase(this.repository);

  Future<OrderItemEntity> call(String orderId) async {
    return await repository.getOrderDetails(orderId);
  }
}
