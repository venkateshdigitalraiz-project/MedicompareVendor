import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_slot_timings_usecase.dart';
import 'slots_event.dart';
import 'slots_state.dart';

class SlotsBloc extends Bloc<SlotsEvent, SlotsState> {
  final GetSlotTimingsUseCase getSlotTimingsUseCase;

  SlotsBloc({required this.getSlotTimingsUseCase}) : super(SlotsInitial()) {
    on<GetSlotTimingsEvent>((event, emit) async {
      emit(SlotsLoading());
      try {
        final timings = await getSlotTimingsUseCase();
        emit(SlotsLoaded(timings: timings));
      } catch (e) {
        emit(SlotsError(message: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
