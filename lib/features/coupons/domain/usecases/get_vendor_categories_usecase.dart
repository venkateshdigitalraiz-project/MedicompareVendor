import '../repositories/coupon_repository.dart';

class GetVendorCategoriesUseCase {
  final CouponRepository repository;

  GetVendorCategoriesUseCase(this.repository);

  Future<List<String>> call() {
    return repository.getVendorCategories();
  }
}
