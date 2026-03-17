import '../../data/models/subscription_model.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionHistory> getSubscriptionHistory();
  Future<SubscriptionListResponse> getSubscriptionPlans({int page, int limit});
}
