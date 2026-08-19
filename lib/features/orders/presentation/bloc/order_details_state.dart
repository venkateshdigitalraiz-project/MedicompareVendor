import 'package:equatable/equatable.dart';
import '../../domain/entities/order_details_response_entity.dart';

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object?> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsLoaded extends OrderDetailsState {
  final OrderDetailsResponseEntity orderDetails;

  const OrderDetailsLoaded(this.orderDetails);

  @override
  List<Object?> get props => [orderDetails];
}

class OrderActionLoading extends OrderDetailsState {}

class OrderStatusUpdated extends OrderDetailsState {
  final String message;

  const OrderStatusUpdated({this.message = 'Order status updated successfully'});

  @override
  List<Object?> get props => [message];
}

class OrderDetailsError extends OrderDetailsState {
  final String message;

  const OrderDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
