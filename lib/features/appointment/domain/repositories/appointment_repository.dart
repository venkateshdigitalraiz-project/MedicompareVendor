import 'dart:io';
import '../entities/appointment_entity.dart';
import '../entities/appointment_details_entity.dart';

abstract class AppointmentRepository {
  Future<AppointmentsListEntity> getAppointments({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String branch = '',
  });

  Future<AppointmentDetailsEntity> getAppointmentDetails(String id);

  Future<void> uploadReport({
    required String orderId,
    required String reportType,
    required String patientId,
    required String selectType,
    String? description,
    required File file,
  });

  Future<void> updateOrderStatus({
    required String orderId,
    required String orderStatus,
  });
}
