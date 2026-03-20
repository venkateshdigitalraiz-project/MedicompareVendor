import 'package:MediCompare/core/utils/core_injection.dart';
import 'package:MediCompare/features/home_care/data/data_sources/home_care_service.dart';
import 'package:MediCompare/features/home_care/presentation/bloc/home_care_bloc.dart';

class HomeCareInjection {
  static HomeCareService provideHomeCareService() {
    return HomeCareService(CoreInjection.provideApiService());
  }

  static HomeCareBloc provideHomeCareBloc() {
    return HomeCareBloc(provideHomeCareService());
  }
}
