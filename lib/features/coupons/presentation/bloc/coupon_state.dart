import 'package:equatable/equatable.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/entities/customer_entity.dart';

abstract class CouponState extends Equatable {
  const CouponState();

  @override
  List<Object> get props => [];
}

class CouponInitial extends CouponState {}

class CouponLoading extends CouponState {}

class CouponSuccess extends CouponState {}

class CouponFailure extends CouponState {
  final String message;

  const CouponFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class CouponUpdateLoading extends CouponState {}

class CouponUpdateSuccess extends CouponState {}

class CouponUpdateFailure extends CouponState {
  final String message;

  const CouponUpdateFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class CouponListLoading extends CouponState {}

class CouponListLoaded extends CouponState {
  final List<Coupon> coupons;

  const CouponListLoaded({required this.coupons});

  @override
  List<Object> get props => [coupons];
}

class CouponListError extends CouponState {
  final String message;

  const CouponListError({required this.message});

  @override
  List<Object> get props => [message];
}

class CustomersLoading extends CouponState {}

class CustomersLoaded extends CouponState {
  final List<Customer> customers;

  const CustomersLoaded({required this.customers});

  @override
  List<Object> get props => [customers];
}

class CustomersError extends CouponState {
  final String message;

  const CustomersError({required this.message});

  @override
  List<Object> get props => [message];
}
