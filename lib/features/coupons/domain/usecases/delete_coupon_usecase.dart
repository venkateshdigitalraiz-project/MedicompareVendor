import '../repositories/coupon_repository.dart';

class DeleteCouponUseCase {
  final CouponRepository repository;

  DeleteCouponUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteCoupon(id);
  }
}
