import '../entities/delivery_order_entity.dart';

abstract class DeliveryOrdersRepository {
  Future<DeliveryOrdersResponseEntity> getDeliveryOrders({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  });
}
