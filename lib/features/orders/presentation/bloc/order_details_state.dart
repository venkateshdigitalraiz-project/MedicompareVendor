import 'package:equatable/equatable.dart';
import '../../../appointment/domain/entities/delivery_partner_entity.dart';
import '../../domain/entities/order_details_response_entity.dart';

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object?> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsLoaded extends OrderDetailsState {
  final OrderDetailsResponseEntity orderDetails;
  final List<DeliveryPartnerEntity> deliveryPartners;
  final DeliveryPartnerEntity? ownDeliveryPartner;
  final bool isLoadingPartners;
  final bool hasLoadedPartners;
  final String? partnersError;
  final int partnersPage;
  final bool hasMorePartners;
  final bool isLoadingMorePartners;
  final bool isAssigningPartner;
  final String? lastPartnersSearch;

  const OrderDetailsLoaded(
    this.orderDetails, {
    this.deliveryPartners = const [],
    this.ownDeliveryPartner,
    this.isLoadingPartners = false,
    this.hasLoadedPartners = false,
    this.partnersError,
    this.partnersPage = 1,
    this.hasMorePartners = true,
    this.isLoadingMorePartners = false,
    this.isAssigningPartner = false,
    this.lastPartnersSearch,
  });

  OrderDetailsLoaded copyWith({
    OrderDetailsResponseEntity? orderDetails,
    List<DeliveryPartnerEntity>? deliveryPartners,
    DeliveryPartnerEntity? ownDeliveryPartner,
    bool? isLoadingPartners,
    bool? hasLoadedPartners,
    String? partnersError,
    int? partnersPage,
    bool? hasMorePartners,
    bool? isLoadingMorePartners,
    bool? isAssigningPartner,
    String? lastPartnersSearch,
  }) {
    return OrderDetailsLoaded(
      orderDetails ?? this.orderDetails,
      deliveryPartners: deliveryPartners ?? this.deliveryPartners,
      ownDeliveryPartner: ownDeliveryPartner ?? this.ownDeliveryPartner,
      isLoadingPartners: isLoadingPartners ?? this.isLoadingPartners,
      hasLoadedPartners: hasLoadedPartners ?? this.hasLoadedPartners,
      partnersError: partnersError,
      partnersPage: partnersPage ?? this.partnersPage,
      hasMorePartners: hasMorePartners ?? this.hasMorePartners,
      isLoadingMorePartners:
          isLoadingMorePartners ?? this.isLoadingMorePartners,
      isAssigningPartner: isAssigningPartner ?? this.isAssigningPartner,
      lastPartnersSearch: lastPartnersSearch ?? this.lastPartnersSearch,
    );
  }

  @override
  List<Object?> get props => [
        orderDetails,
        deliveryPartners,
        ownDeliveryPartner,
        isLoadingPartners,
        hasLoadedPartners,
        partnersError,
        partnersPage,
        hasMorePartners,
        isLoadingMorePartners,
        isAssigningPartner,
        lastPartnersSearch,
      ];
}

class OrderActionLoading extends OrderDetailsState {}

class OrderStatusUpdated extends OrderDetailsState {
  final String message;

  const OrderStatusUpdated({this.message = 'Order status updated successfully'});

  @override
  List<Object?> get props => [message];
}

class OrderDetailsError extends OrderDetailsState {
  final String message;

  const OrderDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderAcceptEligibilityChecked extends OrderDetailsState {
  final OrderDetailsResponseEntity orderDetails;
  
  const OrderAcceptEligibilityChecked(this.orderDetails);
  
  @override
  List<Object?> get props => [orderDetails];
}

class OrderAcceptOtpPending extends OrderDetailsState {
  final String message;
  
  const OrderAcceptOtpPending(this.message);
  
  @override
  List<Object?> get props => [message];
}

