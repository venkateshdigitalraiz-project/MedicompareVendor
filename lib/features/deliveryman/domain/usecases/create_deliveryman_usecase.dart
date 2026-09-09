import '../entities/create_deliveryman_entity.dart';
import '../repositories/deliveryman_repository.dart';

class CreateDeliverymanUseCase {
  final DeliverymanRepository repository;

  CreateDeliverymanUseCase(this.repository);

  Future<bool> call(CreateDeliverymanEntity entity) async {
    return await repository.createDeliveryman(entity);
  }
}
