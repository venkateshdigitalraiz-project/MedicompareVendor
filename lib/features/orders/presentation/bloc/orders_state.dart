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
  final String? loadMoreError;

  const OrdersLoaded(
    this.ordersList, {
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  OrdersLoaded copyWith({
    OrdersListEntity? ordersList,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearError = false,
  }) {
    return OrdersLoaded(
      ordersList ?? this.ordersList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }

  @override
  List<Object?> get props => [ordersList, isLoadingMore, loadMoreError];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

