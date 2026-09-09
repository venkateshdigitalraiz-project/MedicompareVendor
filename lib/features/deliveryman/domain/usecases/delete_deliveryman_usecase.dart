import '../repositories/deliveryman_repository.dart';

class DeleteDeliverymanUseCase {
  final DeliverymanRepository repository;

  DeleteDeliverymanUseCase(this.repository);

  Future<bool> call(String id) async {
    return await repository.deleteDeliveryman(id);
  }
}
