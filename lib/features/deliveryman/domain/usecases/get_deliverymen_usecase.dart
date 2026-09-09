import '../entities/deliveryman_entity.dart';
import '../repositories/deliveryman_repository.dart';

class GetDeliverymenUseCase {
  final DeliverymanRepository repository;

  GetDeliverymenUseCase(this.repository);

  Future<DeliverymanListResponseEntity> call({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    return await repository.getDeliverymen(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }
}
