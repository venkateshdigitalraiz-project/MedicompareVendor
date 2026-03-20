import '../../core/utils/core_injection.dart';
import 'data/data_sources/lab_test_service.dart';
import 'presentation/bloc/lab_test_bloc.dart';

class LabTestInjection {
  static LabTestService provideLabTestService() {
    return LabTestService(CoreInjection.provideApiService());
  }

  static LabTestBloc provideLabTestBloc() {
    return LabTestBloc(provideLabTestService());
  }
}
