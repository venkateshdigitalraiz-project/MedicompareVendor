import '../../core/utils/core_injection.dart';
import 'data/datasources/orders_remote_data_source.dart';
import 'data/repositories/orders_repository_impl.dart';
import 'domain/repositories/orders_repository.dart';
import 'domain/usecases/get_orders_usecase.dart';
import 'domain/usecases/get_order_details_usecase.dart';
import 'presentation/bloc/orders_bloc.dart';

class OrdersInjection {
  static OrdersBloc provideOrdersBloc() {
    return OrdersBloc(
      getOrdersUseCase: provideGetOrdersUseCase(),
      getOrderDetailsUseCase: provideGetOrderDetailsUseCase(),
    );
  }

  static GetOrdersUseCase provideGetOrdersUseCase() {
    return GetOrdersUseCase(provideOrdersRepository());
  }

  static GetOrderDetailsUseCase provideGetOrderDetailsUseCase() {
    return GetOrderDetailsUseCase(provideOrdersRepository());
  }

  static OrdersRepository provideOrdersRepository() {
    return OrdersRepositoryImpl(
      remoteDataSource: provideOrdersRemoteDataSource(),
    );
  }

  static OrdersRemoteDataSource provideOrdersRemoteDataSource() {
    return OrdersRemoteDataSourceImpl(
      apiService: CoreInjection.provideApiService(),
    );
  }
}
