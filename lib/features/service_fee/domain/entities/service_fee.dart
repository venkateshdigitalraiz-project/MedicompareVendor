import 'package:equatable/equatable.dart';
import 'medicine_delivery_fee.dart';
import 'medical_equipment_delivery_fee.dart';
import 'lab_test_visit_fee.dart';
import 'service_fee_user.dart';

class ServiceFee extends Equatable {
  final String id;
  final String vendorId;
  final MedicineDeliveryFee? medicine;
  final MedicalEquipmentDeliveryFee? medicalEquipment;
  final LabTestVisitFee? labTests;
  final ServiceFeeUser? user;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? branchOverrides;

  const ServiceFee({
    required this.id,
    required this.vendorId,
    this.medicine,
    this.medicalEquipment,
    this.labTests,
    this.user,
    required this.createdAt,
    required this.updatedAt,
    this.branchOverrides,
  });

  @override
  List<Object?> get props => [
        id,
        vendorId,
        medicine,
        medicalEquipment,
        labTests,
        user,
        createdAt,
        updatedAt,
        branchOverrides,
      ];
}
