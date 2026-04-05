import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final OrdersListEntity ordersList;
  final bool isLoadingMore;

  const OrdersLoaded(this.ordersList, {this.isLoadingMore = false});

  OrdersLoaded copyWith({
    OrdersListEntity? ordersList,
    bool? isLoadingMore,
  }) {
    return OrdersLoaded(
      ordersList ?? this.ordersList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [ordersList, isLoadingMore];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderDetailsLoaded extends OrdersState {
  final OrderItemEntity order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderActionLoading extends OrdersState {}

class OrderStatusUpdated extends OrdersState {
  final String message;

  const OrderStatusUpdated(
      {this.message = 'Order status updated successfully'});

  @override
  List<Object?> get props => [message];
}
