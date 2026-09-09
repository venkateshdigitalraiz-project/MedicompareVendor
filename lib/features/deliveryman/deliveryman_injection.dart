import '../../core/utils/core_injection.dart';
import 'data/datasources/deliveryman_remote_data_source.dart';
import 'data/repositories/deliveryman_repository_impl.dart';
import 'domain/usecases/get_deliverymen_usecase.dart';
import 'domain/usecases/delete_deliveryman_usecase.dart';
import 'domain/usecases/create_deliveryman_usecase.dart';
import 'presentation/bloc/deliveryman_bloc.dart';
import 'presentation/bloc/add_deliveryman_bloc.dart';
import 'data/datasources/delivery_orders_remote_data_source.dart';
import 'data/repositories/delivery_orders_repository_impl.dart';
import 'domain/usecases/get_delivery_orders_usecase.dart';
import 'presentation/bloc/delivery_orders_bloc.dart';

import 'data/datasources/delivery_analytics_remote_data_source.dart';
import 'data/repositories/delivery_analytics_repository_impl.dart';
import 'domain/usecases/get_delivery_analytics_usecase.dart';
import 'presentation/bloc/delivery_analytics_bloc.dart';

class DeliverymanInjection {
  static DeliverymanBloc provideDeliverymanBloc() {
    final apiService = CoreInjection.provideApiService();
    final remoteDataSource =
        DeliverymanRemoteDataSourceImpl(apiService: apiService);
    final repository =
        DeliverymanRepositoryImpl(remoteDataSource: remoteDataSource);
    final getDeliverymenUseCase = GetDeliverymenUseCase(repository);
    final deleteDeliverymanUseCase = DeleteDeliverymanUseCase(repository);

    return DeliverymanBloc(
      getDeliverymenUseCase: getDeliverymenUseCase,
      deleteDeliverymanUseCase: deleteDeliverymanUseCase,
    );
  }

  static AddDeliverymanBloc provideAddDeliverymanBloc() {
    final apiService = CoreInjection.provideApiService();
    final remoteDataSource =
        DeliverymanRemoteDataSourceImpl(apiService: apiService);
    final repository =
        DeliverymanRepositoryImpl(remoteDataSource: remoteDataSource);
    final createDeliverymanUseCase = CreateDeliverymanUseCase(repository);

    return AddDeliverymanBloc(
      createDeliverymanUseCase: createDeliverymanUseCase,
    );
  }

  static DeliveryOrdersBloc provideDeliveryOrdersBloc() {
    final apiService = CoreInjection.provideApiService();
    final remoteDataSource =
        DeliveryOrdersRemoteDataSourceImpl(apiService: apiService);
    final repository =
        DeliveryOrdersRepositoryImpl(remoteDataSource: remoteDataSource);
    final getDeliveryOrdersUseCase = GetDeliveryOrdersUseCase(repository);

    return DeliveryOrdersBloc(
      getDeliveryOrdersUseCase: getDeliveryOrdersUseCase,
    );
  }

  static DeliveryAnalyticsBloc provideDeliveryAnalyticsBloc() {
    final apiService = CoreInjection.provideApiService();
    final remoteDataSource =
        DeliveryAnalyticsRemoteDataSourceImpl(apiService: apiService);
    final repository =
        DeliveryAnalyticsRepositoryImpl(remoteDataSource: remoteDataSource);
    final getDeliveryAnalyticsUseCase =
        GetDeliveryAnalyticsUseCase(repository);

    return DeliveryAnalyticsBloc(
      getDeliveryAnalyticsUseCase: getDeliveryAnalyticsUseCase,
    );
  }
}


