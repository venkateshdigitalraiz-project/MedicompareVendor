import '../../core/utils/core_injection.dart';
import 'data/datasources/ambulance_remote_data_source.dart';
import 'data/repositories/ambulance_repository_impl.dart';
import 'domain/repositories/ambulance_repository.dart';
import 'domain/usecases/create_ambulance_usecase.dart';
import 'domain/usecases/delete_ambulance_usecase.dart';
import 'domain/usecases/get_ambulance_categories_usecase.dart';
import 'domain/usecases/get_ambulance_details_usecase.dart';
import 'domain/usecases/get_ambulance_facilities_usecase.dart';
import 'domain/usecases/get_ambulance_list_usecase.dart';
import 'domain/usecases/get_ambulance_names_usecase.dart';
import 'domain/usecases/update_ambulance_usecase.dart';
import 'presentation/bloc/ambulance_bloc.dart';

class AmbulanceInjection {
  static AmbulanceRepository _provideAmbulanceRepository() {
    final apiService = CoreInjection.provideApiService();
    final remoteDataSource =
        AmbulanceRemoteDataSourceImpl(apiService: apiService);
    return AmbulanceRepositoryImpl(remoteDataSource: remoteDataSource);
  }

  static GetAmbulanceListUseCase provideGetAmbulanceListUseCase() {
    return GetAmbulanceListUseCase(_provideAmbulanceRepository());
  }

  static GetAmbulanceDetailsUseCase provideGetAmbulanceDetailsUseCase() {
    return GetAmbulanceDetailsUseCase(_provideAmbulanceRepository());
  }

  static GetAmbulanceCategoriesUseCase provideGetAmbulanceCategoriesUseCase() {
    return GetAmbulanceCategoriesUseCase(_provideAmbulanceRepository());
  }

  static GetAmbulanceNamesUseCase provideGetAmbulanceNamesUseCase() {
    return GetAmbulanceNamesUseCase(_provideAmbulanceRepository());
  }

  static GetAmbulanceFacilitiesUseCase provideGetAmbulanceFacilitiesUseCase() {
    return GetAmbulanceFacilitiesUseCase(_provideAmbulanceRepository());
  }

  static CreateAmbulanceUseCase provideCreateAmbulanceUseCase() {
    return CreateAmbulanceUseCase(_provideAmbulanceRepository());
  }

  static UpdateAmbulanceUseCase provideUpdateAmbulanceUseCase() {
    return UpdateAmbulanceUseCase(_provideAmbulanceRepository());
  }

  static DeleteAmbulanceUseCase provideDeleteAmbulanceUseCase() {
    return DeleteAmbulanceUseCase(_provideAmbulanceRepository());
  }

  static AmbulanceBloc provideAmbulanceBloc() {
    return AmbulanceBloc(
      getAmbulanceListUseCase: provideGetAmbulanceListUseCase(),
      getAmbulanceCategoriesUseCase: provideGetAmbulanceCategoriesUseCase(),
      getAmbulanceFacilitiesUseCase: provideGetAmbulanceFacilitiesUseCase(),
      getAmbulanceNamesUseCase: provideGetAmbulanceNamesUseCase(),
      createAmbulanceUseCase: provideCreateAmbulanceUseCase(),
      updateAmbulanceUseCase: provideUpdateAmbulanceUseCase(),
      deleteAmbulanceUseCase: provideDeleteAmbulanceUseCase(),
    );
  }
}
