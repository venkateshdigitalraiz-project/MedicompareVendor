import 'dart:io';
import '../entities/appointment_entity.dart';
import '../entities/appointment_details_entity.dart';

import '../entities/delivery_partner_entity.dart';

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
    String? rejectionReason,
  });

  Future<DeliveryPartnersResultEntity> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  });

  Future<void> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'vendor',
    String deliveryPartner = 'self',
    String? readyTime,
  });
}
