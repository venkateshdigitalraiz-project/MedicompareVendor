import '../entities/delivery_analytics_entity.dart';

abstract class DeliveryAnalyticsRepository {
  Future<DeliveryAnalyticsEntity> getDeliveryAnalytics({String range = '7days'});
}
