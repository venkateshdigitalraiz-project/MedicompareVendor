import 'package:MediCompare/core/utils/core_injection.dart';
import 'data/datasources/ambulance_orders_remote_data_source.dart';
import 'presentation/bloc/ambulance_orders_bloc.dart';

class AmbulanceOrdersInjection {
  static AmbulanceOrdersBloc provideAmbulanceOrdersBloc() {
    final apiService = CoreInjection.provideApiService();
    final dataSource = AmbulanceOrdersRemoteDataSource(apiService: apiService);
    return AmbulanceOrdersBloc(dataSource: dataSource);
  }
}
