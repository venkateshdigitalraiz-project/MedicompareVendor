import '../../domain/entities/coupon_entity.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../datasources/coupon_remote_data_source.dart';
import '../models/coupon_model.dart';
import '../../domain/entities/customer_entity.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource remoteDataSource;

  CouponRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addCoupon(Coupon coupon) async {
    try {
      final couponModel = CouponModel.fromEntity(coupon);
      await remoteDataSource.addCoupon(couponModel);
    } catch (e) {
      throw Exception('Failed to add coupon: $e');
    }
  }

  @override
  Future<void> updateCoupon(String id, Coupon coupon) async {
    try {
      final couponModel = CouponModel.fromEntity(coupon);
      await remoteDataSource.updateCoupon(id, couponModel);
    } catch (e) {
      throw Exception('Failed to update coupon: $e');
    }
  }

  @override
  Future<List<Coupon>> getCoupons({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
  }) async {
    try {
      return await remoteDataSource.getCoupons(
        page: page,
        limit: limit,
        search: search,
        status: status,
      );
    } catch (e) {
      throw Exception('Failed to fetch coupons: $e');
    }
  }

  @override
  Future<List<Customer>> getCustomers({String search = ''}) async {
    try {
      return await remoteDataSource.getCustomers(search: search);
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }
}
