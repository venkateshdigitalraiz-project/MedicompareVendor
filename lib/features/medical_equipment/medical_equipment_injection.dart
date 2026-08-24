import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository_http_impl.dart';
import 'package:MediCompare/core/network/connection_checker.dart';
import 'data/data_sources/medical_equipment_service.dart';
import 'data/repositories/medical_equipment_repository_impl.dart';
import 'domain/repositories/medical_equipment_repository.dart';
import 'domain/usecases/get_medical_equipment_categories_usecase.dart';
import 'domain/usecases/get_medical_equipment_list_usecase.dart';
import 'domain/usecases/get_medical_equipment_details_usecase.dart';
import 'domain/usecases/search_tablets_usecase.dart';
import 'domain/usecases/create_medical_equipment_usecase.dart';
import 'domain/usecases/update_medical_equipment_usecase.dart';
import 'domain/usecases/delete_medical_equipment_usecase.dart';
import 'presentation/bloc/medical_equipment_bloc.dart';
import 'presentation/bloc/medical_equipment_details_bloc.dart';

class MedicalEquipmentInjection {
  static MedicalEquipmentService _provideService() {
    return MedicalEquipmentService(
      ApiServiceRepositoryHttpImplementation(
        baseUrl: ApiEndpoints.baseUrl,
        connectionChecker: ConnectionCheckerImpl(),
      ),
    );
  }

  static MedicalEquipmentRepository provideRepository() {
    return MedicalEquipmentRepositoryImpl(remoteDataSource: _provideService());
  }

  static GetMedicalEquipmentCategoriesUseCase provideGetCategoriesUseCase() {
    return GetMedicalEquipmentCategoriesUseCase(provideRepository());
  }

  static GetMedicalEquipmentListUseCase provideGetListUseCase() {
    return GetMedicalEquipmentListUseCase(provideRepository());
  }

  static GetMedicalEquipmentDetailsUseCase provideGetDetailsUseCase() {
    return GetMedicalEquipmentDetailsUseCase(provideRepository());
  }

  static SearchTabletsUseCase provideSearchTabletsUseCase() {
    return SearchTabletsUseCase(provideRepository());
  }

  static CreateMedicalEquipmentUseCase provideCreateUseCase() {
    return CreateMedicalEquipmentUseCase(provideRepository());
  }

  static UpdateMedicalEquipmentUseCase provideUpdateUseCase() {
    return UpdateMedicalEquipmentUseCase(provideRepository());
  }

  static DeleteMedicalEquipmentUseCase provideDeleteUseCase() {
    return DeleteMedicalEquipmentUseCase(provideRepository());
  }

  static MedicalEquipmentBloc provideMedicalEquipmentBloc() {
    return MedicalEquipmentBloc(
      getCategoriesUseCase: provideGetCategoriesUseCase(),
      getListUseCase: provideGetListUseCase(),
    );
  }

  static MedicalEquipmentDetailsBloc provideMedicalEquipmentDetailsBloc() {
    return MedicalEquipmentDetailsBloc(
      getDetailsUseCase: provideGetDetailsUseCase(),
    );
  }
}
