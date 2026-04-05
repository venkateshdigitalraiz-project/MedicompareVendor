import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_slot_timings_usecase.dart';
import '../../domain/usecases/update_slot_timings_usecase.dart';
import 'slots_event.dart';
import 'slots_state.dart';

class SlotsBloc extends Bloc<SlotsEvent, SlotsState> {
  final GetSlotTimingsUseCase getSlotTimingsUseCase;
  final UpdateSlotTimingsUseCase updateSlotTimingsUseCase;

  SlotsBloc({
    required this.getSlotTimingsUseCase,
    required this.updateSlotTimingsUseCase,
  }) : super(SlotsInitial()) {
    on<GetSlotTimingsEvent>((event, emit) async {
      emit(SlotsLoading());
      try {
        final timings = await getSlotTimingsUseCase();
        emit(SlotsLoaded(timings: timings));
      } catch (e) {
        emit(SlotsError(message: e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<UpdateSlotTimingsEvent>((event, emit) async {
      emit(SlotsLoading());
      try {
        final updatedTiming =
            await updateSlotTimingsUseCase(event.id, event.entity);
        emit(SlotsUpdated(timing: updatedTiming));
        // Refresh the list after update
        add(GetSlotTimingsEvent());
      } catch (e) {
        emit(SlotsError(message: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
