import '../../core/utils/core_injection.dart';
import 'data/data_sources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/login_usecase.dart';

class AuthInjection {
  static RegisterUseCase provideRegisterUseCase() {
    final apiService = CoreInjection.provideApiService();
    final AuthRemoteDataSource remoteDataSource =
        AuthRemoteDataSourceImpl(apiService: apiService);
    final AuthRepository repository =
        AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    return RegisterUseCase(repository);
  }

  static LoginUseCase provideLoginUseCase() {
    final apiService = CoreInjection.provideApiService();
    final AuthRemoteDataSource remoteDataSource =
        AuthRemoteDataSourceImpl(apiService: apiService);
    final AuthRepository repository =
        AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    return LoginUseCase(repository);
  }
}
