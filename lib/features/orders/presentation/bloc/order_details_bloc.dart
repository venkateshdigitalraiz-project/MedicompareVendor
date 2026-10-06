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
    on<CheckAcceptEligibilityEvent>(_onCheckAcceptEligibility);
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
      final statusLower =
          result.orderStatus.trim().toLowerCase().replaceAll(' ', '_');
      if (statusLower == 'confirmed' ||
          statusLower == 'order_confirmed' ||
          statusLower == 'accepted' ||
          statusLower == 'order_accepted' ||
          statusLower == 'processing') {
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
      final targetStatusLower = event.payload['orderStatus']?.toString().toLowerCase() ?? 
                                event.payload['status']?.toString().toLowerCase() ?? '';
      
      final isAccepting = targetStatusLower == 'confirmed' ||
                          targetStatusLower == 'order_confirmed' ||
                          targetStatusLower == 'accepted' ||
                          targetStatusLower == 'order_accepted' ||
                          targetStatusLower == 'processing';

      DeliveryPartnersResultEntity? partnersResult;
      bool hasLoaded = false;
      String? partnersError;

      // Start the update process
      Future<void> updateFuture = updateOrderStatusUseCase.call(event.orderItemId, event.payload);
      
      // Concurrently start the partners fetch if we are accepting the order
      Future<DeliveryPartnersResultEntity?> partnersFuture = Future.value(null);
      if (isAccepting) {
        partnersFuture = getOrderDeliveryPartnersUseCase.call(
          search: '',
          page: 1,
          limit: 10,
        ).catchError((e) {
          partnersError = e.toString().replaceAll('Exception: ', '');
          return null;
        });
      }

      // Wait for both to complete in parallel
      await updateFuture;
      partnersResult = await partnersFuture;
      if (partnersResult != null) hasLoaded = true;

      // Fetch fresh details seamlessly after update
      final updatedDetails = await getOrderDetailsUseCase.call(event.orderItemId);
      
      emit(const OrderStatusUpdated());
      
      if (currentState is OrderDetailsLoaded) {
        final initialPartners = partnersResult?.deliveryMans ?? currentState.deliveryPartners;
        final ownPartner = partnersResult?.ownDeliveryUser ?? currentState.ownDeliveryPartner;
        
        emit(currentState.copyWith(
          orderDetails: updatedDetails,
          deliveryPartners: initialPartners,
          ownDeliveryPartner: ownPartner,
          hasLoadedPartners: hasLoaded || currentState.hasLoadedPartners,
          partnersError: partnersError,
        ));
      }
    } catch (e) {
      emit(OrderDetailsError(e.toString().replaceAll('Exception: ', '')));
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
      
      // Immediately refresh the order details after assignment
      final updatedDetails = await getOrderDetailsUseCase.call(event.orderId);
      
      emit(const OrderStatusUpdated(
          message: 'Delivery partner assigned successfully'));
          
      if (currentState is OrderDetailsLoaded) {
        emit(currentState.copyWith(
          isAssigningPartner: false,
          orderDetails: updatedDetails,
        ));
      }
    } catch (e) {
      emit(OrderDetailsError(
          e.toString().replaceAll('Exception: ', '')));
      if (currentState is OrderDetailsLoaded) {
        emit(currentState.copyWith(isAssigningPartner: false));
      }
    }
  }

  Future<void> _onCheckAcceptEligibility(
    CheckAcceptEligibilityEvent event,
    Emitter<OrderDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrderDetailsLoaded) return;
    
    final orderDetails = currentState.orderDetails;
    final otpEnable = orderDetails.otpEnable?.toLowerCase() ?? 'no';
    final otpStatus = orderDetails.otpStatus?.toLowerCase() ?? '';

    if (otpEnable == 'no' || (otpEnable == 'yes' && otpStatus == 'verified')) {
      emit(OrderAcceptEligibilityChecked(orderDetails));
    } else {
      emit(const OrderAcceptOtpPending('Please submit OTP'));
    }
    
    // Restore UI state immediately
    emit(currentState);
  }
}

