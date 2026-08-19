import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import 'order_details_event.dart';
import 'order_details_state.dart';

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  final GetOrderDetailsUseCase getOrderDetailsUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  OrderDetailsBloc({
    required this.getOrderDetailsUseCase,
    required this.updateOrderStatusUseCase,
  }) : super(OrderDetailsInitial()) {
    on<GetOrderDetailsEvent>((event, emit) async {
      emit(OrderDetailsLoading());
      try {
        final result = await getOrderDetailsUseCase.call(event.orderId,
            orderType: event.orderType);
        emit(OrderDetailsLoaded(result));
      } catch (e) {
        emit(OrderDetailsError(e.toString()));
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
        emit(OrderDetailsError(e.toString()));
        emit(currentState);
      }
    });
  }
}
