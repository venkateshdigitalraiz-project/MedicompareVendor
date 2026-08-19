import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;

  OrdersBloc({
    required this.getOrdersUseCase,
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
  }
}
