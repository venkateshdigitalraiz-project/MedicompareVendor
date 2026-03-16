import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_pincodes_usecase.dart';
import 'pincodes_event.dart';
import 'pincodes_state.dart';

class PincodesBloc extends Bloc<PincodesEvent, PincodesState> {
  final GetPincodesUseCase getPincodesUseCase;

  PincodesBloc({required this.getPincodesUseCase}) : super(PincodesInitial()) {
    on<GetPincodesEvent>((event, emit) async {
      emit(PincodesLoading());
      try {
        final pincodes = await getPincodesUseCase();
        emit(PincodesLoaded(pincodes: pincodes));
      } catch (e) {
        emit(PincodesError(message: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
