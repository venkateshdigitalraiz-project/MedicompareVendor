import '../entities/coupon_entity.dart';
import '../repositories/coupon_repository.dart';

class AddCouponUseCase {
  final CouponRepository repository;

  AddCouponUseCase(this.repository);

  Future<void> call(Coupon coupon) async {
    return await repository.addCoupon(coupon);
  }
}
