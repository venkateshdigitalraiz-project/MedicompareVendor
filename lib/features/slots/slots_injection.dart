import 'package:http/http.dart' as http;
import 'data/data_sources/slots_remote_data_source.dart';
import 'data/repositories/slots_repository_impl.dart';
import 'domain/repositories/slots_repository.dart';
import 'domain/usecases/get_slot_timings_usecase.dart';
import 'domain/usecases/update_slot_timings_usecase.dart';
import 'presentation/bloc/slots_bloc.dart';

class SlotsInjection {
  static SlotsRemoteDataSource provideRemoteDataSource() {
    return SlotsRemoteDataSourceImpl(client: http.Client());
  }

  static SlotsRepository provideRepository() {
    return SlotsRepositoryImpl(remoteDataSource: provideRemoteDataSource());
  }

  static GetSlotTimingsUseCase provideGetSlotTimingsUseCase() {
    return GetSlotTimingsUseCase(repository: provideRepository());
  }

  static UpdateSlotTimingsUseCase provideUpdateSlotTimingsUseCase() {
    return UpdateSlotTimingsUseCase(repository: provideRepository());
  }

  static SlotsBloc provideSlotsBloc() {
    return SlotsBloc(
      getSlotTimingsUseCase: provideGetSlotTimingsUseCase(),
      updateSlotTimingsUseCase: provideUpdateSlotTimingsUseCase(),
    );
  }
}
