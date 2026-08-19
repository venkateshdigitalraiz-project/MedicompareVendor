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
