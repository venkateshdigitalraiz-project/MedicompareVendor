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
    final candidateEndpoints = [
      ApiEndpoints.leadsSubscriptionCreateOrder,
      '/vendor/leads-subscription/create-order',
      '/vendor/leads-subscription/order/create',
      '/vendor/leads-subscription/create_order',
      '/vendor/payment/create-order',
    ];

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await apiService.post(
          endpoint,
          body: {
            'amount': amount,
            'currency': currency,
            'receipt': receipt,
          },
        );
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final orderId = (decoded['data'] as Map<String, dynamic>?)?['orderId'] ??
              (decoded['data'] as Map<String, dynamic>?)?['id'] ??
              decoded['orderId'];
          if (orderId != null && orderId.toString().isNotEmpty) {
            return orderId.toString();
          }
        }
      } catch (e) {
        // If 404 router not found, attempt next endpoint or fallback
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('router not found') ||
            errStr.contains('not found') ||
            errStr.contains('404')) {
          continue;
        }
      }
    }

    // Direct standard Razorpay checkout fallback (does not require pre-created order ID)
    return '';
  }

  Future<bool> purchasePlan(
      {required String planId,
      required String razorpayPaymentId,
      required int amount}) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.leadsSubscriptionPurchase,
        body: {
          'planId': planId,
          'razorpayPaymentId': razorpayPaymentId,
          'amount': amount,
        },
      );
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        return true;
      }
      throw Exception(decoded['message'] ?? 'Failed to complete plan purchase');
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('router not found') || errStr.contains('404')) {
        // Try alternate purchase endpoints
        final fallbackEndpoints = [
          '/vendor/leads-subscription/buy',
          '/vendor/leads-subscription/verify',
        ];
        for (final ep in fallbackEndpoints) {
          try {
            final response = await apiService.post(
              ep,
              body: {
                'planId': planId,
                'razorpayPaymentId': razorpayPaymentId,
                'amount': amount,
              },
            );
            final decoded = jsonDecode(response.body);
            if (decoded['success'] == true) return true;
          } catch (_) {}
        }
      }
      rethrow;
    }
  }
}
