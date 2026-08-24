import '../entities/coupon_entity.dart';
import '../repositories/coupon_repository.dart';

class GetCouponsUseCase {
  final CouponRepository repository;

  GetCouponsUseCase(this.repository);

  Future<List<Coupon>> call({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) {
    return repository.getCoupons(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }
}
