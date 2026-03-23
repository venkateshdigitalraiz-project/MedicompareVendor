import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository_http_impl.dart';
import 'package:MediCompare/core/network/connection_checker.dart';
import 'package:MediCompare/features/dental_service/data/data_sources/dental_service_service.dart';
import 'package:MediCompare/features/dental_service/presentation/bloc/dental_service_bloc.dart';

class DentalServiceInjection {
  static DentalServiceService provideDentalServiceService() {
    return DentalServiceService(
      ApiServiceRepositoryHttpImplementation(
        baseUrl: ApiEndpoints.baseUrl,
        connectionChecker: ConnectionCheckerImpl(),
      ),
    );
  }

  static DentalServiceBloc provideDentalServiceBloc() {
    return DentalServiceBloc(provideDentalServiceService());
  }
}
