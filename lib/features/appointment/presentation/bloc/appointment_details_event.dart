import 'dart:io';
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

class UploadReportEvent extends AppointmentDetailsEvent {
  final String orderId;
  final String orderItemId;
  final String reportType;
  final String patientId;
  final String selectType;
  final String? description;
  final File file;

  const UploadReportEvent({
    required this.orderId,
    required this.orderItemId,
    required this.reportType,
    required this.patientId,
    required this.selectType,
    this.description,
    required this.file,
  });

  @override
  List<Object?> get props => [
        orderId,
        orderItemId,
        reportType,
        patientId,
        selectType,
        description,
        file,
      ];
}

class UpdateAppointmentOrderStatusEvent extends AppointmentDetailsEvent {
  final String orderId;
  final String orderStatus;

  const UpdateAppointmentOrderStatusEvent({
    required this.orderId,
    required this.orderStatus,
  });

  @override
  List<Object?> get props => [orderId, orderStatus];
}

