import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase {
  final OrdersRepository repository;

  GetOrdersUseCase(this.repository);

  Future<OrdersListEntity> call({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
  }) async {
    final result = await repository.getOrders(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
    return result;
  }
}
