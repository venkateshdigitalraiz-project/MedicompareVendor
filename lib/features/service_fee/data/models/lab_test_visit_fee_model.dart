import '../../domain/entities/lab_test_visit_fee.dart';

class LabTestVisitFeeModel extends LabTestVisitFee {
  const LabTestVisitFeeModel({
    required super.visitType,
    required super.homeVisitFee,
    required super.urgentSurcharge,
    required super.maxRadius,
  });

  factory LabTestVisitFeeModel.fromJson(Map<String, dynamic> json) {
    return LabTestVisitFeeModel(
      visitType: json['visitType']?.toString() ?? '',
      homeVisitFee: (json['homeVisitFee'] as num?)?.toDouble() ?? 0.0,
      urgentSurcharge: (json['urgentSurcharge'] as num?)?.toDouble() ?? 0.0,
      maxRadius: (json['maxRadius'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitType': visitType,
      'homeVisitFee': homeVisitFee,
      'urgentSurcharge': urgentSurcharge,
      'maxRadius': maxRadius,
    };
  }
}
