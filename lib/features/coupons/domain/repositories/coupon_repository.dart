import 'package:MediCompare/features/coupons/domain/entities/customer_entity.dart';

import '../entities/coupon_entity.dart';

abstract class CouponRepository {
  Future<void> addCoupon(Coupon coupon);
  Future<void> updateCoupon(String id, Coupon coupon);
  Future<void> deleteCoupon(String id);
  Future<List<Coupon>> getCoupons({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  });
  Future<List<Customer>> getCustomers({String search = ''});
}
