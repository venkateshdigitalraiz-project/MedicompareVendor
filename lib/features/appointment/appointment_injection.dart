import '../../core/utils/core_injection.dart';
import 'data/datasources/appointment_remote_data_source.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'domain/repositories/appointment_repository.dart';
import 'domain/usecases/get_appointments_usecase.dart';
import 'domain/usecases/get_appointment_details_usecase.dart';
import 'presentation/bloc/appointment_booking_bloc.dart';
import 'presentation/bloc/appointment_details_bloc.dart';

class AppointmentInjection {
  static AppointmentDetailsBloc provideAppointmentDetailsBloc() {
    return AppointmentDetailsBloc(
      getAppointmentDetailsUseCase: provideGetAppointmentDetailsUseCase(),
    );
  }

  static GetAppointmentDetailsUseCase provideGetAppointmentDetailsUseCase() {
    return GetAppointmentDetailsUseCase(provideAppointmentRepository());
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
