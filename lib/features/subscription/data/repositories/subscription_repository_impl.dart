import '../../domain/repositories/subscription_repository.dart';
import '../data_sources/subscription_service.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionService service;

  SubscriptionRepositoryImpl({required this.service});

  @override
  Future<SubscriptionHistory> getSubscriptionHistory() {
    return service.getSubscriptionHistory();
  }

  @override
  Future<SubscriptionListResponse> getSubscriptionPlans(
      {int page = 1, int limit = 10}) {
    return service.getSubscriptionPlans(page: page, limit: limit);
  }

  @override
  Future<String> createOrder({required String planId}) {
    return service.createOrder(planId: planId);
  }

  @override
  Future<bool> purchasePlan(
      {required String planId,
      required String razorpayPaymentId,
      required int amount}) {
    return service.purchasePlan(
        planId: planId, razorpayPaymentId: razorpayPaymentId, amount: amount);
  }
}
