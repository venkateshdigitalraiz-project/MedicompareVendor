import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderDetailsUseCase getOrderDetailsUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  OrdersBloc({
    required this.getOrdersUseCase,
    required this.getOrderDetailsUseCase,
    required this.updateOrderStatusUseCase,
  }) : super(OrdersInitial()) {
    on<GetOrdersEvent>((event, emit) async {
      final currentState = state;
      if (event.isLoadMore && currentState is OrdersLoaded) {
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(OrdersLoading());
      }

      try {
        final result = await getOrdersUseCase.call(
          page: event.page,
          limit: event.limit,
          status: event.status,
          search: event.search,
          orderType: event.orderType,
        );

        if (event.isLoadMore && currentState is OrdersLoaded) {
          final updatedOrders =
              currentState.ordersList.orderItems + result.orderItems;
          emit(OrdersLoaded(
            OrdersListEntity(
              orderItems: updatedOrders,
              pagination: result.pagination,
            ),
            isLoadingMore: false,
          ));
        } else {
          emit(OrdersLoaded(result));
        }
      } catch (e) {
        emit(OrdersError(e.toString()));
      }
    });

    on<GetOrderDetailsEvent>((event, emit) async {
      emit(OrdersLoading());
      try {
        final result = await getOrderDetailsUseCase.call(event.orderId,
            orderType: event.orderType);
        emit(OrderDetailsLoaded(result));
      } catch (e) {
        emit(OrdersError(e.toString()));
      }
    });

    on<UpdateOrderStatusEvent>((event, emit) async {
      final currentState = state;
      emit(OrderActionLoading());
      try {
        await updateOrderStatusUseCase.call(event.orderItemId, event.payload);
        emit(const OrderStatusUpdated());
        // Do not reload details immediately here, let the UI trigger it so we don't have a race condition or state conflict
      } catch (e) {
        emit(OrdersError(e.toString()));
        emit(currentState);
      }
    });
  }
}
