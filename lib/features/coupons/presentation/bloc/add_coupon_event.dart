import 'package:equatable/equatable.dart';
import '../../domain/entities/coupon_entity.dart';

abstract class AddCouponEvent extends Equatable {
  const AddCouponEvent();

  @override
  List<Object> get props => [];
}

class SubmitAddCouponEvent extends AddCouponEvent {
  final Coupon coupon;

  const SubmitAddCouponEvent({required this.coupon});

  @override
  List<Object> get props => [coupon];
}
