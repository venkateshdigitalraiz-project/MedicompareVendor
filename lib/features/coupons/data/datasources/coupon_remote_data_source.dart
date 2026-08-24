import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/coupon_model.dart';
import '../models/customer_model.dart';

abstract class CouponRemoteDataSource {
  Future<void> addCoupon(CouponModel coupon);
  Future<void> updateCoupon(String id, CouponModel coupon);
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
  Future<void> addCoupon(CouponModel coupon) async {
    final response = await apiService.post(
      ApiEndpoints.couponCreate,
      body: coupon.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add coupon');
    }
  }

  @override
  Future<void> updateCoupon(String id, CouponModel coupon) async {
    final response = await apiService.post(
      ApiEndpoints.updateCoupon(id),
      body: coupon.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update coupon');
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
