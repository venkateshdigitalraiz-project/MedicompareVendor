import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/ambulance_orders_remote_data_source.dart';
import '../../domain/entities/ambulance_order_entity.dart';
import 'ambulance_orders_event.dart';
import 'ambulance_orders_state.dart';

class AmbulanceOrdersBloc
    extends Bloc<AmbulanceOrdersEvent, AmbulanceOrdersState> {
  final AmbulanceOrdersRemoteDataSource dataSource;

  AmbulanceOrdersBloc({required this.dataSource})
      : super(AmbulanceOrdersInitial()) {
    on<LoadAmbulanceOrdersEvent>(_onLoad);
    on<LoadAmbulanceOrderDetailsEvent>(_onLoadDetails);
  }

  Future<void> _onLoad(LoadAmbulanceOrdersEvent event,
      Emitter<AmbulanceOrdersState> emit) async {
    final currentState = state;
    if (event.isLoadMore && currentState is AmbulanceOrdersLoaded) {
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(AmbulanceOrdersLoading());
    }
    try {
      final result = await dataSource.getBookingList(
        page: event.page,
        limit: event.limit,
        status: event.status,
        search: event.search,
      );
      if (event.isLoadMore && currentState is AmbulanceOrdersLoaded) {
        final merged = AmbulanceOrdersListEntity(
          orders: [...currentState.data.orders, ...result.orders],
          total: result.total,
          page: result.page,
          limit: result.limit,
          totalPages: result.totalPages,
        );
        emit(AmbulanceOrdersLoaded(merged,
            isLoadingMore: false, selectedStatus: event.status));
      } else {
        emit(AmbulanceOrdersLoaded(result, selectedStatus: event.status));
      }
    } catch (e) {
      emit(AmbulanceOrdersError(e.toString()));
    }
  }

  Future<void> _onLoadDetails(LoadAmbulanceOrderDetailsEvent event,
      Emitter<AmbulanceOrdersState> emit) async {
    emit(AmbulanceOrdersLoading());
    try {
      final order = await dataSource.getBookingDetails(event.id);
      emit(AmbulanceOrderDetailsLoaded(order));
    } catch (e) {
      emit(AmbulanceOrdersError(e.toString()));
    }
  }
}
