import '../../domain/entities/medical_equipment_delivery_fee.dart';

class MedicalEquipmentDeliveryFeeModel extends MedicalEquipmentDeliveryFee {
  const MedicalEquipmentDeliveryFeeModel({
    required super.minDeliveryFee,
    required super.baseRadius,
    required super.perKmCharge,
    required super.minOrderForFreeDelivery,
  });

  factory MedicalEquipmentDeliveryFeeModel.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentDeliveryFeeModel(
      minDeliveryFee: (json['minDeliveryFee'] as num?)?.toDouble() ?? 0.0,
      baseRadius: (json['baseRadius'] as num?)?.toDouble() ?? 0.0,
      perKmCharge: (json['perKmCharge'] as num?)?.toDouble() ?? 0.0,
      minOrderForFreeDelivery: (json['minOrderForFreeDelivery'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minDeliveryFee': minDeliveryFee,
      'baseRadius': baseRadius,
      'perKmCharge': perKmCharge,
      'minOrderForFreeDelivery': minOrderForFreeDelivery,
    };
  }
}
