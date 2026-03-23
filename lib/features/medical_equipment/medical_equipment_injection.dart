import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository_http_impl.dart';
import 'package:MediCompare/core/network/connection_checker.dart';
import 'data/data_sources/medical_equipment_service.dart';
import 'presentation/bloc/medical_equipment_bloc.dart';

class MedicalEquipmentInjection {
  static MedicalEquipmentService provideMedicalEquipmentService() {
    return MedicalEquipmentService(
      ApiServiceRepositoryHttpImplementation(
        baseUrl: ApiEndpoints.baseUrl,
        connectionChecker: ConnectionCheckerImpl(),
      ),
    );
  }

  static MedicalEquipmentBloc provideMedicalEquipmentBloc() {
    return MedicalEquipmentBloc(provideMedicalEquipmentService());
  }
}
