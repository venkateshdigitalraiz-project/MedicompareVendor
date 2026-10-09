import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../domain/entities/create_deliveryman_entity.dart';
import '../models/deliveryman_model.dart';

abstract class DeliverymanRemoteDataSource {
  Future<DeliverymanListResponseModel> getDeliverymen({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  });

  Future<CreateDeliverymanEntity> getDeliverymanById(String id);

  Future<bool> createDeliveryman(Map<String, dynamic> data);

  Future<bool> updateDeliveryman(String id, Map<String, dynamic> data);

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
  Future<CreateDeliverymanEntity> getDeliverymanById(String id) async {
    final endpoint = ApiEndpoints.viewDeliveryman(id);
    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] GET: $endpoint');
    }

    try {
      final response = await apiService.get(endpoint);

      if (kDebugMode) {
        print(
            '[DeliverymanRemoteDataSource] View Response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return CreateDeliverymanEntity.fromJson(decoded);
        } else if (decoded is Map) {
          return CreateDeliverymanEntity.fromJson(
              Map<String, dynamic>.from(decoded));
        }
        throw Exception('Invalid response format');
      } else {
        // Fallback: If view returns non-200, try details endpoint
        if (response.statusCode == 404 || response.statusCode == 400) {
          final fallbackEndpoint = ApiEndpoints.deliverymanDetails(id);
          if (kDebugMode) {
            print('[DeliverymanRemoteDataSource] Fallback GET: $fallbackEndpoint');
          }
          final fallbackRes = await apiService.get(fallbackEndpoint);
          if (fallbackRes.statusCode >= 200 && fallbackRes.statusCode < 300) {
            final decoded = json.decode(fallbackRes.body);
            if (decoded is Map<String, dynamic>) {
              return CreateDeliverymanEntity.fromJson(decoded);
            } else if (decoded is Map) {
              return CreateDeliverymanEntity.fromJson(
                  Map<String, dynamic>.from(decoded));
            }
          }
        }

        try {
          final decoded = json.decode(response.body);
          final errorMsg = decoded['message'] ??
              decoded['error'] ??
              'Failed to load deliveryman details (${response.statusCode})';
          throw Exception(errorMsg);
        } catch (e) {
          if (e is Exception && !e.toString().contains('FormatException')) {
            rethrow;
          }
          throw Exception(
              'Failed to load deliveryman details (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
      throw Exception('Failed to load deliveryman details: $e');
    }
  }

  void _extractFieldsAndFiles(
      Map<String, dynamic> data, Map<String, String> fields, Map<String, File> files) {
    
    // Add required missing fields that are in Postman but not in the UI payload
    if (!data.containsKey('password')) fields['password'] = '12345678';
    if (!data.containsKey('confirmPassword')) fields['confirmPassword'] = '12345678';
    if (!data.containsKey('deliveryType')) fields['deliveryType'] = 'medicine';
    if (!data.containsKey('notificationsEnabled')) fields['notificationsEnabled'] = 'true';

    // Helper to format time (e.g. "09:00 AM" to "09:00")
    String formatTime(String time) {
      if (time.isEmpty) return time;
      try {
        final isPM = time.toLowerCase().contains('pm');
        final isAM = time.toLowerCase().contains('am');
        if (!isPM && !isAM) return time.trim();

        final parts = time.replaceAll(RegExp(r'[a-zA-Z]'), '').trim().split(':');
        if (parts.length != 2) return time;

        int hour = int.parse(parts[0]);
        final minute = parts[1];

        if (isPM && hour < 12) hour += 12;
        if (isAM && hour == 12) hour = 0;

        return '${hour.toString().padLeft(2, '0')}:$minute';
      } catch (e) {
        return time;
      }
    }

    final allowedFileKeys = ['aadhaarFile', 'panFile', 'bikeRcFile', 'drivingLicenseFile'];
    final duplicateKeysToIgnore = ['aadhaarDoc', 'panDoc', 'bikeRcDoc', 'drivingLicenseDoc', 'proof', 'workDetails', 'bankDetails', 'workingHours'];

    data.forEach((key, value) {
      if (value == null || duplicateKeysToIgnore.contains(key)) return;
      
      if (allowedFileKeys.contains(key)) {
        if (value is String && value.isNotEmpty && File(value).existsSync()) {
          files[key] = File(value);
        }
      } else {
        if (key == 'shiftStartTime' || key == 'shiftEndTime') {
          fields[key] = formatTime(value.toString());
        } else {
          fields[key] = value.toString();
        }
      }
    });
  }

  @override
  Future<bool> createDeliveryman(Map<String, dynamic> data) async {
    final Map<String, String> fields = {};
    final Map<String, File> files = {};
    _extractFieldsAndFiles(data, fields, files);

    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] POST: ${ApiEndpoints.createDeliveryman}');
      print('Fields: $fields');
      print('Files: ${files.keys.toList()}');
    }

    final response = await apiService.post(
      ApiEndpoints.createDeliveryman,
      fields: fields,
      files: files,
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
  Future<bool> updateDeliveryman(String id, Map<String, dynamic> data) async {
    final endpoint = ApiEndpoints.updateDeliveryman(id);
    final Map<String, String> fields = {};
    final Map<String, File> files = {};
    _extractFieldsAndFiles(data, fields, files);

    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] POST: $endpoint');
      print('Fields: $fields');
      print('Files: ${files.keys.toList()}');
    }

    final response = await apiService.post(
      endpoint,
      fields: fields,
      files: files,
    );

    if (kDebugMode) {
      print('[DeliverymanRemoteDataSource] Update Response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      try {
        final decoded = json.decode(response.body);
        final errorMsg = decoded['message'] ??
            decoded['error'] ??
            'Failed to update deliveryman (${response.statusCode})';
        throw Exception(errorMsg);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Failed to update deliveryman (${response.statusCode})');
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
