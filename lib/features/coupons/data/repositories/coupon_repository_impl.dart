import '../../domain/entities/coupon_entity.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../datasources/coupon_remote_data_source.dart';
import '../models/coupon_model.dart';

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
}
