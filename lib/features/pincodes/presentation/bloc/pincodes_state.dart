import '../../domain/entities/pincode_entity.dart';

abstract class PincodesState {}

class PincodesInitial extends PincodesState {}

class PincodesLoading extends PincodesState {}

class PincodesLoaded extends PincodesState {
  final List<PincodeDataEntity> pincodes;

  PincodesLoaded({required this.pincodes});
}

class PincodeCreated extends PincodesState {}

class PincodeUpdated extends PincodesState {}

class PincodeDeleted extends PincodesState {}

class PincodeOperationError extends PincodesState {
  final String message;

  PincodeOperationError({required this.message});
}

class PincodesError extends PincodesState {
  final String message;

  PincodesError({required this.message});
}
