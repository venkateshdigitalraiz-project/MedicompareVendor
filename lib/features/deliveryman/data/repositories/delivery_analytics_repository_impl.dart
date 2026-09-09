import '../../domain/entities/delivery_analytics_entity.dart';
import '../../domain/repositories/delivery_analytics_repository.dart';
import '../datasources/delivery_analytics_remote_data_source.dart';

class DeliveryAnalyticsRepositoryImpl implements DeliveryAnalyticsRepository {
  final DeliveryAnalyticsRemoteDataSource remoteDataSource;

  DeliveryAnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DeliveryAnalyticsEntity> getDeliveryAnalytics({
    String range = '7days',
  }) async {
    return await remoteDataSource.getDeliveryAnalytics(range: range);
  }
}
