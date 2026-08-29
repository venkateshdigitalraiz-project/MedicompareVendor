import '../../core/utils/core_injection.dart';
import 'data/data_sources/lab_test_service.dart';
import 'data/data_sources/lab_test_remote_data_source.dart';
import 'data/repositories/lab_test_repository_impl.dart';
import 'domain/repositories/lab_test_repository.dart';
import 'domain/usecases/get_lab_test_details_usecase.dart';
import 'domain/usecases/update_lab_test_usecase.dart';
import 'domain/usecases/search_lab_tests_usecase.dart';
import 'presentation/bloc/lab_test_bloc.dart';
import 'presentation/bloc/lab_test_package_bloc.dart';
import 'presentation/bloc/edit_lead_bloc.dart';
import 'presentation/bloc/search_lab_tests_bloc.dart';

class LabTestInjection {
  static LabTestService provideLabTestService() {
    return LabTestService(CoreInjection.provideApiService());
  }

  static LabTestRemoteDataSource provideLabTestRemoteDataSource() {
    return LabTestRemoteDataSourceImpl(CoreInjection.provideApiService());
  }

  static LabTestRepository provideLabTestRepository() {
    return LabTestRepositoryImpl(provideLabTestRemoteDataSource());
  }

  static GetLabTestDetailsUseCase provideGetLabTestDetailsUseCase() {
    return GetLabTestDetailsUseCase(provideLabTestRepository());
  }

  static UpdateLabTestUseCase provideUpdateLabTestUseCase() {
    return UpdateLabTestUseCase(provideLabTestRepository());
  }

  static EditLeadBloc provideEditLeadBloc() {
    return EditLeadBloc(
      provideGetLabTestDetailsUseCase(),
      provideUpdateLabTestUseCase(),
    );
  }

  static LabTestBloc provideLabTestBloc() {
    return LabTestBloc(provideLabTestService());
  }

  static LabTestPackageBloc provideLabTestPackageBloc() {
    return LabTestPackageBloc(provideLabTestService());
  }

  static SearchLabTestsUseCase provideSearchLabTestsUseCase() {
    return SearchLabTestsUseCase(provideLabTestRepository());
  }

  static SearchLabTestsBloc provideSearchLabTestsBloc() {
    return SearchLabTestsBloc(provideSearchLabTestsUseCase());
  }
}
