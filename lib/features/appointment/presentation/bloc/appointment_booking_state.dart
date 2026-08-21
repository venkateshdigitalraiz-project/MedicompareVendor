import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentBookingState extends Equatable {
  const AppointmentBookingState();

  @override
  List<Object?> get props => [];
}

class AppointmentBookingInitial extends AppointmentBookingState {}

class AppointmentBookingLoading extends AppointmentBookingState {}

class AppointmentBookingLoaded extends AppointmentBookingState {
  final AppointmentsListEntity appointmentsList;
  final bool isFetchingMore;

  const AppointmentBookingLoaded({
    required this.appointmentsList,
    this.isFetchingMore = false,
  });

  @override
  List<Object?> get props => [appointmentsList, isFetchingMore];
}

class AppointmentBookingError extends AppointmentBookingState {
  final String message;

  const AppointmentBookingError(this.message);

  @override
  List<Object?> get props => [message];
}
