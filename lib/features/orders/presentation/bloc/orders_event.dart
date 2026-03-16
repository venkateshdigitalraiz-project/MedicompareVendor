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

  const GetOrdersEvent({
    this.page = 1,
    this.limit = 10,
    this.status = '',
    this.search = '',
  });

  @override
  List<Object?> get props => [page, limit, status, search];
}

class GetOrderDetailsEvent extends OrdersEvent {
  final String orderId;

  const GetOrderDetailsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
