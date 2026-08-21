import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_appointment_details_usecase.dart';
import 'appointment_details_event.dart';
import 'appointment_details_state.dart';

class AppointmentDetailsBloc extends Bloc<AppointmentDetailsEvent, AppointmentDetailsState> {
  final GetAppointmentDetailsUseCase getAppointmentDetailsUseCase;

  AppointmentDetailsBloc({required this.getAppointmentDetailsUseCase})
      : super(AppointmentDetailsInitial()) {
    on<GetAppointmentDetailsEvent>(_onGetAppointmentDetails);
  }

  Future<void> _onGetAppointmentDetails(
    GetAppointmentDetailsEvent event,
    Emitter<AppointmentDetailsState> emit,
  ) async {
    emit(AppointmentDetailsLoading());
    try {
      final result = await getAppointmentDetailsUseCase.call(event.appointmentId);
      emit(AppointmentDetailsLoaded(result));
    } catch (e) {
      emit(AppointmentDetailsError(e.toString()));
    }
  }
}
