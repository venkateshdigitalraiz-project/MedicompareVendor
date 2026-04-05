import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class GetOrdersEvent extends OrdersEvent {
  final int page;
  final int limit;
  final String status;
  final String search;
  final String orderType;
  final bool isLoadMore;

  const GetOrdersEvent({
    this.page = 1,
    this.limit = 10,
    this.status = '',
    this.search = '',
    this.orderType = 'normal',
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props =>
      [page, limit, status, search, orderType, isLoadMore];
}

class GetOrderDetailsEvent extends OrdersEvent {
  final String orderId;
  final String orderType;

  const GetOrderDetailsEvent(this.orderId, {this.orderType = 'normal'});

  @override
  List<Object?> get props => [orderId, orderType];
}

class UpdateOrderStatusEvent extends OrdersEvent {
  final String orderItemId;
  final Map<String, dynamic> payload;

  const UpdateOrderStatusEvent({
    required this.orderItemId,
    required this.payload,
  });

  @override
  List<Object?> get props => [orderItemId, payload];
}
