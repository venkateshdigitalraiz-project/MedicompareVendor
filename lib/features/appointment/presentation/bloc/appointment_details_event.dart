import 'package:equatable/equatable.dart';

abstract class AppointmentDetailsEvent extends Equatable {
  const AppointmentDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetAppointmentDetailsEvent extends AppointmentDetailsEvent {
  final String appointmentId;

  const GetAppointmentDetailsEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}
