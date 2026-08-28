import '../../core/utils/core_injection.dart';
import 'data/datasources/coupon_remote_data_source.dart';
import 'data/repositories/coupon_repository_impl.dart';
import 'domain/usecases/add_coupon_usecase.dart';
import 'domain/usecases/get_coupons_usecase.dart';
import 'domain/usecases/update_coupon_usecase.dart';
import 'domain/usecases/get_customers_usecase.dart';
import 'domain/usecases/delete_coupon_usecase.dart';
import 'presentation/bloc/coupon_bloc.dart';

class CouponsInjection {
  static CouponBloc provideCouponBloc() {
    final apiService = CoreInjection.provideApiService();
    final remoteDataSource = CouponRemoteDataSourceImpl(apiService: apiService);
    final repository = CouponRepositoryImpl(remoteDataSource: remoteDataSource);
    final addUseCase = AddCouponUseCase(repository);
    final getUseCase = GetCouponsUseCase(repository);
    final updateUseCase = UpdateCouponUseCase(repository);
    final getCustomersUseCase = GetCustomersUseCase(repository);
    final deleteUseCase = DeleteCouponUseCase(repository);
    return CouponBloc(
      addCouponUseCase: addUseCase,
      getCouponsUseCase: getUseCase,
      updateCouponUseCase: updateUseCase,
      getCustomersUseCase: getCustomersUseCase,
      deleteCouponUseCase: deleteUseCase,
    );
  }
}
