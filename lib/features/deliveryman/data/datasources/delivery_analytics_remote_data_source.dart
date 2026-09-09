import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/delivery_analytics_model.dart';

abstract class DeliveryAnalyticsRemoteDataSource {
  Future<DeliveryAnalyticsModel> getDeliveryAnalytics({String range = '7days'});
}

class DeliveryAnalyticsRemoteDataSourceImpl
    implements DeliveryAnalyticsRemoteDataSource {
  final ApiServiceRepository apiService;

  DeliveryAnalyticsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<DeliveryAnalyticsModel> getDeliveryAnalytics({
    String range = '7days',
  }) async {
    final queryParams = <String, dynamic>{
      'range': range,
    };

    if (kDebugMode) {
      print(
          '[DeliveryAnalyticsRemoteDataSource] GET: ${ApiEndpoints.deliverymanAnalytics} params: $queryParams');
    }

    try {
      final response = await apiService.get(
        ApiEndpoints.deliverymanAnalytics,
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        print(
            '[DeliveryAnalyticsRemoteDataSource] Response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) {
          return const DeliveryAnalyticsModel();
        }

        final decoded = json.decode(response.body);
        if (decoded == null) {
          return const DeliveryAnalyticsModel();
        }

        if (decoded is Map<String, dynamic>) {
          return DeliveryAnalyticsModel.fromJson(decoded);
        } else if (decoded is Map) {
          return DeliveryAnalyticsModel.fromJson(
              Map<String, dynamic>.from(decoded));
        }

        return const DeliveryAnalyticsModel();
      } else {
        String errorMsg =
            'Failed to load delivery analytics (${response.statusCode})';
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map) {
            errorMsg = decoded['message']?.toString() ??
                decoded['error']?.toString() ??
                errorMsg;
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[DeliveryAnalyticsRemoteDataSource] Error: $e');
      }
      rethrow;
    }
  }
}
