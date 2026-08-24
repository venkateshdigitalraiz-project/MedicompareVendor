import '../../core/utils/core_injection.dart';
import 'data/datasources/service_fee_remote_data_source.dart';
import 'data/repositories/service_fee_repository_impl.dart';
import 'domain/repositories/service_fee_repository.dart';
import 'domain/usecases/get_service_fee.dart';
import 'presentation/bloc/service_fee_bloc.dart';

class ServiceFeeInjection {
  static ServiceFeeRemoteDataSource provideRemoteDataSource() {
    return ServiceFeeRemoteDataSourceImpl(CoreInjection.provideApiService());
  }

  static ServiceFeeRepository provideRepository() {
    return ServiceFeeRepositoryImpl(provideRemoteDataSource());
  }

  static GetServiceFee provideGetServiceFee() {
    return GetServiceFee(provideRepository());
  }

  static ServiceFeeBloc provideServiceFeeBloc() {
    return ServiceFeeBloc(provideGetServiceFee());
  }
}
