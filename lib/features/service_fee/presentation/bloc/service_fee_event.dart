import 'package:equatable/equatable.dart';

abstract class ServiceFeeEvent extends Equatable {
  const ServiceFeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadServiceFee extends ServiceFeeEvent {}

class RefreshServiceFee extends ServiceFeeEvent {}
