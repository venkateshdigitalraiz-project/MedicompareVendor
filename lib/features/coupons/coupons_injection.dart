import 'package:http/http.dart' as http;
import 'data/datasources/coupon_remote_data_source.dart';
import 'data/repositories/coupon_repository_impl.dart';
import 'domain/usecases/add_coupon_usecase.dart';
import 'presentation/bloc/add_coupon_bloc.dart';

class CouponsInjection {
  static AddCouponBloc provideAddCouponBloc() {
    final client = http.Client();
    final remoteDataSource = CouponRemoteDataSourceImpl(client: client);
    final repository = CouponRepositoryImpl(remoteDataSource: remoteDataSource);
    final usecase = AddCouponUseCase(repository);
    return AddCouponBloc(addCouponUseCase: usecase);
  }
}
