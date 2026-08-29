import 'package:equatable/equatable.dart';

abstract class ServiceFeeEvent extends Equatable {
  const ServiceFeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadServiceFee extends ServiceFeeEvent {}

class RefreshServiceFee extends ServiceFeeEvent {}

class SaveServiceFee extends ServiceFeeEvent {
  final dynamic currentFee;

  const SaveServiceFee(this.currentFee);

  @override
  List<Object?> get props => [currentFee];
}

class ResetServiceFee extends ServiceFeeEvent {}
