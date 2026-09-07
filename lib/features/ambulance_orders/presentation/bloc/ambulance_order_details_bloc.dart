import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../appointment/domain/entities/delivery_partner_entity.dart';
import '../../domain/usecases/assign_ambulance_delivery_partner_usecase.dart';
import '../../domain/usecases/get_ambulance_delivery_partners_usecase.dart';
import '../../domain/usecases/get_ambulance_order_details_usecase.dart';
import '../../domain/usecases/update_ambulance_booking_status_usecase.dart';
import 'ambulance_order_details_event.dart';
import 'ambulance_order_details_state.dart';

class AmbulanceOrderDetailsBloc
    extends Bloc<AmbulanceOrderDetailsEvent, AmbulanceOrderDetailsState> {
  final GetAmbulanceOrderDetailsUseCase getAmbulanceOrderDetailsUseCase;
  final UpdateAmbulanceBookingStatusUseCase updateAmbulanceBookingStatusUseCase;
  final GetAmbulanceDeliveryPartnersUseCase getDeliveryPartnersUseCase;
  final AssignAmbulanceDeliveryPartnerUseCase assignDeliveryPartnerUseCase;

  AmbulanceOrderDetailsBloc({
    required this.getAmbulanceOrderDetailsUseCase,
    required this.updateAmbulanceBookingStatusUseCase,
    required this.getDeliveryPartnersUseCase,
    required this.assignDeliveryPartnerUseCase,
  }) : super(AmbulanceOrderDetailsInitial()) {
    on<GetAmbulanceOrderDetailsEvent>(_onGetOrderDetails);
    on<UpdateAmbulanceBookingStatusEvent>(_onUpdateBookingStatus);
    on<GetAmbulanceDeliveryPartnersEvent>(_onGetDeliveryPartners);
    on<AssignAmbulanceDeliveryPartnerEvent>(_onAssignDeliveryPartner);
  }

  Future<void> _onGetOrderDetails(
    GetAmbulanceOrderDetailsEvent event,
    Emitter<AmbulanceOrderDetailsState> emit,
  ) async {
    emit(AmbulanceOrderDetailsLoading());
    try {
      final order = await getAmbulanceOrderDetailsUseCase.call(event.orderId);

      DeliveryPartnersResultEntity? partnersResult;
      bool hasLoaded = false;
      String? partnersError;

      if (order.bookingStatus.trim().toLowerCase() == 'confirmed') {
        try {
          partnersResult = await getDeliveryPartnersUseCase.call();
          hasLoaded = true;
        } catch (e) {
          hasLoaded = true;
          partnersError = e.toString().replaceAll('Exception: ', '');
        }
      }

      final initialPartners = partnersResult?.deliveryMans ?? [];
      emit(AmbulanceOrderDetailsLoaded(
        order,
        deliveryPartners: initialPartners,
        ownDeliveryPartner: partnersResult?.ownDeliveryUser,
        hasLoadedPartners: hasLoaded,
        partnersError: partnersError,
        partnersPage: 1,
        hasMorePartners: initialPartners.length >= 10,
        isLoadingMorePartners: false,
      ));
    } catch (e) {
      emit(AmbulanceOrderDetailsError(e.toString()));
    }
  }

  Future<void> _onUpdateBookingStatus(
    UpdateAmbulanceBookingStatusEvent event,
    Emitter<AmbulanceOrderDetailsState> emit,
  ) async {
    emit(AmbulanceBookingStatusUpdatingState());
    try {
      await updateAmbulanceBookingStatusUseCase.call(
        orderId: event.orderId,
        bookingStatus: event.bookingStatus,
        reason: event.reason,
      );
      final statusLower = event.bookingStatus.trim().toLowerCase();
      final successMsg = statusLower == 'confirmed'
          ? 'Booking confirmed successfully'
          : (statusLower == 'cancelled'
              ? 'Booking cancelled successfully'
              : 'Booking status updated successfully');
      emit(AmbulanceBookingStatusUpdatedState(message: successMsg));
    } catch (e) {
      emit(AmbulanceBookingStatusUpdateErrorState(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onGetDeliveryPartners(
    GetAmbulanceDeliveryPartnersEvent event,
    Emitter<AmbulanceOrderDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AmbulanceOrderDetailsLoaded) return;

    if (event.isLoadMore) {
      if (currentState.isLoadingMorePartners ||
          currentState.isLoadingPartners ||
          !currentState.hasMorePartners) {
        return;
      }
      emit(currentState.copyWith(isLoadingMorePartners: true));
      try {
        final partnersResult = await getDeliveryPartnersUseCase.call(
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
      final partnersResult = await getDeliveryPartnersUseCase.call(
        search: event.search,
        page: event.page,
        limit: 10,
      );
      if (state is AmbulanceOrderDetailsLoaded) {
        final newPartners = partnersResult.deliveryMans;
        emit((state as AmbulanceOrderDetailsLoaded).copyWith(
          deliveryPartners: newPartners,
          ownDeliveryPartner: partnersResult.ownDeliveryUser ??
              (state as AmbulanceOrderDetailsLoaded).ownDeliveryPartner,
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
      if (state is AmbulanceOrderDetailsLoaded) {
        emit((state as AmbulanceOrderDetailsLoaded).copyWith(
          isLoadingPartners: false,
          hasLoadedPartners: true,
          partnersError: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onAssignDeliveryPartner(
    AssignAmbulanceDeliveryPartnerEvent event,
    Emitter<AmbulanceOrderDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AmbulanceOrderDetailsLoaded) return;
    if (currentState.isAssigningPartner) return;

    emit(currentState.copyWith(isAssigningPartner: true));
    try {
      await assignDeliveryPartnerUseCase.call(
        orderId: event.orderId,
        deliveryPartnerId: event.deliveryPartnerId,
        deliveryManType: event.deliveryManType,
        deliveryPartner: event.deliveryPartner,
        readyTime: event.readyTime,
      );
      emit(const AmbulanceBookingStatusUpdatedState(
        message: 'Delivery partner assigned successfully',
      ));
    } catch (e) {
      if (state is AmbulanceOrderDetailsLoaded) {
        emit((state as AmbulanceOrderDetailsLoaded).copyWith(
          isAssigningPartner: false,
        ));
      }
      emit(AmbulanceBookingStatusUpdateErrorState(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
