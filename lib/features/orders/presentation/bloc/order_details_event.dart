import 'package:equatable/equatable.dart';

abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetOrderDetailsEvent extends OrderDetailsEvent {
  final String orderId;
  final String orderType;

  const GetOrderDetailsEvent(this.orderId, {this.orderType = 'normal'});

  @override
  List<Object?> get props => [orderId, orderType];
}

class UpdateOrderStatusEvent extends OrderDetailsEvent {
  final String orderItemId;
  final Map<String, dynamic> payload;

  const UpdateOrderStatusEvent({
    required this.orderItemId,
    required this.payload,
  });

  @override
  List<Object?> get props => [orderItemId, payload];
}

class GetOrderDeliveryPartnersEvent extends OrderDetailsEvent {
  final String search;
  final bool forceRefresh;
  final int page;
  final bool isLoadMore;
  final String deliveryManType;

  const GetOrderDeliveryPartnersEvent({
    this.search = '',
    this.forceRefresh = false,
    this.page = 1,
    this.isLoadMore = false,
    this.deliveryManType = 'admin',
  });

  @override
  List<Object?> get props => [search, forceRefresh, page, isLoadMore, deliveryManType];
}

class AssignOrderDeliveryPartnerEvent extends OrderDetailsEvent {
  final String orderId;
  final String deliveryPartnerId;
  final String deliveryManType;
  final String deliveryPartner;
  final String? readyTime;

  const AssignOrderDeliveryPartnerEvent({
    required this.orderId,
    required this.deliveryPartnerId,
    this.deliveryManType = 'admin',
    this.deliveryPartner = 'medicompares',
    this.readyTime,
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

class CheckAcceptEligibilityEvent extends OrderDetailsEvent {
  const CheckAcceptEligibilityEvent();
}
