import '../entities/coupon_entity.dart';
import '../repositories/coupon_repository.dart';

class UpdateCouponUseCase {
  final CouponRepository repository;

  UpdateCouponUseCase(this.repository);

  Future<void> call(String id, Coupon coupon) {
    return repository.updateCoupon(id, coupon);
  }
}
