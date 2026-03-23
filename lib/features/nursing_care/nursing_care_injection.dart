import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository_http_impl.dart';
import 'package:MediCompare/core/network/connection_checker.dart';
import 'data/data_sources/nursing_care_service.dart';
import 'presentation/bloc/nursing_care_bloc.dart';

class NursingCareInjection {
  static NursingCareService provideNursingCareService() {
    return NursingCareService(
      ApiServiceRepositoryHttpImplementation(
        baseUrl: ApiEndpoints.baseUrl,
        connectionChecker: ConnectionCheckerImpl(),
      ),
    );
  }

  static NursingCareBloc provideNursingCareBloc() {
    return NursingCareBloc(provideNursingCareService());
  }
}
