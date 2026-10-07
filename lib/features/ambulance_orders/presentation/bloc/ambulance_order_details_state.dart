import 'package:equatable/equatable.dart';
import '../../domain/entities/ambulance_order_entity.dart';
import '../../../appointment/domain/entities/delivery_partner_entity.dart';

abstract class AmbulanceOrderDetailsState extends Equatable {
  const AmbulanceOrderDetailsState();

  @override
  List<Object?> get props => [];
}

class AmbulanceOrderDetailsInitial extends AmbulanceOrderDetailsState {}

class AmbulanceOrderDetailsLoading extends AmbulanceOrderDetailsState {}

class AmbulanceOrderDetailsLoaded extends AmbulanceOrderDetailsState {
  final AmbulanceOrderEntity order;
  final List<DeliveryPartnerEntity> deliveryPartners;
  final List<DeliveryPartnerEntity> ownDeliveryPartners;
  final DeliveryPartnerEntity? ownDeliveryPartner;
  final bool isLoadingPartners;
  final bool hasLoadedPartners;
  final String? partnersError;
  final bool isAssigningPartner;
  final String? lastPartnersSearch;
  final int partnersPage;
  final bool hasMorePartners;
  final bool isLoadingMorePartners;

  const AmbulanceOrderDetailsLoaded(
    this.order, {
    this.deliveryPartners = const [],
    this.ownDeliveryPartners = const [],
    this.ownDeliveryPartner,
    this.isLoadingPartners = false,
    this.hasLoadedPartners = false,
    this.partnersError,
    this.isAssigningPartner = false,
    this.lastPartnersSearch,
    this.partnersPage = 1,
    this.hasMorePartners = true,
    this.isLoadingMorePartners = false,
  });

  AmbulanceOrderDetailsLoaded copyWith({
    AmbulanceOrderEntity? order,
    List<DeliveryPartnerEntity>? deliveryPartners,
    List<DeliveryPartnerEntity>? ownDeliveryPartners,
    DeliveryPartnerEntity? ownDeliveryPartner,
    bool? isLoadingPartners,
    bool? hasLoadedPartners,
    String? partnersError,
    bool? isAssigningPartner,
    String? lastPartnersSearch,
    int? partnersPage,
    bool? hasMorePartners,
    bool? isLoadingMorePartners,
  }) {
    return AmbulanceOrderDetailsLoaded(
      order ?? this.order,
      deliveryPartners: deliveryPartners ?? this.deliveryPartners,
      ownDeliveryPartners: ownDeliveryPartners ?? this.ownDeliveryPartners,
      ownDeliveryPartner: ownDeliveryPartner ?? this.ownDeliveryPartner,
      isLoadingPartners: isLoadingPartners ?? this.isLoadingPartners,
      hasLoadedPartners: hasLoadedPartners ?? this.hasLoadedPartners,
      partnersError: partnersError,
      isAssigningPartner: isAssigningPartner ?? this.isAssigningPartner,
      lastPartnersSearch: lastPartnersSearch ?? this.lastPartnersSearch,
      partnersPage: partnersPage ?? this.partnersPage,
      hasMorePartners: hasMorePartners ?? this.hasMorePartners,
      isLoadingMorePartners:
          isLoadingMorePartners ?? this.isLoadingMorePartners,
    );
  }

  @override
  List<Object?> get props => [
        order,
        deliveryPartners,
        ownDeliveryPartners,
        ownDeliveryPartner,
        isLoadingPartners,
        hasLoadedPartners,
        partnersError,
        isAssigningPartner,
        lastPartnersSearch,
        partnersPage,
        hasMorePartners,
        isLoadingMorePartners,
      ];
}

class AmbulanceOrderDetailsError extends AmbulanceOrderDetailsState {
  final String message;

  const AmbulanceOrderDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AmbulanceBookingStatusUpdatingState extends AmbulanceOrderDetailsState {}

class AmbulanceBookingStatusUpdatedState extends AmbulanceOrderDetailsState {
  final String message;

  const AmbulanceBookingStatusUpdatedState({this.message = 'Booking status updated successfully'});

  @override
  List<Object?> get props => [message];
}

class AmbulanceBookingStatusUpdateErrorState extends AmbulanceOrderDetailsState {
  final String message;

  const AmbulanceBookingStatusUpdateErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
