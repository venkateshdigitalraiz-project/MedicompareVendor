import 'package:equatable/equatable.dart';

abstract class AddDeliverymanState extends Equatable {
  final int currentStep;

  const AddDeliverymanState({this.currentStep = 1});

  @override
  List<Object?> get props => [currentStep];
}

class AddDeliverymanInitial extends AddDeliverymanState {
  const AddDeliverymanInitial({super.currentStep = 1});
}

class AddDeliverymanSubmitting extends AddDeliverymanState {
  const AddDeliverymanSubmitting({super.currentStep = 5});
}

class AddDeliverymanSuccess extends AddDeliverymanState {
  final String message;

  const AddDeliverymanSuccess({
    super.currentStep = 5,
    this.message = 'Deliveryman created successfully',
  });

  @override
  List<Object?> get props => [currentStep, message];
}

class AddDeliverymanFailure extends AddDeliverymanState {
  final String error;

  const AddDeliverymanFailure({
    required this.error,
    super.currentStep = 5,
  });

  @override
  List<Object?> get props => [currentStep, error];
}
