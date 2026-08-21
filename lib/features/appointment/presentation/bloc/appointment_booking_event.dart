import 'package:equatable/equatable.dart';

abstract class AppointmentBookingEvent extends Equatable {
  const AppointmentBookingEvent();

  @override
  List<Object?> get props => [];
}

class GetAppointmentBookingsEvent extends AppointmentBookingEvent {
  final String? status;
  final String? search;
  final int page;
  final bool isLoadMore;

  const GetAppointmentBookingsEvent({
    this.status,
    this.search,
    this.page = 1,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [status, search, page, isLoadMore];
}
