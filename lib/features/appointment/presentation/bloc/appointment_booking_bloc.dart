import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import 'appointment_booking_event.dart';
import 'appointment_booking_state.dart';

class AppointmentBookingBloc extends Bloc<AppointmentBookingEvent, AppointmentBookingState> {
  final GetAppointmentsUseCase getAppointmentsUseCase;

  AppointmentBookingBloc({required this.getAppointmentsUseCase})
      : super(AppointmentBookingInitial()) {
    on<GetAppointmentBookingsEvent>(_onGetAppointmentBookings);
  }

  Future<void> _onGetAppointmentBookings(
    GetAppointmentBookingsEvent event,
    Emitter<AppointmentBookingState> emit,
  ) async {
    if (!event.isLoadMore) {
      emit(AppointmentBookingLoading());
    } else if (state is AppointmentBookingLoaded) {
      final currentState = state as AppointmentBookingLoaded;
      emit(AppointmentBookingLoaded(
        appointmentsList: currentState.appointmentsList,
        isFetchingMore: true,
      ));
    }

    try {
      final result = await getAppointmentsUseCase.call(
        page: event.page,
        limit: 10,
        status: event.status ?? '',
        search: event.search ?? '',
      );

      final enforcedPagination = AppointmentPaginationEntity(
        total: result.pagination.total,
        page: event.page,
        limit: result.pagination.limit,
        totalPages: result.pagination.totalPages,
      );

      if (event.isLoadMore && state is AppointmentBookingLoaded) {
        final currentState = state as AppointmentBookingLoaded;
        
        // Prevent duplicate appending if API returns empty or same data
        if (result.appointmentItems.isEmpty) {
          emit(AppointmentBookingLoaded(
            appointmentsList: currentState.appointmentsList,
            isFetchingMore: false,
          ));
          return;
        }

        final updatedList = List<AppointmentItemEntity>.from(currentState.appointmentsList.appointmentItems)
          ..addAll(result.appointmentItems);

        emit(AppointmentBookingLoaded(
          appointmentsList: AppointmentsListEntity(
            appointmentItems: updatedList,
            pagination: enforcedPagination,
          ),
          isFetchingMore: false,
        ));
      } else {
        emit(AppointmentBookingLoaded(
          appointmentsList: AppointmentsListEntity(
            appointmentItems: result.appointmentItems,
            pagination: enforcedPagination,
          )
        ));
      }
    } catch (e) {
      if (state is AppointmentBookingLoaded) {
        final currentState = state as AppointmentBookingLoaded;
        emit(AppointmentBookingLoaded(
          appointmentsList: currentState.appointmentsList,
          isFetchingMore: false,
        ));
      } else {
        emit(AppointmentBookingError(e.toString()));
      }
    }
  }
}
