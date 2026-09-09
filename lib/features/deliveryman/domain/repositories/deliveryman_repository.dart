import '../entities/deliveryman_entity.dart';
import '../entities/create_deliveryman_entity.dart';

abstract class DeliverymanRepository {
  Future<DeliverymanListResponseEntity> getDeliverymen({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  });

  Future<bool> createDeliveryman(CreateDeliverymanEntity entity);

  Future<bool> deleteDeliveryman(String id);
}
