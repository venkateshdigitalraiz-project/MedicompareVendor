import 'dart:io';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_details_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';

import '../../domain/entities/delivery_partner_entity.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AppointmentsListEntity> getAppointments({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String branch = '',
  }) async {
    try {
      final models = await remoteDataSource.getAppointments(
        page: page,
        limit: limit,
        status: status,
        search: search,
        branch: branch,
      );
      return models;
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Failed to fetch appointments: $e');
    }
  }

  @override
  Future<AppointmentDetailsEntity> getAppointmentDetails(String id) async {
    try {
      final model = await remoteDataSource.getAppointmentDetails(id);
      return model;
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> uploadReport({
    required String orderId,
    required String reportType,
    required String patientId,
    required String selectType,
    String? description,
    required File file,
  }) async {
    try {
      await remoteDataSource.uploadReport(
        orderId: orderId,
        reportType: reportType,
        patientId: patientId,
        selectType: selectType,
        description: description,
        file: file,
      );
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String orderStatus,
    String? rejectionReason,
  }) async {
    try {
      await remoteDataSource.updateOrderStatus(
        orderId: orderId,
        orderStatus: orderStatus,
        rejectionReason: rejectionReason,
      );
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<DeliveryPartnersResultEntity> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  }) async {
    try {
      final models = await remoteDataSource.getDeliveryPartners(
        deliveryManType: deliveryManType,
        page: page,
        limit: limit,
        status: status,
        search: search,
      );
      return models;
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'vendor',
    String deliveryPartner = 'self',
    String? readyTime,
  }) async {
    try {
      await remoteDataSource.assignDeliveryPartner(
        orderId: orderId,
        deliveryPartnerId: deliveryPartnerId,
        deliveryManType: deliveryManType,
        deliveryPartner: deliveryPartner,
        readyTime: readyTime,
      );
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
