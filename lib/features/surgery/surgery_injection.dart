import '../../core/utils/core_injection.dart';
import 'data/data_sources/surgery_service.dart';
import 'presentation/bloc/surgery_bloc.dart';

class SurgeryInjection {
  static SurgeryService provideSurgeryService() {
    return SurgeryService(CoreInjection.provideApiService());
  }

  static SurgeryBloc provideSurgeryBloc() {
    return SurgeryBloc(provideSurgeryService());
  }
}
