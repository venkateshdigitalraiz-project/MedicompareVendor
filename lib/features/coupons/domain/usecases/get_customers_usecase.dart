import '../entities/customer_entity.dart';
import '../repositories/coupon_repository.dart';

class GetCustomersUseCase {
  final CouponRepository repository;

  GetCustomersUseCase(this.repository);

  Future<List<Customer>> call({String search = ''}) {
    return repository.getCustomers(search: search);
  }
}
