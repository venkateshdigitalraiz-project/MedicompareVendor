import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/deliveryman_model.dart';

abstract class DeliverymanRemoteDataSource {
  Future<DeliverymanListResponseModel> getDeliverymen({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  });

  Future<bool> createDeliveryman(Map<String, dynamic> data);

  Future<bool> deleteDeliveryman(String id);
}

class DeliverymanRemoteDataSourceImpl implements DeliverymanRemoteDataSource {
  final ApiServiceRepository apiService;

  DeliverymanRemoteDataSourceImpl({required this.apiService});

  @override
  Future<DeliverymanListResponseModel> getDeliverymen({
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
      print('[DeliverymanRemoteDataSource] GET: ${ApiEndpoints.deliverymanList} params: $queryParams');
    }

    final response = await apiService.get(
      ApiEndpoints.deliverymanList,
      queryParameters: queryParams,
    );

    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] Response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(response.body);
      if (decoded == null) {
        return const DeliverymanListResponseModel();
      }

      // If wrapper has 'data'
      if (decoded is Map && decoded['data'] != null) {
        return DeliverymanListResponseModel.fromJson(decoded['data']);
      }

      return DeliverymanListResponseModel.fromJson(decoded);
    } else {
      try {
        final decoded = json.decode(response.body);
        final errorMsg = decoded['message'] ??
            decoded['error'] ??
            'Failed to load delivery personnel (${response.statusCode})';
        throw Exception(errorMsg);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception(
            'Failed to load delivery personnel (${response.statusCode})');
      }
    }
  }

  @override
  Future<bool> createDeliveryman(Map<String, dynamic> data) async {
    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] POST: ${ApiEndpoints.createDeliveryman} body: $data');
    }

    final response = await apiService.post(
      ApiEndpoints.createDeliveryman,
      body: data,
    );

    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] Create Response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      try {
        final decoded = json.decode(response.body);
        final errorMsg = decoded['message'] ??
            decoded['error'] ??
            'Failed to create deliveryman (${response.statusCode})';
        throw Exception(errorMsg);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Failed to create deliveryman (${response.statusCode})');
      }
    }
  }

  @override
  Future<bool> deleteDeliveryman(String id) async {
    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] DELETE: ${ApiEndpoints.deleteDeliveryman(id)}');
    }

    final response = await apiService.post(
      ApiEndpoints.deleteDeliveryman(id),
    );

    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] Delete Response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      try {
        final decoded = json.decode(response.body);
        final errorMsg = decoded['message'] ??
            decoded['error'] ??
            'Failed to delete deliveryman';
        throw Exception(errorMsg);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Failed to delete deliveryman (${response.statusCode})');
      }
    }
  }
}
