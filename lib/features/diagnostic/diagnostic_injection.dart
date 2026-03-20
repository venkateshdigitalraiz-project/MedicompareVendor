import 'package:MediCompare/core/utils/core_injection.dart';
import 'data/data_sources/diagnostic_service.dart';
import 'presentation/bloc/diagnostic_bloc.dart';

class DiagnosticInjection {
  static DiagnosticService provideDiagnosticService() {
    return DiagnosticService(CoreInjection.provideApiService());
  }

  static DiagnosticBloc provideDiagnosticBloc() {
    return DiagnosticBloc(provideDiagnosticService());
  }
}
