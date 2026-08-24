import '../../domain/entities/medicine_delivery_fee.dart';

class MedicineDeliveryFeeModel extends MedicineDeliveryFee {
  const MedicineDeliveryFeeModel({
    required super.minDeliveryFee,
    required super.baseRadius,
    required super.perKmCharge,
    required super.minOrderForFreeDelivery,
  });

  factory MedicineDeliveryFeeModel.fromJson(Map<String, dynamic> json) {
    return MedicineDeliveryFeeModel(
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
