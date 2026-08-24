import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_equipment_entity.dart';

abstract class MedicalEquipmentDetailsState extends Equatable {
  const MedicalEquipmentDetailsState();

  @override
  List<Object?> get props => [];
}

class MedicalEquipmentDetailsInitial extends MedicalEquipmentDetailsState {}

class MedicalEquipmentDetailsLoading extends MedicalEquipmentDetailsState {}

class MedicalEquipmentDetailsLoaded extends MedicalEquipmentDetailsState {
  final MedicalEquipmentItem item;

  const MedicalEquipmentDetailsLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

class MedicalEquipmentDetailsError extends MedicalEquipmentDetailsState {
  final String message;

  const MedicalEquipmentDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
