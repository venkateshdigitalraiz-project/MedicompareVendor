import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<OrdersListEntity> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
  });
  Future<OrderItemEntity> getOrderDetails(String orderId);
  Future<bool> updateOrderStatus(String orderItemId, Map<String, dynamic> payload);
}
