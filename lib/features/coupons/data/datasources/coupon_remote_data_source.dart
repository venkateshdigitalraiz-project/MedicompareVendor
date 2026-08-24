import 'package:MediCompare/features/coupons/data/models/coupon_model.dart';
import 'package:http/http.dart' as http;

abstract class CouponRemoteDataSource {
  Future<void> addCoupon(CouponModel coupon);
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final http.Client client;

  CouponRemoteDataSourceImpl({required this.client});

  @override
  Future<void> addCoupon(CouponModel coupon) async {
    // final response = await client.post(
    //   Uri.parse('YOUR_API_ENDPOINT/coupons'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: json.encode(coupon.toJson()),
    // );
    // if (response.statusCode != 200 && response.statusCode != 201) {
    //   throw Exception('Failed to add coupon');
    // }

    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1));
  }
}
