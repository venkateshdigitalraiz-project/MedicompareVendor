import '../../domain/entities/delivery_order_entity.dart';
import '../../domain/repositories/delivery_orders_repository.dart';
import '../datasources/delivery_orders_remote_data_source.dart';

class DeliveryOrdersRepositoryImpl implements DeliveryOrdersRepository {
  final DeliveryOrdersRemoteDataSource remoteDataSource;

  DeliveryOrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DeliveryOrdersResponseEntity> getDeliveryOrders({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    return await remoteDataSource.getDeliveryOrders(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }
}
