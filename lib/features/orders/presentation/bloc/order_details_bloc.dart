import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../appointment/domain/entities/delivery_partner_entity.dart';
import '../../domain/usecases/assign_order_delivery_partner_usecase.dart';
import '../../domain/usecases/get_order_delivery_partners_usecase.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import 'order_details_event.dart';
import 'order_details_state.dart';

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  final GetOrderDetailsUseCase getOrderDetailsUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final GetOrderDeliveryPartnersUseCase getOrderDeliveryPartnersUseCase;
  final AssignOrderDeliveryPartnerUseCase assignOrderDeliveryPartnerUseCase;

  OrderDetailsBloc({
    required this.getOrderDetailsUseCase,
    required this.updateOrderStatusUseCase,
    required this.getOrderDeliveryPartnersUseCase,
    required this.assignOrderDeliveryPartnerUseCase,
  }) : super(OrderDetailsInitial()) {
    on<GetOrderDetailsEvent>(_onGetOrderDetails);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<GetOrderDeliveryPartnersEvent>(_onGetDeliveryPartners);
    on<AssignOrderDeliveryPartnerEvent>(_onAssignDeliveryPartner);
  }

  Future<void> _onGetOrderDetails(
    GetOrderDetailsEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    emit(OrderDetailsLoading());
    try {
      final result = await getOrderDetailsUseCase.call(event.orderId,
          orderType: event.orderType);

      DeliveryPartnersResultEntity? partnersResult;
      bool hasLoaded = false;
      String? partnersError;
      final statusLower = result.orderStatus.toLowerCase();
      if (statusLower == 'confirmed') {
        try {
          partnersResult = await getOrderDeliveryPartnersUseCase.call(
            search: '',
            page: 1,
            limit: 10,
          );
          hasLoaded = true;
        } catch (e) {
          partnersError = e.toString().replaceAll('Exception: ', '');
        }
      }

      final initialPartners = partnersResult?.deliveryMans ?? [];
      emit(OrderDetailsLoaded(
        result,
        deliveryPartners: initialPartners,
        ownDeliveryPartner: partnersResult?.ownDeliveryUser,
        hasLoadedPartners: hasLoaded,
        partnersError: partnersError,
        partnersPage: 1,
        hasMorePartners: initialPartners.length >= 10,
        isLoadingMorePartners: false,
      ));
    } catch (e) {
      emit(OrderDetailsError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    final currentState = state;
    emit(OrderActionLoading());
    try {
      await updateOrderStatusUseCase.call(event.orderItemId, event.payload);
      emit(const OrderStatusUpdated());
    } catch (e) {
      emit(OrderDetailsError(e.toString()));
      if (currentState is OrderDetailsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onGetDeliveryPartners(
    GetOrderDeliveryPartnersEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrderDetailsLoaded) return;

    if (event.isLoadMore) {
      if (currentState.isLoadingMorePartners ||
          currentState.isLoadingPartners ||
          !currentState.hasMorePartners) {
        return;
      }
      emit(currentState.copyWith(isLoadingMorePartners: true));
      try {
        final partnersResult = await getOrderDeliveryPartnersUseCase.call(
          search: event.search,
          page: event.page,
          limit: 10,
        );
        final newPartners = partnersResult.deliveryMans;
        final hasMore = newPartners.length >= 10;
        final updatedList =
            List<DeliveryPartnerEntity>.from(currentState.deliveryPartners);
        for (final p in newPartners) {
          if (!updatedList.any((existing) => existing.id == p.id)) {
            updatedList.add(p);
          }
        }
        emit(currentState.copyWith(
          deliveryPartners: updatedList,
          isLoadingMorePartners: false,
          hasMorePartners: hasMore,
          partnersPage: event.page,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isLoadingMorePartners: false,
        ));
      }
      return;
    }

    if (!event.forceRefresh && currentState.isLoadingPartners) {
      return;
    }

    if (!event.forceRefresh &&
        currentState.hasLoadedPartners &&
        currentState.lastPartnersSearch == event.search) {
      return;
    }

    emit(currentState.copyWith(
      isLoadingPartners: true,
      lastPartnersSearch: event.search,
    ));

    try {
      final partnersResult = await getOrderDeliveryPartnersUseCase.call(
        search: event.search,
        page: event.page,
        limit: 10,
      );
      if (state is OrderDetailsLoaded) {
        final newPartners = partnersResult.deliveryMans;
        emit((state as OrderDetailsLoaded).copyWith(
          deliveryPartners: newPartners,
          ownDeliveryPartner: partnersResult.ownDeliveryUser ??
              (state as OrderDetailsLoaded).ownDeliveryPartner,
          isLoadingPartners: false,
          hasLoadedPartners: true,
          partnersError: null,
          lastPartnersSearch: event.search,
          partnersPage: event.page,
          hasMorePartners: newPartners.length >= 10,
          isLoadingMorePartners: false,
        ));
      }
    } catch (e) {
      if (state is OrderDetailsLoaded) {
        emit((state as OrderDetailsLoaded).copyWith(
          isLoadingPartners: false,
          hasLoadedPartners: true,
          partnersError: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onAssignDeliveryPartner(
    AssignOrderDeliveryPartnerEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderDetailsLoaded) {
      emit(currentState.copyWith(isAssigningPartner: true));
    } else {
      emit(OrderActionLoading());
    }

    try {
      await assignOrderDeliveryPartnerUseCase.call(
        orderId: event.orderId,
        deliveryPartnerId: event.deliveryPartnerId,
        deliveryManType: event.deliveryManType,
        deliveryPartner: event.deliveryPartner,
        readyTime: event.readyTime,
      );
      emit(const OrderStatusUpdated(
          message: 'Delivery partner assigned successfully'));
    } catch (e) {
      emit(OrderDetailsError(
          e.toString().replaceAll('Exception: ', '')));
      if (currentState is OrderDetailsLoaded) {
        emit(currentState.copyWith(isAssigningPartner: false));
      }
    }
  }
}

