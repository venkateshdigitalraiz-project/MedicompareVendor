import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;

  OrdersBloc({required this.getOrdersUseCase}) : super(OrdersInitial()) {
    on<GetOrdersEvent>((event, emit) async {
      emit(OrdersLoading());
      try {
        final result = await getOrdersUseCase.call(
          page: event.page,
          limit: event.limit,
          status: event.status,
          search: event.search,
        );
        
        // ignore: unnecessary_null_comparison
        if (result == null) {
          emit(const OrdersError("Received null orders list from server"));
        } else {
          emit(OrdersLoaded(result));
        }
      } catch (e) {
        emit(OrdersError(e.toString()));
      }
    });
  }
}
