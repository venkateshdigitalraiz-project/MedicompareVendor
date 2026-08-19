import '../entities/order_entity.dart';
import '../entities/order_details_response_entity.dart';

abstract class OrdersRepository {
  Future<OrdersListEntity> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String orderType = 'normal',
  });
  Future<OrderDetailsResponseEntity> getOrderDetails(String orderId,
      {String orderType = 'normal'});
  Future<bool> updateOrderStatus(
      String orderItemId, Map<String, dynamic> payload);
}
