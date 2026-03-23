import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository_http_impl.dart';
import 'package:MediCompare/core/network/connection_checker.dart';
import 'data/data_sources/medical_treatment_service.dart';
import 'presentation/bloc/medical_treatment_bloc.dart';

class MedicalTreatmentInjection {
  static MedicalTreatmentService provideMedicalTreatmentService() {
    return MedicalTreatmentService(
      ApiServiceRepositoryHttpImplementation(
        baseUrl: ApiEndpoints.baseUrl,
        connectionChecker: ConnectionCheckerImpl(),
      ),
    );
  }

  static MedicalTreatmentBloc provideMedicalTreatmentBloc() {
    return MedicalTreatmentBloc(provideMedicalTreatmentService());
  }
}
