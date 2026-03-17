import '../../core/utils/core_injection.dart';
import 'data/data_sources/dashboard_remote_data_source.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/usecases/get_dashboard_usecase.dart';
import 'presentation/bloc/dashboard_bloc.dart';

class DashboardInjection {
  static DashboardRemoteDataSource provideRemoteDataSource() {
    return DashboardRemoteDataSourceImpl(
      apiService: CoreInjection.provideApiService(),
    );
  }

  static DashboardRepository provideRepository() {
    return DashboardRepositoryImpl(remoteDataSource: provideRemoteDataSource());
  }

  static GetDashboardUseCase provideGetDashboardUseCase() {
    return GetDashboardUseCase(repository: provideRepository());
  }

  static DashboardBloc provideDashboardBloc() {
    return DashboardBloc(getDashboardUseCase: provideGetDashboardUseCase());
  }
}
