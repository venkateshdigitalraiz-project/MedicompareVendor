import 'dart:io';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_details_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';

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
  }) async {
    try {
      await remoteDataSource.updateOrderStatus(
        orderId: orderId,
        orderStatus: orderStatus,
      );
    } on ServerException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
