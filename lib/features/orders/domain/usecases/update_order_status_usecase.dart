import '../repositories/orders_repository.dart';

class UpdateOrderStatusUseCase {
  final OrdersRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<bool> call(String orderItemId, Map<String, dynamic> payload) async {
    return await repository.updateOrderStatus(orderItemId, payload);
  }
}
