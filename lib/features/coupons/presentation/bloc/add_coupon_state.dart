import 'package:equatable/equatable.dart';

abstract class AddCouponState extends Equatable {
  const AddCouponState();

  @override
  List<Object> get props => [];
}

class AddCouponInitial extends AddCouponState {}

class AddCouponLoading extends AddCouponState {}

class AddCouponSuccess extends AddCouponState {}

class AddCouponFailure extends AddCouponState {
  final String message;

  const AddCouponFailure({required this.message});

  @override
  List<Object> get props => [message];
}
