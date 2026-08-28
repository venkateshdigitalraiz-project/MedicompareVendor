import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/coupon_model.dart';
import '../models/customer_model.dart';

abstract class CouponRemoteDataSource {
  Future<void> addCoupon(CouponModel coupon);
  Future<void> updateCoupon(String id, CouponModel coupon);
  Future<void> deleteCoupon(String id);
  Future<List<CouponModel>> getCoupons({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  });
  Future<List<CustomerModel>> getCustomers({String search = ''});
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final ApiServiceRepository apiService;

  CouponRemoteDataSourceImpl({required this.apiService});

  @override
  Future<void> deleteCoupon(String id) async {
    if (kDebugMode) {
      print('[DeleteCoupon API URL]: ${ApiEndpoints.deleteCoupon(id)}');
    }
    final response = await apiService.post(
      ApiEndpoints.deleteCoupon(id),
    );
    if (kDebugMode) {
      print('[DeleteCoupon API Response]: ${response.statusCode} - ${response.body}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final decoded = json.decode(response.body);
        final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Failed to delete coupon';
        throw Exception(errorMsg);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Failed to delete coupon (${response.statusCode}): ${response.body}');
      }
    }
  }

  @override
  Future<void> addCoupon(CouponModel coupon) async {
    final body = coupon.toJson();
    if (kDebugMode) {
      print('[CreateCoupon API Request Body]: ${json.encode(body)}');
    }
    final response = await apiService.post(
      ApiEndpoints.couponCreate,
      body: body,
    );
    if (kDebugMode) {
      print('[CreateCoupon API Response]: ${response.statusCode} - ${response.body}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final decoded = json.decode(response.body);
        final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Failed to add coupon';
        throw Exception(errorMsg);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Failed to add coupon (${response.statusCode}): ${response.body}');
      }
    }
  }

  @override
  Future<void> updateCoupon(String id, CouponModel coupon) async {
    final body = coupon.toJson();
    if (kDebugMode) {
      print('[UpdateCoupon API Request Body]: ${json.encode(body)}');
    }
    final response = await apiService.post(
      ApiEndpoints.updateCoupon(id),
      body: body,
    );
    if (kDebugMode) {
      print('[UpdateCoupon API Response]: ${response.statusCode} - ${response.body}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final decoded = json.decode(response.body);
        final errorMsg = decoded['message'] ?? decoded['error'] ?? 'Failed to update coupon';
        throw Exception(errorMsg);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Failed to update coupon (${response.statusCode}): ${response.body}');
      }
    }
  }

  @override
  Future<List<CouponModel>> getCoupons({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    final response = await apiService.get(
      ApiEndpoints.couponList,
      queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
        'status': status,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded != null && decoded['success'] == true && decoded['data'] != null) {
        final List<dynamic> list = decoded['data']['coupons'] ?? [];
        return list.map((item) => CouponModel.fromJson(item)).toList();
      }
    }
    return [];
  }

  @override
  Future<List<CustomerModel>> getCustomers({String search = ''}) async {
    final response = await apiService.get(
      ApiEndpoints.customersList,
      queryParameters: {
        'page': 1,
        'limit': 100,
        'search': search,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded != null && decoded['success'] == true && decoded['data'] != null) {
        final List<dynamic> list = decoded['data']['customers'] ?? [];
        return list.map((item) => CustomerModel.fromJson(item)).toList();
      }
    }
    return [];
  }
}
