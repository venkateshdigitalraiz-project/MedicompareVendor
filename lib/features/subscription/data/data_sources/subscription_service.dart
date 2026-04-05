import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  final ApiServiceRepository apiService;

  SubscriptionService({required this.apiService});

  Future<SubscriptionHistory> getSubscriptionHistory() async {
    final response =
        await apiService.get(ApiEndpoints.leadsSubscriptionHistory);
    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true && decoded['data'] != null) {
      return SubscriptionHistory.fromJson(decoded['data']);
    } else if (decoded['success'] == true) {
      return const SubscriptionHistory(
          planHistory: []); // Return empty history if data is null
    } else {
      throw Exception(
          decoded['message'] ?? 'Failed to fetch subscription history');
    }
  }

  Future<SubscriptionListResponse> getSubscriptionPlans(
      {int page = 1, int limit = 10}) async {
    final response = await apiService.get(
      ApiEndpoints.leadsSubscriptionList,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true && decoded['data'] != null) {
      return SubscriptionListResponse.fromJson(decoded['data']);
    } else if (decoded['success'] == true) {
      return SubscriptionListResponse(
          list: const [],
          pagination: Pagination(
              total: 0,
              page: page,
              limit: limit,
              totalPages: 0,
              hasNextPage: false,
              hasPrevPage: false));
    } else {
      throw Exception(
          decoded['message'] ?? 'Failed to fetch subscription plans');
    }
  }

  Future<String> createOrder(
      {required int amount,
      required String currency,
      required String receipt}) async {
    final response = await apiService.post(
      ApiEndpoints.leadsSubscriptionCreateOrder,
      body: {
        'amount': amount,
        'currency': currency,
        'receipt': receipt,
      },
    );
    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true) {
      // Use null-safe access to avoid crash if data is null
      final orderId = (decoded['data'] as Map<String, dynamic>?)?['orderId'] ??
          decoded['orderId'];
      return orderId?.toString() ?? '';
    } else {
      throw Exception(decoded['message'] ?? 'Failed to create payment order');
    }
  }

  Future<bool> purchasePlan(
      {required String planId,
      required String razorpayPaymentId,
      required int amount}) async {
    final response = await apiService.post(
      ApiEndpoints.leadsSubscriptionPurchase,
      body: {
        'planId': planId,
        'razorpayPaymentId': razorpayPaymentId,
        'amount': amount,
      },
    );
    final decoded = jsonDecode(response.body);
    return decoded['success'] == true;
  }
}
