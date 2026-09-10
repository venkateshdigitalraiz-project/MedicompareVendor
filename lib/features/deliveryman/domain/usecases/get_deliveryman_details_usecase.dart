import '../entities/create_deliveryman_entity.dart';
import '../repositories/deliveryman_repository.dart';

class GetDeliverymanDetailsUseCase {
  final DeliverymanRepository repository;

  GetDeliverymanDetailsUseCase(this.repository);

  Future<CreateDeliverymanEntity> call(String id) async {
    return await repository.getDeliverymanById(id);
  }
}
