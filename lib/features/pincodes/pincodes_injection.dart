import 'package:http/http.dart' as http;
import 'data/data_sources/pincodes_remote_data_source.dart';
import 'data/repositories/pincodes_repository_impl.dart';
import 'domain/repositories/pincodes_repository.dart';
import 'domain/usecases/get_pincodes_usecase.dart';
import 'presentation/bloc/pincodes_bloc.dart';

class PincodesInjection {
  static PincodesRemoteDataSource provideRemoteDataSource() {
    return PincodesRemoteDataSourceImpl(client: http.Client());
  }

  static PincodesRepository provideRepository() {
    return PincodesRepositoryImpl(remoteDataSource: provideRemoteDataSource());
  }

  static GetPincodesUseCase provideGetPincodesUseCase() {
    return GetPincodesUseCase(repository: provideRepository());
  }

  static PincodesBloc providePincodesBloc() {
    return PincodesBloc(getPincodesUseCase: provideGetPincodesUseCase());
  }
}
