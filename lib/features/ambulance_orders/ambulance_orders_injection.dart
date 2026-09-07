import 'package:MediCompare/core/utils/core_injection.dart';
import 'data/datasources/ambulance_orders_remote_data_source.dart';
import 'data/repositories/ambulance_orders_repository_impl.dart';
import 'domain/repositories/ambulance_orders_repository.dart';
import 'domain/usecases/assign_ambulance_delivery_partner_usecase.dart';
import 'domain/usecases/get_ambulance_delivery_partners_usecase.dart';
import 'domain/usecases/get_ambulance_order_details_usecase.dart';
import 'domain/usecases/update_ambulance_booking_status_usecase.dart';
import 'presentation/bloc/ambulance_order_details_bloc.dart';
import 'presentation/bloc/ambulance_orders_bloc.dart';

class AmbulanceOrdersInjection {
  static AmbulanceOrdersRemoteDataSource provideRemoteDataSource() {
    final apiService = CoreInjection.provideApiService();
    return AmbulanceOrdersRemoteDataSource(apiService: apiService);
  }

  static AmbulanceOrdersRepository provideRepository() {
    return AmbulanceOrdersRepositoryImpl(
      remoteDataSource: provideRemoteDataSource(),
    );
  }

  static AmbulanceOrdersBloc provideAmbulanceOrdersBloc() {
    return AmbulanceOrdersBloc(dataSource: provideRemoteDataSource());
  }

  static AmbulanceOrderDetailsBloc provideAmbulanceOrderDetailsBloc() {
    final repository = provideRepository();
    return AmbulanceOrderDetailsBloc(
      getAmbulanceOrderDetailsUseCase:
          GetAmbulanceOrderDetailsUseCase(repository),
      updateAmbulanceBookingStatusUseCase:
          UpdateAmbulanceBookingStatusUseCase(repository),
      getDeliveryPartnersUseCase:
          GetAmbulanceDeliveryPartnersUseCase(repository),
      assignDeliveryPartnerUseCase:
          AssignAmbulanceDeliveryPartnerUseCase(repository),
    );
  }
}
