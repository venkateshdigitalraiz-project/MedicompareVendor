import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  final ApiServiceRepository apiService;

  SubscriptionService({required this.apiService});

  Future<SubscriptionHistory> getSubscriptionHistory() async {
    final response = await apiService.get(ApiEndpoints.leadsSubscriptionHistory);
    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true) {
      return SubscriptionHistory.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? 'Failed to fetch subscription history');
    }
  }

  Future<SubscriptionListResponse> getSubscriptionPlans({int page = 1, int limit = 10}) async {
    final response = await apiService.get(
      ApiEndpoints.leadsSubscriptionList,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    final decoded = jsonDecode(response.body);
    if (decoded['success'] == true) {
      return SubscriptionListResponse.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? 'Failed to fetch subscription plans');
    }
  }
}
