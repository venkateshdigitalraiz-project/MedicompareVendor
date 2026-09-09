import 'package:equatable/equatable.dart';
import '../../domain/entities/create_deliveryman_entity.dart';

abstract class AddDeliverymanEvent extends Equatable {
  const AddDeliverymanEvent();

  @override
  List<Object?> get props => [];
}

class ChangeAddDeliverymanStepEvent extends AddDeliverymanEvent {
  final int step;

  const ChangeAddDeliverymanStepEvent(this.step);

  @override
  List<Object?> get props => [step];
}

class SubmitAddDeliverymanEvent extends AddDeliverymanEvent {
  final CreateDeliverymanEntity data;

  const SubmitAddDeliverymanEvent(this.data);

  @override
  List<Object?> get props => [data];
}
