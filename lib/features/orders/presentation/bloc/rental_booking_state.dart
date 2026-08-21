import 'package:equatable/equatable.dart';
import '../../domain/entities/rental_booking_entity.dart';

abstract class RentalBookingState extends Equatable {
  const RentalBookingState();

  @override
  List<Object?> get props => [];
}

class RentalBookingInitial extends RentalBookingState {}

class RentalBookingLoading extends RentalBookingState {}

class RentalBookingLoaded extends RentalBookingState {
  final RentalBookingResponseEntity bookingsResponse;
  final bool isLoadingMore;

  const RentalBookingLoaded({
    required this.bookingsResponse,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [bookingsResponse, isLoadingMore];
}

class RentalBookingError extends RentalBookingState {
  final String message;

  const RentalBookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
