import '../../data/models/subscription_model.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionHistory> getSubscriptionHistory();
  Future<SubscriptionListResponse> getSubscriptionPlans({int page, int limit});
  Future<String> createOrder(
      {required int amount, required String currency, required String receipt});
  Future<bool> purchasePlan(
      {required String planId,
      required String razorpayPaymentId,
      required int amount});
}
