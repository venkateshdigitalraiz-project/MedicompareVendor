import '../entities/ambulance_order_entity.dart';
import '../repositories/ambulance_orders_repository.dart';

class GetAmbulanceOrderDetailsUseCase {
  final AmbulanceOrdersRepository repository;

  GetAmbulanceOrderDetailsUseCase(this.repository);

  Future<AmbulanceOrderEntity> call(String id) {
    return repository.getOrderDetails(id);
  }
}
