import '../../core/utils/core_injection.dart';
import 'data/data_sources/medicine_service.dart';
import 'presentation/bloc/medicine_bloc.dart';

class MedicineInjection {
  static MedicineService provideMedicineService() {
    return MedicineService(CoreInjection.provideApiService());
  }

  static MedicineBloc provideMedicineBloc() {
    return MedicineBloc(provideMedicineService());
  }
}
