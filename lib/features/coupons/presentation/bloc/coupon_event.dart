import 'package:equatable/equatable.dart';
import '../../domain/entities/coupon_entity.dart';

abstract class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object> get props => [];
}

class SubmitAddCouponEvent extends CouponEvent {
  final Coupon coupon;

  const SubmitAddCouponEvent({required this.coupon});

  @override
  List<Object> get props => [coupon];
}

class SubmitUpdateCouponEvent extends CouponEvent {
  final String id;
  final Coupon coupon;

  const SubmitUpdateCouponEvent({required this.id, required this.coupon});

  @override
  List<Object> get props => [id, coupon];
}

class GetCouponsEvent extends CouponEvent {
  final int page;
  final int limit;
  final String search;
  final String status;
  final bool isLoadMore;

  const GetCouponsEvent({
    this.page = 1,
    this.limit = 10,
    this.search = '',
    this.status = '',
    this.isLoadMore = false,
  });

  @override
  List<Object> get props => [page, limit, search, status, isLoadMore];
}

class FetchCustomersEvent extends CouponEvent {
  final String search;

  const FetchCustomersEvent({this.search = ''});

  @override
  List<Object> get props => [search];
}

class DeleteCouponEvent extends CouponEvent {
  final String id;

  const DeleteCouponEvent({required this.id});

  @override
  List<Object> get props => [id];
}
