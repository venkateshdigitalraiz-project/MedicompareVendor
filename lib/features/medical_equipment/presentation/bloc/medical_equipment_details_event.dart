import 'package:equatable/equatable.dart';

abstract class MedicalEquipmentDetailsEvent extends Equatable {
  const MedicalEquipmentDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicalEquipmentDetailsEvent extends MedicalEquipmentDetailsEvent {
  final String id;

  const LoadMedicalEquipmentDetailsEvent(this.id);

  @override
  List<Object?> get props => [id];
}
