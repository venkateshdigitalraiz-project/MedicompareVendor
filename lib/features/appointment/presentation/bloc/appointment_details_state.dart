import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_details_entity.dart';
import '../../domain/entities/delivery_partner_entity.dart';

abstract class AppointmentDetailsState extends Equatable {
  const AppointmentDetailsState();

  @override
  List<Object?> get props => [];
}

class AppointmentDetailsInitial extends AppointmentDetailsState {}

class AppointmentDetailsLoading extends AppointmentDetailsState {}

class AppointmentDetailsLoaded extends AppointmentDetailsState {
  final AppointmentDetailsEntity appointmentDetails;
  final List<DeliveryPartnerEntity> deliveryPartners;
  final DeliveryPartnerEntity? ownDeliveryPartner;
  final bool isLoadingPartners;
  final bool hasLoadedPartners;
  final String? partnersError;
  final bool isAssigningPartner;
  final String? lastPartnersSearch;

  const AppointmentDetailsLoaded(
    this.appointmentDetails, {
    this.deliveryPartners = const [],
    this.ownDeliveryPartner,
    this.isLoadingPartners = false,
    this.hasLoadedPartners = false,
    this.partnersError,
    this.isAssigningPartner = false,
    this.lastPartnersSearch,
  });

  AppointmentDetailsLoaded copyWith({
    AppointmentDetailsEntity? appointmentDetails,
    List<DeliveryPartnerEntity>? deliveryPartners,
    DeliveryPartnerEntity? ownDeliveryPartner,
    bool? isLoadingPartners,
    bool? hasLoadedPartners,
    String? partnersError,
    bool? isAssigningPartner,
    String? lastPartnersSearch,
  }) {
    return AppointmentDetailsLoaded(
      appointmentDetails ?? this.appointmentDetails,
      deliveryPartners: deliveryPartners ?? this.deliveryPartners,
      ownDeliveryPartner: ownDeliveryPartner ?? this.ownDeliveryPartner,
      isLoadingPartners: isLoadingPartners ?? this.isLoadingPartners,
      hasLoadedPartners: hasLoadedPartners ?? this.hasLoadedPartners,
      partnersError: partnersError,
      isAssigningPartner: isAssigningPartner ?? this.isAssigningPartner,
      lastPartnersSearch: lastPartnersSearch ?? this.lastPartnersSearch,
    );
  }

  @override
  List<Object?> get props => [
        appointmentDetails,
        deliveryPartners,
        ownDeliveryPartner,
        isLoadingPartners,
        hasLoadedPartners,
        partnersError,
        isAssigningPartner,
        lastPartnersSearch,
      ];
}

class AppointmentDetailsError extends AppointmentDetailsState {
  final String message;

  const AppointmentDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportUploadingState extends AppointmentDetailsState {
  final String orderItemId;
  final String itemKey;
  final String? patientId;
  final String? selectType;

  const ReportUploadingState(this.orderItemId, this.itemKey, {this.patientId, this.selectType});

  @override
  List<Object?> get props => [orderItemId, itemKey, patientId, selectType];
}

class ReportUploadSuccessState extends AppointmentDetailsState {
  final String message;
  final String orderItemId;
  final String itemKey;

  const ReportUploadSuccessState(this.message, this.orderItemId, this.itemKey);

  @override
  List<Object?> get props => [message, orderItemId, itemKey];
}

class ReportUploadErrorState extends AppointmentDetailsState {
  final String message;
  final String orderItemId;
  final String itemKey;

  const ReportUploadErrorState(this.message, this.orderItemId, this.itemKey);

  @override
  List<Object?> get props => [message, orderItemId, itemKey];
}

class AppointmentStatusUpdatingState extends AppointmentDetailsState {
  final bool isOtpVerification;
  final String? updatingStatus;

  const AppointmentStatusUpdatingState({
    this.isOtpVerification = false,
    this.updatingStatus,
  });

  @override
  List<Object?> get props => [isOtpVerification, updatingStatus];
}

class AppointmentStatusUpdatedState extends AppointmentDetailsState {
  final String message;

  const AppointmentStatusUpdatedState({this.message = 'Status updated successfully'});

  @override
  List<Object?> get props => [message];
}

class AppointmentStatusUpdateErrorState extends AppointmentDetailsState {
  final String message;

  const AppointmentStatusUpdateErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

