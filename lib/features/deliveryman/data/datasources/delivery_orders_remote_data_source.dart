import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/delivery_order_model.dart';

abstract class DeliveryOrdersRemoteDataSource {
  Future<DeliveryOrdersResponseModel> getDeliveryOrders({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  });
}

class DeliveryOrdersRemoteDataSourceImpl
    implements DeliveryOrdersRemoteDataSource {
  final ApiServiceRepository apiService;

  DeliveryOrdersRemoteDataSourceImpl({required this.apiService});

  @override
  Future<DeliveryOrdersResponseModel> getDeliveryOrders({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }

    if (kDebugMode) {
      print('[DeliveryOrdersRemoteDataSource] GET: ${ApiEndpoints.deliverymanAllOrders} params: $queryParams');
    }

    final response = await apiService.get(
      ApiEndpoints.deliverymanAllOrders,
      queryParameters: queryParams,
    );

    if (kDebugMode) {
      print('[DeliveryOrdersRemoteDataSource] Response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(response.body);
      if (decoded == null) {
        return const DeliveryOrdersResponseModel();
      }

      if (decoded is Map && decoded['data'] != null) {
        return DeliveryOrdersResponseModel.fromJson(decoded['data']);
      }

      return DeliveryOrdersResponseModel.fromJson(decoded);
    } else {
      try {
        final decoded = json.decode(response.body);
        final errorMsg = decoded['message'] ??
            decoded['error'] ??
            'Failed to load delivery orders (${response.statusCode})';
        throw Exception(errorMsg);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception(
            'Failed to load delivery orders (${response.statusCode})');
      }
    }
  }
}
