import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/delivery_partner_entity.dart';
import '../../domain/usecases/get_appointment_details_usecase.dart';
import '../../domain/usecases/upload_report_usecase.dart';
import '../../domain/usecases/update_appointment_order_status_usecase.dart';
import '../../domain/usecases/get_delivery_partners_usecase.dart';
import '../../domain/usecases/assign_delivery_partner_usecase.dart';
import 'appointment_details_event.dart';
import 'appointment_details_state.dart';

class AppointmentDetailsBloc
    extends Bloc<AppointmentDetailsEvent, AppointmentDetailsState> {
  final GetAppointmentDetailsUseCase getAppointmentDetailsUseCase;
  final UploadReportUseCase uploadReportUseCase;
  final UpdateAppointmentOrderStatusUseCase updateAppointmentOrderStatusUseCase;
  final GetDeliveryPartnersUseCase getDeliveryPartnersUseCase;
  final AssignDeliveryPartnerUseCase assignDeliveryPartnerUseCase;

  AppointmentDetailsBloc({
    required this.getAppointmentDetailsUseCase,
    required this.uploadReportUseCase,
    required this.updateAppointmentOrderStatusUseCase,
    required this.getDeliveryPartnersUseCase,
    required this.assignDeliveryPartnerUseCase,
  }) : super(AppointmentDetailsInitial()) {
    on<GetAppointmentDetailsEvent>(_onGetAppointmentDetails);
    on<UploadReportEvent>(_onUploadReport);
    on<UpdateAppointmentOrderStatusEvent>(_onUpdateAppointmentOrderStatus);
    on<GetDeliveryPartnersEvent>(_onGetDeliveryPartners);
    on<AssignDeliveryPartnerEvent>(_onAssignDeliveryPartner);
  }

  Future<void> _onGetAppointmentDetails(
    GetAppointmentDetailsEvent event,
    Emitter<AppointmentDetailsState> emit,
  ) async {
    emit(AppointmentDetailsLoading());
    try {
      final result =
          await getAppointmentDetailsUseCase.call(event.appointmentId);

      DeliveryPartnersResultEntity? partnersResult;
      bool hasLoaded = false;
      String? partnersError;

      if (result.orderStatus.trim().toLowerCase() == 'confirmed') {
        try {
          partnersResult = await getDeliveryPartnersUseCase.call();
          hasLoaded = true;
        } catch (e) {
          hasLoaded = true;
          partnersError = e.toString().replaceAll('Exception: ', '');
        }
      }

      emit(AppointmentDetailsLoaded(
        result,
        deliveryPartners: partnersResult?.deliveryMans ?? [],
        ownDeliveryPartner: partnersResult?.ownDeliveryUser,
        hasLoadedPartners: hasLoaded,
        partnersError: partnersError,
      ));
    } catch (e) {
      emit(AppointmentDetailsError(e.toString()));
    }
  }

  Future<void> _onUploadReport(
    UploadReportEvent event,
    Emitter<AppointmentDetailsState> emit,
  ) async {
    emit(ReportUploadingState(event.orderItemId));
    try {
      await uploadReportUseCase.call(
        orderId: event.orderId,
        reportType: event.reportType,
        patientId: event.patientId,
        selectType: event.selectType,
        description: event.description,
        file: event.file,
      );
      emit(ReportUploadSuccessState(
          'Report uploaded successfully', event.orderItemId));
      // Re-fetch appointment details to get updated state from backend
      final result =
          await getAppointmentDetailsUseCase.call(event.orderId);
      final currentLoaded = state is AppointmentDetailsLoaded
          ? (state as AppointmentDetailsLoaded)
          : null;
      emit(AppointmentDetailsLoaded(
        result,
        deliveryPartners: currentLoaded?.deliveryPartners ?? [],
        ownDeliveryPartner: currentLoaded?.ownDeliveryPartner,
        hasLoadedPartners: currentLoaded?.hasLoadedPartners ?? false,
      ));
    } catch (e) {
      emit(ReportUploadErrorState(
          e.toString().replaceAll('Exception: ', ''), event.orderItemId));
    }
  }

  Future<void> _onUpdateAppointmentOrderStatus(
    UpdateAppointmentOrderStatusEvent event,
    Emitter<AppointmentDetailsState> emit,
  ) async {
    emit(AppointmentStatusUpdatingState());
    try {
      await updateAppointmentOrderStatusUseCase.call(
        orderId: event.orderId,
        orderStatus: event.orderStatus,
        rejectionReason: event.rejectionReason,
      );
      final statusLower = event.orderStatus.trim().toLowerCase();
      final successMsg = statusLower == 'confirmed'
          ? 'Order confirmed successfully'
          : (statusLower == 'cancelled'
              ? 'Order cancelled successfully'
              : 'Order status updated successfully');
      emit(AppointmentStatusUpdatedState(message: successMsg));
    } catch (e) {
      emit(AppointmentStatusUpdateErrorState(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetDeliveryPartners(
    GetDeliveryPartnersEvent event,
    Emitter<AppointmentDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AppointmentDetailsLoaded) return;

    // Prevent duplicate API calls while loading or if already loaded with same search
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
      );
      if (state is AppointmentDetailsLoaded) {
        emit((state as AppointmentDetailsLoaded).copyWith(
          deliveryPartners: partnersResult.deliveryMans,
          ownDeliveryPartner: partnersResult.ownDeliveryUser ??
              (state as AppointmentDetailsLoaded).ownDeliveryPartner,
          isLoadingPartners: false,
          hasLoadedPartners: true,
          partnersError: null,
          lastPartnersSearch: event.search,
        ));
      }
    } catch (e) {
      if (state is AppointmentDetailsLoaded) {
        emit((state as AppointmentDetailsLoaded).copyWith(
          isLoadingPartners: false,
          hasLoadedPartners: true,
          partnersError: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onAssignDeliveryPartner(
    AssignDeliveryPartnerEvent event,
    Emitter<AppointmentDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AppointmentDetailsLoaded) return;
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
      emit(const AppointmentStatusUpdatedState(
          message: 'Delivery partner assigned successfully'));
    } catch (e) {
      if (state is AppointmentDetailsLoaded) {
        emit((state as AppointmentDetailsLoaded).copyWith(
          isAssigningPartner: false,
        ));
      }
      emit(AppointmentStatusUpdateErrorState(
          e.toString().replaceAll('Exception: ', '')));
    }
  }
}
