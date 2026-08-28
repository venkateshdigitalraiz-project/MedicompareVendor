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

class ReportUploadingState extends AppointmentDetailsState {
  final String orderItemId;

  const ReportUploadingState(this.orderItemId);

  @override
  List<Object?> get props => [orderItemId];
}

class ReportUploadSuccessState extends AppointmentDetailsState {
  final String message;
  final String orderItemId;

  const ReportUploadSuccessState(this.message, this.orderItemId);

  @override
  List<Object?> get props => [message, orderItemId];
}

class ReportUploadErrorState extends AppointmentDetailsState {
  final String message;
  final String orderItemId;

  const ReportUploadErrorState(this.message, this.orderItemId);

  @override
  List<Object?> get props => [message, orderItemId];
}

class AppointmentStatusUpdatingState extends AppointmentDetailsState {}

class AppointmentStatusUpdatedState extends AppointmentDetailsState {
  final String message;

  const AppointmentStatusUpdatedState({this.message = 'Status updated successfully'});

  @override
  List<Object?> get props => [message];
}

class AppointmentStatusUpdateErrorState extends AppointmentDetailsState {
  final String message;

  const AppointmentStatusUpdateErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

