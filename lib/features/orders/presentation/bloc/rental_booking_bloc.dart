import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_rental_bookings_usecase.dart';
import 'rental_booking_event.dart';
import 'rental_booking_state.dart';
import '../../domain/entities/rental_booking_entity.dart';

class RentalBookingBloc extends Bloc<RentalBookingEvent, RentalBookingState> {
  final GetRentalBookingsUseCase getRentalBookingsUseCase;

  RentalBookingBloc({required this.getRentalBookingsUseCase})
      : super(RentalBookingInitial()) {
    on<GetRentalBookingsEvent>(_onGetRentalBookings);
  }

  Future<void> _onGetRentalBookings(
    GetRentalBookingsEvent event,
    Emitter<RentalBookingState> emit,
  ) async {
    List<RentalBookingEntity> currentBookings = [];
    
    if (event.isLoadMore && state is RentalBookingLoaded) {
      currentBookings = (state as RentalBookingLoaded).bookingsResponse.orderItems;
      emit(RentalBookingLoaded(
        bookingsResponse: (state as RentalBookingLoaded).bookingsResponse,
        isLoadingMore: true,
      ));
    } else {
      emit(RentalBookingLoading());
    }

    try {
      final bookingsResponse = await getRentalBookingsUseCase(
        page: event.page,
        status: event.status,
        search: event.search,
      );

      if (event.isLoadMore) {
        final updatedBookings = List<RentalBookingEntity>.from(currentBookings)
          ..addAll(bookingsResponse.orderItems);
        
        final updatedResponse = RentalBookingResponseEntity(
          orderItems: updatedBookings,
          pagination: bookingsResponse.pagination,
        );
        emit(RentalBookingLoaded(bookingsResponse: updatedResponse));
      } else {
        emit(RentalBookingLoaded(bookingsResponse: bookingsResponse));
      }
    } catch (e) {
      emit(RentalBookingError(message: e.toString()));
    }
  }
}
