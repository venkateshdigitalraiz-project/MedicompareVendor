import '../../domain/entities/pincode_entity.dart';

abstract class PincodesState {}

class PincodesInitial extends PincodesState {}

class PincodesLoading extends PincodesState {}

class PincodesLoaded extends PincodesState {
  final List<PincodeDataEntity> pincodes;

  PincodesLoaded({required this.pincodes});
}

class PincodesError extends PincodesState {
  final String message;

  PincodesError({required this.message});
}
