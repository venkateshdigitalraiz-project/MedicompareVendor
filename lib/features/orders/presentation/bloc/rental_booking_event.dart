import 'package:equatable/equatable.dart';

abstract class RentalBookingEvent extends Equatable {
  const RentalBookingEvent();

  @override
  List<Object?> get props => [];
}

class GetRentalBookingsEvent extends RentalBookingEvent {
  final String? status;
  final String? search;
  final int page;
  final bool isLoadMore;

  const GetRentalBookingsEvent({
    this.status,
    this.search,
    this.page = 1,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [status, search, page, isLoadMore];
}
