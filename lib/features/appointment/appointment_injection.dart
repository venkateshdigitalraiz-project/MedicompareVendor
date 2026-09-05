import '../../core/utils/core_injection.dart';
import 'data/datasources/appointment_remote_data_source.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'domain/repositories/appointment_repository.dart';
import 'domain/usecases/get_appointments_usecase.dart';
import 'domain/usecases/get_appointment_details_usecase.dart';
import 'domain/usecases/upload_report_usecase.dart';
import 'domain/usecases/update_appointment_order_status_usecase.dart';
import 'domain/usecases/get_delivery_partners_usecase.dart';
import 'domain/usecases/assign_delivery_partner_usecase.dart';
import 'presentation/bloc/appointment_booking_bloc.dart';
import 'presentation/bloc/appointment_details_bloc.dart';

class AppointmentInjection {
  static AppointmentDetailsBloc provideAppointmentDetailsBloc() {
    return AppointmentDetailsBloc(
      getAppointmentDetailsUseCase: provideGetAppointmentDetailsUseCase(),
      uploadReportUseCase: provideUploadReportUseCase(),
      updateAppointmentOrderStatusUseCase:
          provideUpdateAppointmentOrderStatusUseCase(),
      getDeliveryPartnersUseCase: provideGetDeliveryPartnersUseCase(),
      assignDeliveryPartnerUseCase: provideAssignDeliveryPartnerUseCase(),
    );
  }

  static GetDeliveryPartnersUseCase provideGetDeliveryPartnersUseCase() {
    return GetDeliveryPartnersUseCase(provideAppointmentRepository());
  }

  static AssignDeliveryPartnerUseCase provideAssignDeliveryPartnerUseCase() {
    return AssignDeliveryPartnerUseCase(provideAppointmentRepository());
  }

  static GetAppointmentDetailsUseCase provideGetAppointmentDetailsUseCase() {
    return GetAppointmentDetailsUseCase(provideAppointmentRepository());
  }

  static UploadReportUseCase provideUploadReportUseCase() {
    return UploadReportUseCase(provideAppointmentRepository());
  }

  static UpdateAppointmentOrderStatusUseCase
      provideUpdateAppointmentOrderStatusUseCase() {
    return UpdateAppointmentOrderStatusUseCase(provideAppointmentRepository());
  }

  static AppointmentBookingBloc provideAppointmentBookingBloc() {
    return AppointmentBookingBloc(
      getAppointmentsUseCase: provideGetAppointmentsUseCase(),
    );
  }

  static GetAppointmentsUseCase provideGetAppointmentsUseCase() {
    return GetAppointmentsUseCase(provideAppointmentRepository());
  }

  static AppointmentRepository provideAppointmentRepository() {
    return AppointmentRepositoryImpl(
      remoteDataSource: provideAppointmentRemoteDataSource(),
    );
  }

  static AppointmentRemoteDataSource provideAppointmentRemoteDataSource() {
    return AppointmentRemoteDataSourceImpl(
      apiService: CoreInjection.provideApiService(),
    );
  }
}
