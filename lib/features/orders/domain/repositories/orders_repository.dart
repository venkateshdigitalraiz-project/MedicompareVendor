import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<OrdersListEntity> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String orderType = 'normal',
  });
  Future<OrderItemEntity> getOrderDetails(String orderId,
      {String orderType = 'normal'});
  Future<bool> updateOrderStatus(
      String orderItemId, Map<String, dynamic> payload);
}
