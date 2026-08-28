import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_appointment_details_usecase.dart';
import '../../domain/usecases/upload_report_usecase.dart';
import '../../domain/usecases/update_appointment_order_status_usecase.dart';
import 'appointment_details_event.dart';
import 'appointment_details_state.dart';

class AppointmentDetailsBloc
    extends Bloc<AppointmentDetailsEvent, AppointmentDetailsState> {
  final GetAppointmentDetailsUseCase getAppointmentDetailsUseCase;
  final UploadReportUseCase uploadReportUseCase;
  final UpdateAppointmentOrderStatusUseCase updateAppointmentOrderStatusUseCase;

  AppointmentDetailsBloc({
    required this.getAppointmentDetailsUseCase,
    required this.uploadReportUseCase,
    required this.updateAppointmentOrderStatusUseCase,
  }) : super(AppointmentDetailsInitial()) {
    on<GetAppointmentDetailsEvent>(_onGetAppointmentDetails);
    on<UploadReportEvent>(_onUploadReport);
    on<UpdateAppointmentOrderStatusEvent>(_onUpdateAppointmentOrderStatus);
  }

  Future<void> _onGetAppointmentDetails(
    GetAppointmentDetailsEvent event,
    Emitter<AppointmentDetailsState> emit,
  ) async {
    emit(AppointmentDetailsLoading());
    try {
      final result =
          await getAppointmentDetailsUseCase.call(event.appointmentId);
      emit(AppointmentDetailsLoaded(result));
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
      emit(AppointmentDetailsLoaded(result));
    } catch (e) {
      emit(ReportUploadErrorState(
          e.toString().replaceAll('Exception: ', ''), event.orderItemId));
    }
  }

  Future<void> _onUpdateAppointmentOrderStatus(
    UpdateAppointmentOrderStatusEvent event,
    Emitter<AppointmentDetailsState> emit,
  ) async {
    try {
      await updateAppointmentOrderStatusUseCase.call(
        orderId: event.orderId,
        orderStatus: event.orderStatus,
      );
      emit(const AppointmentStatusUpdatedState());
      final result =
          await getAppointmentDetailsUseCase.call(event.orderId);
      emit(AppointmentDetailsLoaded(result));
    } catch (e) {
      emit(AppointmentStatusUpdateErrorState(
          e.toString().replaceAll('Exception: ', '')));
    }
  }
}
