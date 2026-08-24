import '../../domain/entities/service_fee.dart';
import 'medicine_delivery_fee_model.dart';
import 'medical_equipment_delivery_fee_model.dart';
import 'lab_test_visit_fee_model.dart';
import 'service_fee_user_model.dart';

class ServiceFeeModel extends ServiceFee {
  const ServiceFeeModel({
    required super.id,
    required super.vendorId,
    super.medicine,
    super.medicalEquipment,
    super.labTests,
    super.user,
    required super.createdAt,
    required super.updatedAt,
    super.branchOverrides,
  });

  factory ServiceFeeModel.fromJson(Map<String, dynamic> json, {ServiceFeeUserModel? user}) {
    final services = json['services'] as Map<String, dynamic>?;

    MedicineDeliveryFeeModel? medicineModel;
    if (services != null && services['medicine'] != null) {
      final delivery = services['medicine']['delivery'] as Map<String, dynamic>?;
      if (delivery != null) {
        medicineModel = MedicineDeliveryFeeModel.fromJson(delivery);
      }
    }

    MedicalEquipmentDeliveryFeeModel? medicalEquipmentModel;
    if (services != null && services['medicalequipment'] != null) {
      final delivery = services['medicalequipment']['delivery'] as Map<String, dynamic>?;
      if (delivery != null) {
        medicalEquipmentModel = MedicalEquipmentDeliveryFeeModel.fromJson(delivery);
      }
    }

    LabTestVisitFeeModel? labTestsModel;
    if (services != null && services['labtests'] != null) {
      final visit = services['labtests']['visit'] as Map<String, dynamic>?;
      if (visit != null) {
        labTestsModel = LabTestVisitFeeModel.fromJson(visit);
      }
    }

    return ServiceFeeModel(
      id: json['_id'] ?? '',
      vendorId: json['vendorId'] ?? '',
      medicine: medicineModel,
      medicalEquipment: medicalEquipmentModel,
      labTests: labTestsModel,
      user: user,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      branchOverrides: json['branchOverrides'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vendorId': vendorId,
      'services': {
        if (medicine != null)
          'medicine': {
            'delivery': (medicine as MedicineDeliveryFeeModel).toJson(),
          },
        if (medicalEquipment != null)
          'medicalequipment': {
            'delivery': (medicalEquipment as MedicalEquipmentDeliveryFeeModel).toJson(),
          },
        if (labTests != null)
          'labtests': {
            'visit': (labTests as LabTestVisitFeeModel).toJson(),
          },
      },
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'branchOverrides': branchOverrides,
    };
  }
}
