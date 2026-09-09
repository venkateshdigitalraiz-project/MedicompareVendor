import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_delivery_orders_usecase.dart';
import 'delivery_orders_event.dart';
import 'delivery_orders_state.dart';

class DeliveryOrdersBloc
    extends Bloc<DeliveryOrdersEvent, DeliveryOrdersState> {
  final GetDeliveryOrdersUseCase getDeliveryOrdersUseCase;

  DeliveryOrdersBloc({
    required this.getDeliveryOrdersUseCase,
  }) : super(const DeliveryOrdersInitial()) {
    on<LoadDeliveryOrdersEvent>(_onLoadDeliveryOrders);
    on<SearchDeliveryOrdersEvent>(_onSearchDeliveryOrders);
    on<FilterDeliveryOrdersEvent>(_onFilterDeliveryOrders);
    on<ChangeDeliveryOrdersPageEvent>(_onChangePage);
  }

  Future<void> _onLoadDeliveryOrders(
    LoadDeliveryOrdersEvent event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const DeliveryOrdersLoading());
    }

    try {
      final response = await getDeliveryOrdersUseCase(
        page: event.page,
        limit: event.limit,
        search: event.search,
        status: event.status == 'all' ? '' : event.status,
      );

      emit(DeliveryOrdersLoaded(
        items: response.list,
        summary: response.summary,
        pagination: response.pagination,
        searchQuery: event.search,
        statusFilter: event.status,
      ));
    } catch (e) {
      emit(DeliveryOrdersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSearchDeliveryOrders(
    SearchDeliveryOrdersEvent event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    final currentState = state;
    String currentStatus = 'all';
    if (currentState is DeliveryOrdersLoaded) {
      currentStatus = currentState.statusFilter;
    }

    add(LoadDeliveryOrdersEvent(
      page: 1,
      limit: 10,
      search: event.query,
      status: currentStatus,
    ));
  }

  Future<void> _onFilterDeliveryOrders(
    FilterDeliveryOrdersEvent event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    final currentState = state;
    String currentSearch = '';
    if (currentState is DeliveryOrdersLoaded) {
      currentSearch = currentState.searchQuery;
    }

    add(LoadDeliveryOrdersEvent(
      page: 1,
      limit: 10,
      search: currentSearch,
      status: event.status,
    ));
  }

  Future<void> _onChangePage(
    ChangeDeliveryOrdersPageEvent event,
    Emitter<DeliveryOrdersState> emit,
  ) async {
    final currentState = state;
    String currentSearch = '';
    String currentStatus = 'all';
    int limit = 10;

    if (currentState is DeliveryOrdersLoaded) {
      currentSearch = currentState.searchQuery;
      currentStatus = currentState.statusFilter;
      limit = currentState.pagination.limit;
    }

    add(LoadDeliveryOrdersEvent(
      page: event.page,
      limit: limit,
      search: currentSearch,
      status: currentStatus,
    ));
  }
}
