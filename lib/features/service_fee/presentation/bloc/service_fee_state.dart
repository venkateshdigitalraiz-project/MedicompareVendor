import 'package:equatable/equatable.dart';
import '../../domain/entities/service_fee.dart';

abstract class ServiceFeeState extends Equatable {
  const ServiceFeeState();

  @override
  List<Object?> get props => [];
}

class ServiceFeeInitial extends ServiceFeeState {}

class ServiceFeeLoading extends ServiceFeeState {}

class ServiceFeeSuccess extends ServiceFeeState {
  final ServiceFee serviceFee;
  const ServiceFeeSuccess(this.serviceFee);

  @override
  List<Object?> get props => [serviceFee];
}

class ServiceFeeFailure extends ServiceFeeState {
  final String message;
  const ServiceFeeFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServiceFeeRefreshing extends ServiceFeeState {
  final ServiceFee serviceFee;
  const ServiceFeeRefreshing(this.serviceFee);

  @override
  List<Object?> get props => [serviceFee];
}
