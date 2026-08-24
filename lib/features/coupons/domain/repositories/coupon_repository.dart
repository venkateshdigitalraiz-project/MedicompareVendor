import '../entities/coupon_entity.dart';

abstract class CouponRepository {
  Future<void> addCoupon(Coupon coupon);
}
