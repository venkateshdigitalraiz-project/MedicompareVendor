import '../entities/create_deliveryman_entity.dart';
import '../repositories/deliveryman_repository.dart';

class UpdateDeliverymanUseCase {
  final DeliverymanRepository repository;

  UpdateDeliverymanUseCase(this.repository);

  Future<bool> call(String id, CreateDeliverymanEntity entity) async {
    return await repository.updateDeliveryman(id, entity);
  }
}
