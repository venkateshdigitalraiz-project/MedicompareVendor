import '../datasources/orders_remote_data_source.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrdersListEntity> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String orderType = 'normal',
  }) async {
    return await remoteDataSource.getOrders(
      page: page,
      limit: limit,
      status: status,
      search: search,
      orderType: orderType,
    );
  }

  @override
  Future<OrderItemEntity> getOrderDetails(String orderId) async {
    return await remoteDataSource.getOrderDetails(orderId);
  }

  @override
  Future<bool> updateOrderStatus(
      String orderItemId, Map<String, dynamic> payload) async {
    return await remoteDataSource.updateOrderStatus(orderItemId, payload);
  }
}
