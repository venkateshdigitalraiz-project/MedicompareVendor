import '../api/api_endpoints.dart';
import '../api/api_service_repository.dart';
import '../api/api_service_repository_http_impl.dart';
import '../network/connection_checker.dart';

class CoreInjection {
  static ApiServiceRepository provideApiService() {
    return ApiServiceRepositoryHttpImplementation(
      baseUrl: ApiEndpoints.baseUrl,
      connectionChecker: ConnectionCheckerImpl(),
    );
  }
}
