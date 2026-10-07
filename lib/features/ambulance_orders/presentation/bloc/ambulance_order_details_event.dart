import 'package:equatable/equatable.dart';

abstract class AmbulanceOrderDetailsEvent extends Equatable {
  const AmbulanceOrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetAmbulanceOrderDetailsEvent extends AmbulanceOrderDetailsEvent {
  final String orderId;

  const GetAmbulanceOrderDetailsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateAmbulanceBookingStatusEvent extends AmbulanceOrderDetailsEvent {
  final String orderId;
  final String bookingStatus;
  final String? reason;

  const UpdateAmbulanceBookingStatusEvent({
    required this.orderId,
    required this.bookingStatus,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, bookingStatus, reason];
}

class GetAmbulanceDeliveryPartnersEvent extends AmbulanceOrderDetailsEvent {
  final String search;
  final bool forceRefresh;
  final int page;
  final bool isLoadMore;
  final String deliveryManType;

  const GetAmbulanceDeliveryPartnersEvent({
    this.search = '',
    this.forceRefresh = false,
    this.page = 1,
    this.isLoadMore = false,
    this.deliveryManType = 'admin',
  });

  @override
  List<Object?> get props => [search, forceRefresh, page, isLoadMore, deliveryManType];
}

class AssignAmbulanceDeliveryPartnerEvent extends AmbulanceOrderDetailsEvent {
  final String orderId;
  final String deliveryPartnerId;
  final String deliveryManType;
  final String deliveryPartner;
  final String? readyTime;

  const AssignAmbulanceDeliveryPartnerEvent({
    required this.orderId,
    required this.deliveryPartnerId,
    this.deliveryManType = 'admin',
    this.deliveryPartner = 'medicompares',
    this.readyTime = '30',
  });

  @override
  List<Object?> get props => [
        orderId,
        deliveryPartnerId,
        deliveryManType,
        deliveryPartner,
        readyTime,
      ];
}
