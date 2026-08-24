// import '../entities/order_entity.dart';
import '../entities/order_details_response_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailsUseCase {
  final OrdersRepository repository;

  GetOrderDetailsUseCase(this.repository);

  Future<OrderDetailsResponseEntity> call(String orderId,
      {String orderType = 'normal'}) async {
    return await repository.getOrderDetails(orderId, orderType: orderType);
  }
}
