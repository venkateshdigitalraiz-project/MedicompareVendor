import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_details_entity.dart';

abstract class AppointmentDetailsState extends Equatable {
  const AppointmentDetailsState();

  @override
  List<Object?> get props => [];
}

class AppointmentDetailsInitial extends AppointmentDetailsState {}

class AppointmentDetailsLoading extends AppointmentDetailsState {}

class AppointmentDetailsLoaded extends AppointmentDetailsState {
  final AppointmentDetailsEntity appointmentDetails;

  const AppointmentDetailsLoaded(this.appointmentDetails);

  @override
  List<Object?> get props => [appointmentDetails];
}

class AppointmentDetailsError extends AppointmentDetailsState {
  final String message;

  const AppointmentDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
