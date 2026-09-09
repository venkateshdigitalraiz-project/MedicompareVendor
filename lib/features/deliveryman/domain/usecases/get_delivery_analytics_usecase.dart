import '../entities/delivery_analytics_entity.dart';
import '../repositories/delivery_analytics_repository.dart';

class GetDeliveryAnalyticsUseCase {
  final DeliveryAnalyticsRepository repository;

  GetDeliveryAnalyticsUseCase(this.repository);

  Future<DeliveryAnalyticsEntity> call({String range = '7days'}) async {
    return await repository.getDeliveryAnalytics(range: range);
  }
}
