import 'dart:io';
import '../repositories/appointment_repository.dart';

class UploadReportUseCase {
  final AppointmentRepository repository;

  UploadReportUseCase(this.repository);

  Future<void> call({
    required String orderId,
    required String reportType,
    required String patientId,
    required String selectType,
    String? description,
    required File file,
  }) async {
    return await repository.uploadReport(
      orderId: orderId,
      reportType: reportType,
      patientId: patientId,
      selectType: selectType,
      description: description,
      file: file,
    );
  }
}
