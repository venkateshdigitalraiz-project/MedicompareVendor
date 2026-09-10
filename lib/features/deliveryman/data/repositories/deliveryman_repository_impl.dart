import '../../domain/entities/deliveryman_entity.dart';
import '../../domain/entities/create_deliveryman_entity.dart';
import '../../domain/repositories/deliveryman_repository.dart';
import '../datasources/deliveryman_remote_data_source.dart';

class DeliverymanRepositoryImpl implements DeliverymanRepository {
  final DeliverymanRemoteDataSource remoteDataSource;

  DeliverymanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DeliverymanListResponseEntity> getDeliverymen({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    return await remoteDataSource.getDeliverymen(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }

  @override
  Future<CreateDeliverymanEntity> getDeliverymanById(String id) async {
    return await remoteDataSource.getDeliverymanById(id);
  }

  @override
  Future<bool> createDeliveryman(CreateDeliverymanEntity entity) async {
    return await remoteDataSource.createDeliveryman(entity.toJson());
  }

  @override
  Future<bool> updateDeliveryman(
      String id, CreateDeliverymanEntity entity) async {
    return await remoteDataSource.updateDeliveryman(id, entity.toJson());
  }

  @override
  Future<bool> deleteDeliveryman(String id) async {
    return await remoteDataSource.deleteDeliveryman(id);
  }
}
