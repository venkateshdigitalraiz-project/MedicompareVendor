import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/deliveryman_entity.dart';
import '../../domain/usecases/get_deliverymen_usecase.dart';
import '../../domain/usecases/delete_deliveryman_usecase.dart';
import 'deliveryman_event.dart';
import 'deliveryman_state.dart';

class DeliverymanBloc extends Bloc<DeliverymanEvent, DeliverymanState> {
  final GetDeliverymenUseCase getDeliverymenUseCase;
  final DeleteDeliverymanUseCase deleteDeliverymanUseCase;

  DeliverymanBloc({
    required this.getDeliverymenUseCase,
    required this.deleteDeliverymanUseCase,
  }) : super(const DeliverymanInitial()) {
    on<LoadDeliverymenEvent>(_onLoadDeliverymen);
    on<SearchDeliverymenEvent>(_onSearchDeliverymen);
    on<FilterDeliverymenEvent>(_onFilterDeliverymen);
    on<ChangeDeliverymenPageEvent>(_onChangePage);
    on<DeleteDeliverymanEvent>(_onDeleteDeliveryman);
  }

  Future<void> _onLoadDeliverymen(
    LoadDeliverymenEvent event,
    Emitter<DeliverymanState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const DeliverymanLoading());
    }

    try {
      final response = await getDeliverymenUseCase(
        page: event.page,
        limit: event.limit,
        search: event.search,
        status: event.status == 'all' ? '' : event.status,
      );

      emit(DeliverymanLoaded(
        items: response.list,
        summary: response.summary,
        pagination: response.pagination,
        searchQuery: event.search,
        statusFilter: event.status,
        isDeleting: false,
      ));
    } catch (e) {
      emit(DeliverymanError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSearchDeliverymen(
    SearchDeliverymenEvent event,
    Emitter<DeliverymanState> emit,
  ) async {
    final currentState = state;
    String currentStatus = 'all';
    if (currentState is DeliverymanLoaded) {
      currentStatus = currentState.statusFilter;
    }

    add(LoadDeliverymenEvent(
      page: 1,
      limit: 10,
      search: event.query,
      status: currentStatus,
    ));
  }

  Future<void> _onFilterDeliverymen(
    FilterDeliverymenEvent event,
    Emitter<DeliverymanState> emit,
  ) async {
    final currentState = state;
    String currentSearch = '';
    if (currentState is DeliverymanLoaded) {
      currentSearch = currentState.searchQuery;
    }

    add(LoadDeliverymenEvent(
      page: 1,
      limit: 10,
      search: currentSearch,
      status: event.status,
    ));
  }

  Future<void> _onChangePage(
    ChangeDeliverymenPageEvent event,
    Emitter<DeliverymanState> emit,
  ) async {
    final currentState = state;
    String currentSearch = '';
    String currentStatus = 'all';
    int limit = 10;

    if (currentState is DeliverymanLoaded) {
      currentSearch = currentState.searchQuery;
      currentStatus = currentState.statusFilter;
      limit = currentState.pagination.limit;
    }

    add(LoadDeliverymenEvent(
      page: event.page,
      limit: limit,
      search: currentSearch,
      status: currentStatus,
    ));
  }

  Future<void> _onDeleteDeliveryman(
    DeleteDeliverymanEvent event,
    Emitter<DeliverymanState> emit,
  ) async {
    final currentState = state;
    if (currentState is DeliverymanLoaded) {
      emit(currentState.copyWith(
        isDeleting: true,
        clearActionMessage: true,
      ));

      try {
        await deleteDeliverymanUseCase(event.id);

        final updatedItems =
            currentState.items.where((item) => item.id != event.id).toList();

        int active = 0;
        int inactive = 0;
        int completed = 0;
        for (final item in updatedItems) {
          if (item.isActive) {
            active++;
          } else {
            inactive++;
          }
          completed += item.totalDeliveries;
        }

        final updatedSummary = DeliverymanSummaryEntity(
          totalPersonnel: updatedItems.length,
          activePartners: active,
          inactivePartners: inactive,
          completedDeliveries: completed,
        );

        emit(currentState.copyWith(
          items: updatedItems,
          summary: updatedSummary,
          isDeleting: false,
          actionMessage: "Deliveryman deleted successfully",
        ));

        // Re-fetch in background to sync server state
        add(LoadDeliverymenEvent(
          page: currentState.pagination.page,
          limit: currentState.pagination.limit,
          search: currentState.searchQuery,
          status: currentState.statusFilter,
          isRefresh: true,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isDeleting: false,
          actionMessage:
              'Failed to delete: ${e.toString().replaceAll('Exception: ', '')}',
        ));
      }
    }
  }
}
