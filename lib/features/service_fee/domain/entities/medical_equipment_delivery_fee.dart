import 'package:equatable/equatable.dart';

class MedicalEquipmentDeliveryFee extends Equatable {
  final double minDeliveryFee;
  final double baseRadius;
  final double perKmCharge;
  final double minOrderForFreeDelivery;

  const MedicalEquipmentDeliveryFee({
    required this.minDeliveryFee,
    required this.baseRadius,
    required this.perKmCharge,
    required this.minOrderForFreeDelivery,
  });

  @override
  List<Object?> get props => [
        minDeliveryFee,
        baseRadius,
        perKmCharge,
        minOrderForFreeDelivery,
      ];
}
